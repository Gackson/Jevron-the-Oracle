import XCTest
@testable import JEV

private actor RecordingClient: ReadingClient {
    nonisolated let isPreview = false
    var requests: [ReadingRequest] = []
    let delay: Duration
    let incomplete: Bool
    init(delay: Duration = .milliseconds(10), incomplete: Bool = false) {
        self.delay = delay; self.incomplete = incomplete
    }
    func reading(_ request: ReadingRequest) async throws -> ReadingResponse {
        requests.append(request)
        // Intentionally ignore cancellation to exercise the session's stale-result guard.
        try? await Task.sleep(for: delay)
        return .init(requestId: request.requestId, characterId: request.characterId, catalogVersion: "test.1",
                     status: incomplete ? "incomplete" : "complete",
                     segments: [.init(candidateId: "test.answer", text: "A new perspective.")],
                     stopReason: incomplete ? "deadline" : "rule_complete")
    }
}

/// A gate controls completion so the assertions cannot accidentally observe a finished reply.
private actor IncrementalClient: ReadingClient {
    nonisolated let isPreview = false
    private var continuation: CheckedContinuation<Void, Never>?
    let fallback: Bool
    init(fallback: Bool = false) { self.fallback = fallback }
    func reading(_ request: ReadingRequest) async throws -> ReadingResponse {
        try await reading(request, onPartial: { _ in })
    }
    func reading(_ request: ReadingRequest, onPartial: @escaping @Sendable (String) async -> Void) async throws -> ReadingResponse {
        await onPartial("A threshold")
        await withCheckedContinuation { continuation = $0 }
        // Deliberately emit even after cancellation to verify stale-partial protection.
        await onPartial("A threshold. A weight.")
        if fallback { return .authoredFallback(for: request, reason: "composition_error") }
        return .init(requestId: request.requestId, characterId: request.characterId, catalogVersion: "test.1",
                     status: "complete", segments: [.init(candidateId: "test.answer", text: "A threshold. A weight.")],
                     stopReason: "rule_complete")
    }
    func finish() { continuation?.resume(); continuation = nil }
    var paused: Bool { continuation != nil }
}

@MainActor
final class ConversationTests: XCTestCase {
    private func settle(_ store: ConversationStore) async throws {
        for _ in 0..<200 {
            if !store.isWaiting { return }
            try await Task.sleep(for: .milliseconds(5))
        }
        XCTFail("Request did not settle")
    }

    private func awaitPartial(_ client: IncrementalClient) async throws {
        for _ in 0..<200 {
            if await client.paused { return }
            try await Task.sleep(for: .milliseconds(5))
        }
        XCTFail("No incremental reply arrived")
    }

    func testPartialAppearsBeforeCompletionAndKeepsOneTurnIdentity() async throws {
        let store = ConversationStore(), client = IncrementalClient()
        store.draft = "Where next?"
        store.send(using: client)
        try await awaitPartial(client)
        XCTAssertTrue(store.isWaiting)
        XCTAssertTrue(store.history.isEmpty, "Unfinished output must not enter follow-up context")
        XCTAssertEqual(store.displayHistory.count, 1)
        XCTAssertEqual(store.displayHistory.last?.answer, "A threshold")
        let id = store.displayHistory.last?.id
        await client.finish()
        try await settle(store)
        XCTAssertEqual(store.history.count, 1)
        XCTAssertEqual(store.displayHistory.last?.id, id)
        XCTAssertEqual(store.history.last?.answer, "A threshold. A weight.")
        XCTAssertNil(store.pendingTurn)
    }

    func testSwitchDropsPartialAndRejectsLateStreamingUpdates() async throws {
        let store = ConversationStore(), client = IncrementalClient()
        store.draft = "Where next?"
        store.send(using: client)
        try await awaitPartial(client)
        store.select(.stone)
        await client.finish()
        try await Task.sleep(for: .milliseconds(30))
        XCTAssertTrue(store.displayHistory.isEmpty)
        store.select(.oracle)
        XCTAssertTrue(store.displayHistory.isEmpty)
        XCTAssertEqual(store.draft, "Where next?")
    }

    func testFailedCompositionReplacesPartialWithOneFallback() async throws {
        let store = ConversationStore(), client = IncrementalClient(fallback: true)
        store.draft = "Where next?"
        store.send(using: client)
        try await awaitPartial(client)
        await client.finish()
        try await settle(store)
        XCTAssertEqual(store.displayHistory.count, 1)
        XCTAssertTrue(store.history[0].isAuthoredFallback)
        XCTAssertEqual(store.history[0].generationStopReason, "composition_error")
        XCTAssertFalse(store.history[0].fallbackLabel.contains("Connection"))
        XCTAssertFalse(store.history[0].answer.contains("threshold"))
    }

    func testReplyLanguageFollowsSettingWithoutRewritingEarlierTurns() async throws {
        let store=ConversationStore(), client=RecordingClient()
        store.draft="Question in English"
        store.send(using:client,language:.simplifiedChinese)
        try await settle(store)
        XCTAssertEqual(store.history.last?.locale,"zh-Hans")
        store.draft="Follow up"
        store.send(using:client,language:.english)
        try await settle(store)
        let requests=await client.requests
        XCTAssertEqual(requests.map(\.locale),["zh-Hans","en"])
        XCTAssertEqual(requests.last?.history.count,1)
        XCTAssertEqual(store.history.first?.locale,"zh-Hans")
    }
    func testChineseDisplayUnitsPreserveTextAndAttachPunctuation() {
        let text="若水流，则石存。"
        let units=ReplyText.units(text)
        XCTAssertEqual(units.joined(),text)
        XCTAssertFalse(units.contains("，"))
        XCTAssertFalse(units.contains("。"))
        XCTAssertEqual(ReplyText.units("Stone abideth."),["Stone","abideth."])
    }

    func testDoubleSubmitIssuesOneRequest() async throws {
        let store = ConversationStore()
        let client = RecordingClient()
        store.draft = "What am I waiting for?"
        store.send(using: client)
        store.send(using: client)
        try await settle(store)
        let count = await client.requests.count
        XCTAssertEqual(count, 1)
        XCTAssertEqual(store.history.count, 1)
        XCTAssertTrue(store.draft.isEmpty)
    }

    func testSwitchCharacterRejectsLateAnswerAndPreservesDraft() async throws {
        let store = ConversationStore()
        let client = RecordingClient(delay: .milliseconds(80))
        store.draft = "Original question"
        store.send(using: client)
        await Task.yield()
        store.select(.stone)
        store.draft = "Stone question"
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertTrue(store.history.isEmpty)
        XCTAssertNil(store.activeRequest)
        XCTAssertEqual(store.draft, "Stone question")
        store.select(.oracle)
        XCTAssertTrue(store.history.isEmpty)
        XCTAssertEqual(store.draft, "Original question")
    }

    func testIncompleteIsNotSavedAndQuestionCanBeRetried() async throws {
        let store = ConversationStore()
        store.draft = "Should I begin?"
        store.send(using: RecordingClient(incomplete: true))
        try await settle(store)
        XCTAssertTrue(store.history.isEmpty)
        XCTAssertEqual(store.draft, "Should I begin?")
        XCTAssertNotNil(store.errorMessage)
        XCTAssertTrue(store.canSend)
    }

    func testFollowUpUsesPriorTurnsOnlyFromSameCharacter() async throws {
        let store = ConversationStore()
        let client = RecordingClient()
        store.draft = "First"
        store.send(using: client)
        try await settle(store)
        store.draft = "And then?"
        store.send(using: client)
        try await settle(store)
        var requests = await client.requests
        XCTAssertEqual(requests.last?.history.count, 1)
        XCTAssertEqual(requests.last?.history.first?.question, "First")
        store.select(.jester)
        store.draft = "Another question"
        store.send(using: client)
        try await settle(store)
        requests = await client.requests
        XCTAssertTrue(requests.last!.history.isEmpty)
    }

    func testInputLimitUsesUnicodeScalarsAndWhitespaceIsRejected() {
        let store = ConversationStore()
        store.draft = "  \n "
        XCTAssertFalse(store.canSend)
        store.draft = String(repeating: "é", count: 500)
        XCTAssertTrue(store.canSend)
        store.draft += "x"
        XCTAssertFalse(store.canSend)
    }

    func testMismatchedAndEmptyResponsesAreRejected() {
        let request = ReadingRequest(requestId: UUID(), characterId: .oracle, question: "Why?", locale: "en", history: [])
        let mismatch = ReadingResponse(requestId: UUID(), characterId: .oracle, catalogVersion: "test",
                                       status: "complete", segments: [.init(candidateId: "a", text: "Answer")], stopReason: "rule_complete")
        XCTAssertThrowsError(try mismatch.validatedText(for: request))
        let empty = ReadingResponse(requestId: request.requestId, characterId: .oracle, catalogVersion: "test",
                                   status: "complete", segments: [], stopReason: "rule_complete")
        XCTAssertThrowsError(try empty.validatedText(for: request))
    }

    func testSampleRepliesNeverEnterLiveContext() async throws {
        let store = ConversationStore()
        store.turns[.oracle] = [.init(id: UUID(), question: "Sample", answer: "Fixture", date: .now, isPreview: true)]
        let client = RecordingClient()
        store.draft = "Real question"
        store.send(using: client)
        try await settle(store)
        let requests = await client.requests
        XCTAssertTrue(requests[0].history.isEmpty)
    }
}


@MainActor
final class SpeechInputTests: XCTestCase {
    func testReleaseStopsCaptureBeforeFinalTextIsDeliveredOnce() async throws {
        let speech = SpeechInput(testTranscript: "A spoken question")
        var partial = "", results: [String?] = []
        await speech.start(onText: { partial = $0 }, onCompletion: { results.append($0) })
        XCTAssertTrue(speech.isRecording)
        XCTAssertEqual(partial, "A spoken question")
        speech.finish()
        XCTAssertFalse(speech.isRecording)
        XCTAssertTrue(speech.isPreparing)
        XCTAssertTrue(results.isEmpty)
        try await Task.sleep(for: .milliseconds(900))
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0], "A spoken question")
        XCTAssertFalse(speech.isPreparing)
        speech.stop()
        XCTAssertEqual(results.count, 1)
    }

    func testReleaseDuringPreparationPreventsLateCapture() async throws {
        let speech = SpeechInput(testTranscript: "Must not arrive")
        var text = "", completions = 0
        let start = Task {
            await speech.start(onText: { text = $0 }, onCompletion: { result in
                XCTAssertNil(result); completions += 1
            })
        }
        await Task.yield()
        XCTAssertTrue(speech.isPreparing)
        speech.finish()
        await start.value
        XCTAssertFalse(speech.isRecording)
        XCTAssertFalse(speech.isPreparing)
        XCTAssertTrue(text.isEmpty)
        XCTAssertEqual(completions, 1)
    }

    func testInterruptionDiscardsPendingSubmission() async throws {
        let speech = SpeechInput(testTranscript: "Do not send")
        var results: [String?] = []
        await speech.start(onText: { _ in }, onCompletion: { results.append($0) })
        speech.finish()
        speech.stop()
        try await Task.sleep(for: .milliseconds(900))
        XCTAssertEqual(results.count, 1)
        XCTAssertNil(results[0])
        XCTAssertFalse(speech.isRecording)
    }
}
