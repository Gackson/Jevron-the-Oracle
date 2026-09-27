import XCTest
@testable import JEV

private actor ScriptedJEV: JEVTransport {
    var payloads: [Data] = []
    var words: [String]
    var invalid = false
    var failAfter: Int?
    var failure: URLError?
    var partials: [String] = []
    var partialsAtSend: [[String]] = []
    func recordPartial(_ text: String) { partials.append(text) }
    init(words: [String] = [], invalid: Bool = false, failAfter: Int? = nil, failure: URLError? = nil) {
        self.words = words; self.invalid = invalid; self.failAfter = failAfter; self.failure = failure
    }
    func send(_ payload: Data, timeout: TimeInterval) async throws -> Data {
        payloads.append(payload)
        partialsAtSend.append(partials)
        if invalid || (failAfter.map { payloads.count > $0 } ?? false) {
            if let failure { throw failure }
            return Data("{}".utf8)
        }
        let p = try JSONSerialization.jsonObject(with:payload) as! [String:Any]
        let q = (p["questions"] as! [String:Any])["nextFragment"] as! [String:Any]
        let criteria = q["criteria"] as! [String:[String:Any]]
        let state = p["state"] as! [String:Any]
        let choice: String
        if state["reply_so_far"] == nil { choice = "begin" }
        else if words.isEmpty { choice = criteria.keys.sorted().first! }
        else {
            let word = words.removeFirst()
            choice = try XCTUnwrap(criteria.first { $0.value["text"] as? String == word }?.key)
        }
        let probabilities = Dictionary(uniqueKeysWithValues: criteria.keys.map { ($0,$0 == choice ? 1.0:0.0) })
        return try JSONSerialization.data(withJSONObject:["model":p["model"]!,"answers":["nextFragment":[
            "type":"choice","choice":choice,"confidence":1.0,"probabilities":probabilities]]])
    }
}
private final class DirectProviderProtocol: URLProtocol {
    static var inspected: URLRequest?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        Self.inspected = request
        client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: 401,
            httpVersion: nil, headerFields: nil)!, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("unauthorized".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}
private struct SlowJEV: JEVTransport {
    func send(_ payload: Data, timeout: TimeInterval) async throws -> Data {
        try await Task.sleep(for:.seconds(30)); return Data()
    }
}

@MainActor
final class DirectJEVTests: XCTestCase {
    private func request(_ role:OracleCharacter) -> ReadingRequest {
        .init(requestId:UUID(),characterId:role,question:"Should I begin?",locale:"en",
              history:[.init(question:"Why am I waiting?",answer:"An old fear.")])
    }
    func testAllThreeCharactersUseBundledVocabularyAndHistory() async throws {
        for role in OracleCharacter.allCases {
            let words: [String]
            switch role {
            case .oracle: words=[]
            case .fool: words=["your","plan","wears","a","tiny","helmet",".",""]
            case .stone: words=["the","stone","holds","a","small","trace",".",""]
            case .jester: words=["your","fear","hires","a","lawyer","to","keep","the","door","closed",".",""]
            }
            let transport=ScriptedJEV(words:words), req=request(role)
            let result=try await DirectJEVClient(transport:transport).reading(req)
            XCTAssertEqual(result.origin,"jev",role.rawValue)
            XCTAssertEqual(result.catalogVersion,"2026-09-27.relations1")
            XCTAssertFalse(try result.validatedText(for:req).contains(" ."))
            let payloads=await transport.payloads
            XCTAssertEqual(payloads.count,role == .oracle ? 1:words.count+1)
            for payload in payloads {
                let p=try JSONSerialization.jsonObject(with:payload) as! [String:Any]
                let history=(p["state"] as! [String:Any])["history"] as! [[String:String]]
                XCTAssertEqual(history.first?["answer"],"An old fear.")
                XCTAssertFalse(String(decoding:payload,as:UTF8.self).contains("no_match"))
            }
            if role == .jester { XCTAssertEqual(try result.validatedText(for:req),"Your fear hires a lawyer to keep the door closed.") }
        }
    }
    func testChineseCatalogsComposeAndStreamWithoutSpaces() async throws {
        for role in OracleCharacter.allCases {
            let words: [String]
            switch role {
            case .oracle: words=[]
            case .stone: words=["石","犹","存","。",""]
            case .jester: words=["你","为什么","需要","许可","？",""]
            case .fool: words=["可疑","的","鹅","审计","你","的","作业","。",""]
            }
            let transport=ScriptedJEV(words:words)
            let req=ReadingRequest(requestId:UUID(),characterId:role,question:"Should I begin?",locale:"zh-Hans",history:[])
            let result=try await DirectJEVClient(transport:transport).reading(req) { text in await transport.recordPartial(text) }
            let answer=try result.validatedText(for:req)
            XCTAssertEqual(result.origin,"jev",role.rawValue)
            XCTAssertTrue(ReplyText.containsChinese(answer))
            XCTAssertFalse(answer.contains(" "))
            let partials=await transport.partials
            XCTAssertEqual(partials.last,answer)
            for partial in partials { XCTAssertTrue(answer.hasPrefix(partial)) }
            let fallback=try await DirectJEVClient(keyProvider:{nil}).reading(req)
            XCTAssertTrue(ReplyText.containsChinese(try fallback.validatedText(for:req)))
            XCTAssertEqual(fallback.generationStopReason,"missing_key")
        }
    }
    func testArchaicStelaFormsComposeWithCorrectVerbShape() async throws {
        for words in [["stone","abideth",".",""],["the","stone","hath","a","trace",".",""],
                      ["the","stone","doth","hold","a","trace",".",""]] {
            let req=request(.stone)
            let result=try await DirectJEVClient(transport:ScriptedJEV(words:words)).reading(req)
            XCTAssertEqual(result.origin,"jev")
        }
    }
    func testDirectLiveChineseWhenExplicitlyEnabled() async throws {
        guard let key=ProcessInfo.processInfo.environment["JEV_TEST_API_KEY"],
              ProcessInfo.processInfo.environment["JEV_LIVE_CHINESE"] == "1", !key.isEmpty else {
            throw XCTSkip("Explicitly enable the paid Chinese four-character smoke test")
        }
        for role in OracleCharacter.allCases where ProcessInfo.processInfo.environment["JEV_LIVE_ROLE"] == nil || ProcessInfo.processInfo.environment["JEV_LIVE_ROLE"] == role.rawValue {
            let question=role == .fool ? "作业太无聊了，给我一点好玩的想法。" : role == .stone ? "我总是不敢开始，该怎么办？" : "我该和女朋友分手吗？"
            let req=ReadingRequest(requestId:UUID(),characterId:role,question:question,locale:"zh-Hans",history:[])
            let result=try await DirectJEVClient(keyProvider:{key}).reading(req)
            let answer=try result.validatedText(for:req)
            print("JEV_ZH_LIVE role=\(role.rawValue) origin=\(result.origin ?? "missing") reason=\(result.generationStopReason ?? "complete") reply=\(answer)")
            XCTAssertEqual(result.origin,"jev")
            XCTAssertTrue(ReplyText.containsChinese(answer))
            XCTAssertFalse(answer.contains(" "))
        }
        let req=ReadingRequest(requestId:UUID(),characterId:.stone,question:"What remains after a relationship ends?",locale:"en",history:[])
        let result=try await DirectJEVClient(keyProvider:{key}).reading(req)
        print("JEV_STELA_EN_LIVE origin=\(result.origin ?? "missing") reply=\(try result.validatedText(for:req))")
        XCTAssertEqual(result.origin,"jev")
    }

    func testVerifiedWordsAreDeliveredBeforeTheNextProviderCall() async throws {
        let transport = ScriptedJEV(words: ["the", "stone", "holds", "a", "small", "trace", ".", ""])
        let req = request(.stone)
        let result = try await DirectJEVClient(transport: transport).reading(req) { text in
            await transport.recordPartial(text)
        }
        let partials = await transport.partials
        let beforeCalls = await transport.partialsAtSend
        XCTAssertEqual(partials, ["The", "The stone", "The stone holds", "The stone holds a",
                                  "The stone holds a small", "The stone holds a small trace", "The stone holds a small trace."])
        XCTAssertTrue(beforeCalls[1].isEmpty, "Planning does not display an unverified word")
        XCTAssertEqual(beforeCalls[2], ["The"], "First word must reach UI before second word is requested")
        XCTAssertEqual(partials.last, try result.validatedText(for: req))
    }

    func testShortJesterQuestionFinishesInsteadOfExhaustingCandidates() async throws {
        let transport = ScriptedJEV(words:["what","is","your","fear","?",""])
        let req = request(.jester)
        let result = try await DirectJEVClient(transport:transport).reading(req)
        XCTAssertEqual(result.origin,"jev")
        XCTAssertEqual(try result.validatedText(for:req),"What is your fear?")
    }
    func testFailureAfterPartialKeepsActualCauseAndDoesNotRetry() async throws {
        for networkFailure in [false,true] {
            let transport = ScriptedJEV(words:["you","should"],failAfter:3,
                                        failure:networkFailure ? URLError(.networkConnectionLost):nil)
            let req = request(.jester)
            let result = try await DirectJEVClient(transport:transport).reading(req) { text in
                await transport.recordPartial(text)
            }
            let partials = await transport.partials
            let calls = await transport.payloads.count
            XCTAssertEqual(partials.last,"You should")
            XCTAssertEqual(calls,4)
            XCTAssertEqual(result.generationStopReason,networkFailure ? "transport_error":"invalid_model_output")
            XCTAssertEqual(result.origin,"authored_fallback")
            let turn = ReadingTurn(id:req.requestId,question:req.question,answer:try result.validatedText(for:req),
                                   date:.now,isPreview:false,origin:result.origin,generationStopReason:result.generationStopReason)
            XCTAssertEqual(turn.fallbackLabel.contains("Connection"),networkFailure)
        }
    }
    func testDirectLiveJesterWhenExplicitlyEnabled() async throws {
        guard let key=ProcessInfo.processInfo.environment["JEV_TEST_API_KEY"],
              ProcessInfo.processInfo.environment["JEV_LIVE_JESTER"] == "1", !key.isEmpty else {
            throw XCTSkip("Explicitly enable the paid Jester regression")
        }
        let req=ReadingRequest(requestId:UUID(),characterId:.jester,
            question:"Should I leave my girl?",locale:"en",history:[])
        let result=try await DirectJEVClient(keyProvider:{key}).reading(req)
        print("JEV_JESTER_LIVE origin=\(result.origin ?? "missing") reason=\(result.generationStopReason ?? "complete") reply=\(try result.validatedText(for:req))")
        XCTAssertEqual(result.origin,"jev")
        XCTAssertEqual(result.generationStatus,"complete")
    }

    func testInvalidProviderOutputHasOneAttemptAndCharacterFallback() async throws {
        let transport=ScriptedJEV(invalid:true), req=request(.jester)
        let result=try await DirectJEVClient(transport:transport).reading(req)
        XCTAssertEqual(result.origin,"authored_fallback")
        let calls=await transport.payloads.count
        XCTAssertEqual(calls,1)
        XCTAssertEqual(result.generationStopReason,"invalid_model_output")
        XCTAssertFalse(try result.validatedText(for:req).isEmpty)
    }
    func testDeadlineAndMissingKeyReturnCharacterReplies() async throws {
        let req=request(.stone), start=ContinuousClock.now
        let result=try await DirectJEVClient(transport:SlowJEV(),deadline:0.03).reading(req)
        XCTAssertEqual(result.origin,"authored_fallback")
        XCTAssertEqual(result.generationStopReason,"deadline")
        XCTAssertLessThan(start.duration(to:.now),.seconds(1))
        let missing=try await DirectJEVClient(keyProvider:{nil}).reading(req)
        XCTAssertEqual(missing.origin,"authored_fallback")
        XCTAssertEqual(missing.generationStopReason,"missing_key")
    }
    func testCancellationDoesNotProduceFallback() async throws {
        let req=request(.oracle)
        let task=Task { try await DirectJEVClient(transport:SlowJEV()).reading(req) }
        try await Task.sleep(for:.milliseconds(30));task.cancel()
        do { _=try await task.value;XCTFail("Cancelled read returned a reply") }
        catch { XCTAssertTrue(error is CancellationError) }
    }
    func testProviderEndpointAuthorizationAndFailedKeyFallback() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [DirectProviderProtocol.self]
        let provider = JEVHTTPTransport(key:"fake-test-key", session:URLSession(configuration:config))
        let result = try await DirectJEVClient(transport:provider).reading(request(.oracle))
        XCTAssertEqual(result.origin,"authored_fallback")
        XCTAssertEqual(result.generationStopReason,"http_401")
        let sent = try XCTUnwrap(DirectProviderProtocol.inspected)
        XCTAssertEqual(sent.url?.absoluteString,"https://api.typesafe.ai/v1/systemone")
        XCTAssertEqual(sent.value(forHTTPHeaderField:"Authorization"),"Bearer fake-test-key")
        XCTAssertEqual(sent.httpMethod,"POST")
        XCTAssertLessThanOrEqual(sent.timeoutInterval,25)
    }
    func testKeychainSaveReplaceDelete() throws {
        let original=try JEVKeychain.load()
        defer { if let original { try? JEVKeychain.save(original) } else { try? JEVKeychain.delete() } }
        try JEVKeychain.save("not-a-real-key-one")
        XCTAssertEqual(try JEVKeychain.load(),"not-a-real-key-one")
        try JEVKeychain.save("not-a-real-key-two")
        XCTAssertEqual(try JEVKeychain.load(),"not-a-real-key-two")
        XCTAssertThrowsError(try JEVKeychain.save("  "))
        try JEVKeychain.delete()
        XCTAssertNil(try JEVKeychain.load())
    }
    func testDirectLiveFoolWhenExplicitlyEnabled() async throws {
        guard let key=ProcessInfo.processInfo.environment["JEV_TEST_API_KEY"],
              ProcessInfo.processInfo.environment["JEV_LIVE_FOOL"] == "1", !key.isEmpty else {
            throw XCTSkip("Explicitly enable the paid Fool sample")
        }
        let req=ReadingRequest(requestId:UUID(),characterId:.fool,
            question:"My homework is boring. Give me a silly way to think about it.",locale:"en",history:[])
        let result=try await DirectJEVClient(keyProvider:{key}).reading(req)
        print("JEV_FOOL_LIVE origin=\(result.origin ?? "missing") reply=\(try result.validatedText(for:req))")
        XCTAssertEqual(result.origin,"jev")
        XCTAssertEqual(result.generationStatus,"complete")
    }
    func testDirectLiveOracleWhenExplicitlyEnabled() async throws {
        guard let key=ProcessInfo.processInfo.environment["JEV_TEST_API_KEY"],!key.isEmpty else {
            throw XCTSkip("Supply a test-process key to explicitly enable paid direct-provider verification")
        }
        let req=request(.oracle)
        let result=try await DirectJEVClient(keyProvider:{key}).reading(req)
        XCTAssertEqual(result.origin,"jev")
        XCTAssertEqual(result.generationStatus,"complete")
        XCTAssertFalse(try result.validatedText(for:req).isEmpty)
    }
}
