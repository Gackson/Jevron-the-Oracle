import Foundation
import Observation

enum AnswerLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    var id: String { rawValue }
    var title: String { self == .english ? "English" : "简体中文" }
    var speechLocale: String { self == .english ? "en-US" : "zh-CN" }
}

/// Keep CJK text compact and prevent closing punctuation from beginning a wrapped row.
enum ReplyText {
    static func containsChinese(_ text: String) -> Bool {
        text.unicodeScalars.contains { (0x3400...0x9FFF).contains($0.value) || (0x20000...0x2FA1F).contains($0.value) }
    }
    static func units(_ text: String) -> [String] {
        guard containsChinese(text) else { return text.split(whereSeparator: \.isWhitespace).map(String.init) }
        var result: [String] = []
        for character in text where !character.isWhitespace {
            if "，。？！；：、）》」』】”.!?;:,".contains(character), !result.isEmpty {
                result[result.count - 1].append(character)
            } else { result.append(String(character)) }
        }
        return result
    }
}

enum OracleCharacter: String, CaseIterable, Codable, Identifiable, Sendable {
    case oracle, stone, jester, fool
    var id: String { rawValue }
    var name: String { self == .stone ? "The Stela" : "The " + rawValue.capitalized }
    func advanced(by offset: Int) -> Self {
        let characters = Self.allCases
        let index = characters.firstIndex(of: self)!
        return characters[((index + offset) % characters.count + characters.count) % characters.count]
    }
    var invitation: String {
        switch self {
        case .oracle: return "What weighs on your mind?"
        case .stone: return "Leave a question in the quiet."
        case .jester: return "What are you so certain of?"
        case .fool: return "What shall we make wonderfully strange?"
        }
    }
    var rule: String {
        switch self {
        case .oracle: return "A few words. Room for yours."
        case .stone: return "A thought, held in silence."
        case .jester: return "An unexpected turn."
        case .fool: return "A little sense. A little nonsense."
        }
    }
}

struct ReadingTurn: Identifiable, Codable, Sendable {
    let id: UUID
    let question: String
    var answer: String
    let date: Date
    let isPreview: Bool
    var origin: String? = nil
    var generationStopReason: String? = nil
    var locale: String? = nil
    var isAuthoredFallback: Bool { origin == "authored_fallback" }
    var fallbackLabel: String {
        if locale == "zh-Hans" {
            let reason: String
            switch generationStopReason {
            case "transport_error": reason = "连接中断"
            case "deadline": reason = "回答超时"
            case "missing_key": reason = "请在设置中添加密钥"
            case "http_401", "http_403": reason = "请检查密钥"
            case "http_429": reason = "服务请求过于频繁"
            case "invalid_model_output", "composition_error", "step_limit": reason = "未能完成回答"
            default: reason = "暂时无法生成回答"
            }
            return reason + " · 角色备用回复"
        }
        let reason: String
        switch generationStopReason {
        case "transport_error": reason = "Connection interrupted"
        case "deadline": reason = "Reply timed out"
        case "missing_key": reason = "Add an API key in Settings"
        case "http_401", "http_403": reason = "Check your API key"
        case "http_429": reason = "Service rate limit reached"
        case "invalid_model_output", "composition_error", "step_limit": reason = "Reply could not be completed"
        case "resources": reason = "Language resources unavailable"
        default: reason = "Reply unavailable"
        }
        return reason + " · character reply"
    }
}

struct ContextTurn: Codable, Sendable {
    let question: String
    let answer: String
}

struct ReadingRequest: Codable, Sendable {
    let requestId: UUID
    let characterId: OracleCharacter
    let question: String
    let locale: String
    let history: [ContextTurn]
}

struct ReadingResponse: Codable, Sendable {
    struct Segment: Codable, Sendable {
        let candidateId: String
        let text: String
    }
    let requestId: UUID
    let characterId: OracleCharacter
    let catalogVersion: String
    let status: String
    let segments: [Segment]
    let stopReason: String
    var origin: String? = nil
    var generationStatus: String? = nil
    var generationStopReason: String? = nil

    func validatedText(for request: ReadingRequest) throws -> String {
        guard requestId == request.requestId, characterId == request.characterId,
              !catalogVersion.isEmpty else { throw ReadingError.invalidResponse }
        guard status == "complete" else {
            throw ReadingError.interrupted
        }
        switch origin {
        case nil:
            // Existing previews and v2 fixtures remain compatible.
            guard stopReason == "rule_complete", generationStatus == nil else { throw ReadingError.invalidResponse }
        case "jev":
            guard stopReason == "rule_complete", generationStatus == "complete" else { throw ReadingError.invalidResponse }
        case "authored_fallback":
            guard stopReason == "fallback_complete", generationStatus == "failed" else { throw ReadingError.invalidResponse }
        default: throw ReadingError.invalidResponse
        }
        guard !segments.isEmpty, segments.count <= 128,
              segments.allSatisfy({ !$0.candidateId.isEmpty && !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            throw ReadingError.invalidResponse
        }
        let result = segments.map(\.text).joined(separator: request.locale == "zh-Hans" ? "" : " ")
        guard result.unicodeScalars.count <= 2_000 else { throw ReadingError.invalidResponse }
        return result
    }

    static func authoredFallback(for request: ReadingRequest, reason: String? = nil) -> ReadingResponse {
        let text: String
        if request.locale == "zh-Hans" {
            switch request.characterId {
            case .oracle: text = "答案还没有抵达。请稍等片刻，再问一次。"
            case .stone: text = "碑声未至，容后再问。"
            case .jester: text = "我的话在后台迷了路，容我重新登场。"
            case .fool: text = "我的念头把裤子弄丢了，请让我找一找。"
            }
        } else { switch request.characterId {
        case .oracle: text = "The answer has not reached me. Give me a moment, and ask again."
        case .stone: text = "The echo has not crossed the stone. Ask again."
        case .jester: text = "My words have missed their cue. Give them another entrance."
        case .fool: text = "My thoughts have misplaced their trousers. Let me try again."
        }
        }
        return .init(requestId: request.requestId, characterId: request.characterId,
                     catalogVersion: "client-fallback.1", status: "complete",
                     segments: [.init(candidateId: request.characterId.rawValue + ".client_fallback", text: text)],
                     stopReason: "fallback_complete", origin: "authored_fallback", generationStatus: "failed", generationStopReason: reason)
    }
}

enum ReadingError: Error, LocalizedError {
    case invalidResponse, interrupted, unavailable, invalidEndpoint
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "The reply could not be read. Please try again."
        case .interrupted: return "The echo was interrupted. Your question is still here."
        case .unavailable: return "We couldn’t receive an answer. Check your connection and try again."
        case .invalidEndpoint: return "Add a valid HTTPS service address in Settings."
        }
    }
}

protocol ReadingClient: Sendable {
    var isPreview: Bool { get }
    func reading(_ request: ReadingRequest) async throws -> ReadingResponse
    func reading(_ request: ReadingRequest, onPartial: @escaping @Sendable (String) async -> Void) async throws -> ReadingResponse
}

extension ReadingClient {
    func reading(_ request: ReadingRequest, onPartial: @escaping @Sendable (String) async -> Void) async throws -> ReadingResponse {
        try await reading(request)
    }
}

struct HTTPReadingClient: ReadingClient {
    let baseURL: URL
    var session: URLSession = .shared
    var accessToken: String? = nil
    var isPreview: Bool { false }
    func reading(_ request: ReadingRequest) async throws -> ReadingResponse {
        guard baseURL.scheme == "https", baseURL.host != nil,
              baseURL.user == nil, baseURL.password == nil,
              baseURL.query == nil, baseURL.fragment == nil else { throw ReadingError.invalidEndpoint }
        try Task.checkCancellation()
        var call = URLRequest(url: baseURL.appendingPathComponent("v2/readings"))
        call.httpMethod = "POST"
        // Server's total generation budget is 120s; leave room for transport.
        call.timeoutInterval = 150
        call.cachePolicy = .reloadIgnoringLocalCacheData
        call.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let accessToken, !accessToken.isEmpty {
            call.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        call.httpBody = try JSONEncoder().encode(request)
        do {
            let (data, response) = try await session.data(for: call)
            try Task.checkCancellation()
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
                  data.count <= 65_536 else { throw ReadingError.unavailable }
            let reply = try JSONDecoder().decode(ReadingResponse.self, from: data)
            _ = try reply.validatedText(for: request)
            return reply
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            try Task.checkCancellation()
            return .authoredFallback(for: request)
        }
    }
}

/// Explicit interaction fixtures. Never used as fallback for a failed live request.
struct PreviewReadingClient: ReadingClient {
    var isPreview: Bool { true }
    var initialDelay: Duration = .milliseconds(450)
    var wordInterval: Duration = .milliseconds(180)
    func reading(_ request: ReadingRequest) async throws -> ReadingResponse {
        try await reading(request, onPartial: { _ in })
    }
    func reading(_ request: ReadingRequest, onPartial: @escaping @Sendable (String) async -> Void) async throws -> ReadingResponse {
        try await Task.sleep(for: initialDelay)
        let samples: [OracleCharacter: [String]] = [
            .oracle: ["Notice which answer you were hoping for.", "Some things loosen when you stop pulling.", "Let the urgency pass. See what remains."],
            .stone: ["A threshold. A weight. A footprint.", "An anchor. A current. A shore.", "A seed. A winter. A return."],
            .jester: ["Your fear has appointed itself head of security.", "Your backup plan has become your only plan.", "Your first draft is waiting for permission from its own eraser."],
            .fool: ["Your plan wears a tiny helmet.", "A suspicious goose audits your homework.", "The confused toaster apologizes to your calendar."]
        ]
        let chinese: [OracleCharacter: [String]] = [
            .oracle: ["留意一下，你正在盼望哪一种答案。", "有些东西，停止拉扯才会松开。", "让急切过去，再看看留下了什么。"],
            .stone: ["石静而水行。", "若根未深，莫问枝远。", "风过而痕存。"],
            .jester: ["你的恐惧，何时当上了评委？", "你要的是答案，还是许可？", "计划开完了会，行动还在门外。"],
            .fool: ["你的计划戴上了微小的头盔。", "可疑的鹅正在审计你的作业。", "烤面包机郑重地向日历道歉。"]
        ]
        let text = (request.locale == "zh-Hans" ? chinese : samples)[request.characterId]![request.history.count % 3]
        var received: [String] = []
        for word in ReplyText.units(text) {
            try Task.checkCancellation()
            received.append(String(word))
            await onPartial(received.joined(separator: request.locale == "zh-Hans" ? "" : " "))
            try await Task.sleep(for: wordInterval)
        }
        return ReadingResponse(requestId: request.requestId, characterId: request.characterId,
                               catalogVersion: "preview.1", status: "complete",
                               segments: [.init(candidateId: "preview.sample", text: text)], stopReason: "rule_complete")
    }
}

@MainActor @Observable
final class ConversationStore {
    var selected: OracleCharacter = .oracle
    var drafts: [OracleCharacter: String] = [:]
    var turns: [OracleCharacter: [ReadingTurn]] = [:]
    private(set) var pendingTurn: ReadingTurn?
    var activeRequest: UUID?
    var errorMessage: String?
    var latestRevealingID: UUID?
    private var requestTask: Task<Void, Never>?
    var isWaiting: Bool { activeRequest != nil }
    var draft: String {
        get { drafts[selected, default: ""] }
        set { drafts[selected] = newValue }
    }
    var history: [ReadingTurn] { turns[selected, default: []] }
    var displayHistory: [ReadingTurn] { history + (pendingTurn.map { [$0] } ?? []) }
    var canSend: Bool {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        return !isWaiting && !text.isEmpty && text.unicodeScalars.count <= 500
    }

    func select(_ character: OracleCharacter) {
        guard character != selected else { return }
        cancel()
        selected = character
        latestRevealingID = nil
        errorMessage = nil
    }

    func cancel() {
        requestTask?.cancel()
        requestTask = nil
        activeRequest = nil
        pendingTurn = nil
    }

    func clearConversation() {
        cancel()
        turns[selected] = []
        drafts[selected] = ""
        latestRevealingID = nil
        errorMessage = nil
    }

    private func receivePartial(_ text: String, requestID: UUID, character: OracleCharacter) {
        guard activeRequest == requestID, selected == character, pendingTurn?.id == requestID,
              !text.isEmpty, text.unicodeScalars.count <= 2_000 else { return }
        pendingTurn?.answer = text
    }

    func send(using client: any ReadingClient, language: AnswerLanguage = .english) {
        guard canSend else { return }
        let question = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        let character = selected
        let id = UUID()
        // Fixture turns never become evidence in a live conversation.
        let context = history.filter { $0.isPreview == client.isPreview && !$0.isAuthoredFallback }.suffix(6).map {
            ContextTurn(question: $0.question, answer: $0.answer)
        }
        let request = ReadingRequest(requestId: id, characterId: character, question: question, locale: language.rawValue, history: context)
        activeRequest = id
        pendingTurn = .init(id: id, question: question, answer: "", date: .now, isPreview: client.isPreview, locale: language.rawValue)
        latestRevealingID = id
        errorMessage = nil
        requestTask = Task { [weak self] in
            do {
                let response = try await client.reading(request) { [weak self] text in
                    await self?.receivePartial(text, requestID: id, character: character)
                }
                try Task.checkCancellation()
                let answer = try response.validatedText(for: request)
                guard let self, self.activeRequest == id, self.selected == character else { return }
                self.turns[character, default: []].append(.init(id: id, question: question, answer: answer, date: .now,
                                                              isPreview: client.isPreview, origin: response.origin,
                                                              generationStopReason: response.generationStopReason, locale: language.rawValue))
                self.drafts[character] = ""
                self.latestRevealingID = id
                self.pendingTurn = nil
                self.activeRequest = nil
                self.requestTask = nil
            } catch {
                guard let self, self.activeRequest == id else { return }
                self.pendingTurn = nil
                self.activeRequest = nil
                self.requestTask = nil
                if !(error is CancellationError) {
                    self.errorMessage = (error as? ReadingError)?.localizedDescription ?? ReadingError.unavailable.localizedDescription
                }
            }
        }
    }
}
