import XCTest
@testable import JEV

private final class APIProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (Int, Data))?
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        do {
            let (status, data) = try Self.handler!(request)
            client?.urlProtocol(self, didReceive: HTTPURLResponse(url: request.url!, statusCode: status,
                         httpVersion: nil, headerFields: ["Content-Type": "application/json"])!, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    override func stopLoading() {}
}

private actor FallbackRecorder: ReadingClient {
    nonisolated let isPreview = false
    var requests: [ReadingRequest] = []
    func reading(_ request: ReadingRequest) async throws -> ReadingResponse {
        requests.append(request)
        return .authoredFallback(for: request)
    }
}

@MainActor
final class ReadingAPITests: XCTestCase {
    private func request(_ role: OracleCharacter = .jester) -> ReadingRequest {
        .init(requestId: UUID(), characterId: role, question: "Why am I waiting?", locale: "en",
              history: [.init(question: "Should I begin?", answer: "Notice the door.")])
    }
    private func client() -> HTTPReadingClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [APIProtocol.self]
        return HTTPReadingClient(baseURL: URL(string: "https://example.test")!, session: URLSession(configuration: config))
    }
    private func body(_ req: ReadingRequest) throws -> Data {
        try JSONSerialization.data(withJSONObject: ["requestId":req.requestId.uuidString,"characterId":req.characterId.rawValue,
            "catalogVersion":"2026-09-27.roles4b","status":"complete","stopReason":"rule_complete","origin":"jev",
            "generationStatus":"complete","segments":[["candidateId":"jester.composed","text":"Your fear hires a lawyer."]]])
    }
    func testHTTPContractAndComposedPunctuation() async throws {
        let req = request(), data = try body(req)
        APIProtocol.handler = { call in
            XCTAssertEqual(call.url?.path,"/v2/readings")
            XCTAssertEqual(call.httpMethod,"POST")
            XCTAssertEqual(call.timeoutInterval,150)
            XCTAssertEqual(call.value(forHTTPHeaderField:"Content-Type"),"application/json")
            var raw = call.httpBody
            if raw == nil, let stream = call.httpBodyStream {
                stream.open(); defer { stream.close() }
                var result = Data(), buffer = [UInt8](repeating:0,count:4096)
                while stream.hasBytesAvailable {
                    let count = stream.read(&buffer,maxLength:buffer.count)
                    if count <= 0 { break }; result.append(buffer,count:count)
                }
                raw = result
            }
            let sent = try JSONDecoder().decode(ReadingRequest.self,from:try XCTUnwrap(raw))
            XCTAssertEqual(sent.requestId,req.requestId)
            XCTAssertEqual(sent.history.first?.answer,"Notice the door.")
            return (200,data)
        }
        let reply = try await client().reading(req)
        XCTAssertEqual(reply.origin,"jev")
        XCTAssertEqual(try reply.validatedText(for:req),"Your fear hires a lawyer.")
    }
    func testUnavailableAndMalformedServicesAlwaysReturnCharacterReply() async throws {
        for role in OracleCharacter.allCases {
            let req = request(role)
            APIProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }
            let offline = try await client().reading(req)
            XCTAssertEqual(offline.origin,"authored_fallback")
            XCTAssertFalse(try offline.validatedText(for:req).isEmpty)
            APIProtocol.handler = { _ in (200,Data("{}".utf8)) }
            let malformed = try await client().reading(req)
            XCTAssertEqual(malformed.origin,"authored_fallback")
        }
    }
    func testServerFallbackIsDecodedWithoutBeingCalledModelSuccess() async throws {
        let req = request(.stone)
        let data = try JSONEncoder().encode(ReadingResponse.authoredFallback(for:req))
        APIProtocol.handler = { _ in (200,data) }
        let reply = try await client().reading(req)
        XCTAssertEqual(reply.generationStatus,"failed")
        XCTAssertEqual(reply.stopReason,"fallback_complete")
        XCTAssertEqual(reply.origin,"authored_fallback")
        var invalid = reply; invalid.origin = "jev"
        XCTAssertThrowsError(try invalid.validatedText(for:req))
    }
    func testCancellationNeverCreatesFallback() async throws {
        APIProtocol.handler = { _ in throw URLError(.cancelled) }
        do { _ = try await client().reading(request()); XCTFail("Cancellation swallowed") }
        catch { XCTAssertTrue(error is CancellationError) }
    }
    func testFallbackIsStoredButExcludedFromNextContext() async throws {
        let store = ConversationStore(), client = FallbackRecorder()
        store.turns[.oracle] = (0..<8).map { .init(id:UUID(),question:"Q\($0)",answer:"A\($0)",date:.now,isPreview:false,origin:"jev") }
        for question in ["First","Second"] {
            store.draft = question; store.send(using:client)
            for _ in 0..<200 {
                if !store.isWaiting { break }
                try await Task.sleep(for:.milliseconds(5))
            }
            XCTAssertFalse(store.isWaiting)
        }
        XCTAssertTrue(store.history.last!.isAuthoredFallback)
        let sent = await client.requests
        XCTAssertEqual(sent.count,2)
        XCTAssertEqual(sent.last?.history.count,6)
        XCTAssertEqual(sent.last?.history.first?.question,"Q2")
        XCTAssertFalse(sent.last!.history.contains { $0.question == "First" })
    }
    func testLocalHTTPSServiceWhenExplicitlyEnabled() async throws {
        guard let address = ProcessInfo.processInfo.environment["JEV_LIVE_TEST_URL"], let url = URL(string:address) else {
            throw XCTSkip("Set JEV_LIVE_TEST_URL to test the running HTTPS service")
        }
        let req = request(.oracle)
        let reply = try await HTTPReadingClient(baseURL:url).reading(req)
        XCTAssertEqual(reply.catalogVersion,"2026-09-27.roles4b", "Must reach server, not client fallback")
        XCTAssertFalse(try reply.validatedText(for:req).isEmpty)
        print("JEV_LIVE_API origin=\(reply.origin ?? "missing") generationStatus=\(reply.generationStatus ?? "missing")")
    }
}
