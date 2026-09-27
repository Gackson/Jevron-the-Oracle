import Foundation
import JavaScriptCore
import Security

/// The user supplies this device's credential in Settings. No key is bundled or logged.
enum JEVKeychain {
    private static let service = "com.jev.oracle.typesafe"
    private static var query: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service,
         kSecAttrAccount as String: "api-key", kSecAttrSynchronizable as String: false]
    }
    static func load() throws -> String? {
        var q = query
        q[kSecReturnData as String] = true; q[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else { throw CredentialError.storage(status) }
        return value
    }
    static func save(_ key: String) throws {
        let value = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, !value.contains(where: { $0.isWhitespace }), value.utf8.count <= 4096 else { throw CredentialError.invalid }
        let data = Data(value.utf8)
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var q = query
            q[kSecValueData as String] = data
            q[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            let added = SecItemAdd(q as CFDictionary, nil)
            guard added == errSecSuccess else { throw CredentialError.storage(added) }
        } else if status != errSecSuccess { throw CredentialError.storage(status) }
    }
    static func delete() throws {
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw CredentialError.storage(status) }
    }
    enum CredentialError: LocalizedError {
        case invalid, storage(OSStatus)
        var errorDescription: String? {
            switch self {
            case .invalid: return "Enter a valid API key without spaces."
            case .storage: return "The key could not be accessed securely. Please try again."
            }
        }
    }
}

protocol JEVTransport: Sendable {
    func send(_ payload: Data, timeout: TimeInterval) async throws -> Data
}

private final class JEVNoRedirect: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

struct JEVHTTPTransport: JEVTransport {
    let key: String
    var session: URLSession = .shared
    func send(_ payload: Data, timeout: TimeInterval) async throws -> Data {
        // Fixed provider endpoint: a settings value cannot redirect a user's credential.
        var request = URLRequest(url: URL(string: "https://api.typesafe.ai/v1/systemone")!)
        request.httpMethod = "POST"; request.httpBody = payload
        request.timeoutInterval = timeout; request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + key, forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request, delegate: JEVNoRedirect())
        try Task.checkCancellation()
        guard let response = response as? HTTPURLResponse else { throw DirectJEVError.provider }
        guard (200..<300).contains(response.statusCode) else { throw DirectJEVError.http(response.statusCode) }
        guard data.count <= 2_000_000 else { throw DirectJEVError.invalidOutput }
        return data
    }
}

private enum DirectJEVError: Error {
    case resources, composition, invalidOutput, provider, deadline, missingKey, stepLimit, http(Int)
    var reason: String {
        switch self {
        case .resources: return "resources"
        case .composition: return "composition_error"
        case .invalidOutput: return "invalid_model_output"
        case .provider: return "transport_error"
        case .deadline: return "deadline"
        case .missingKey: return "missing_key"
        case .stepLimit: return "step_limit"
        case .http(let status): return "http_\(status)"
        }
    }
}

/// Each reply has its own isolated JS context. This code never evaluates model-generated code.
final class JEVComposer {
    private let context: JSContext
    private let engine: JSValue
    init(request: ReadingRequest, bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: "runtime", withExtension: "json", subdirectory: "Language"),
              let scriptURL = bundle.url(forResource: "engine", withExtension: "js", subdirectory: "Language"),
              let context = JSContext() else { throw DirectJEVError.resources }
        self.context = context
        context.evaluateScript(try String(contentsOf: scriptURL, encoding: .utf8))
        guard context.exception == nil, let engine = context.objectForKeyedSubscript("JEV"), !engine.isUndefined else { throw DirectJEVError.resources }
        self.engine = engine
        let input = try JSONEncoder().encode(request)
        try call("initialize", [try String(contentsOf: url, encoding: .utf8), String(decoding: input, as: UTF8.self)])
    }
    @discardableResult private func call(_ name: String, _ arguments: [Any]) throws -> JSValue {
        context.exception = nil
        let value = engine.invokeMethod(name, withArguments: arguments)
        if let exception = context.exception {
            // Only carry a known category across the JS bridge, never raw response data.
            switch exception.objectForKeyedSubscript("message")?.toString() {
            case "invalid_model_output": throw DirectJEVError.invalidOutput
            case "step_limit": throw DirectJEVError.stepLimit
            default: throw DirectJEVError.composition
            }
        }
        guard let value else { throw DirectJEVError.composition }
        return value
    }
    func next() throws -> (payload: Data?, text: String?, version: String?) {
        guard let string = try call("next", []).toString(), let data = string.data(using: .utf8),
              let result = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw DirectJEVError.composition }
        if result["done"] as? Bool == true {
            guard let text = result["text"] as? String, !text.isEmpty,
                  let version = result["catalogVersion"] as? String else { throw DirectJEVError.composition }
            return (nil, text, version)
        }
        guard let payload = result["payload"] as? [String: Any] else { throw DirectJEVError.composition }
        return (try JSONSerialization.data(withJSONObject: payload), nil, nil)
    }
    func snapshot() throws -> String {
        guard let text = try call("snapshot", []).toString() else { throw DirectJEVError.composition }
        return text
    }
    func accept(_ data: Data) throws {
        guard let string = String(data: data, encoding: .utf8) else { throw DirectJEVError.invalidOutput }
        try call("accept", [string])
    }
}

struct DirectJEVClient: ReadingClient {
    var isPreview: Bool { false }
    static var isConfigured: Bool { (try? JEVKeychain.load())?.isEmpty == false }
    var transport: (any JEVTransport)? = nil
    var deadline: TimeInterval = 120
    var keyProvider: @Sendable () throws -> String? = { try JEVKeychain.load() }

    func reading(_ request: ReadingRequest) async throws -> ReadingResponse {
        try await reading(request, onPartial: { _ in })
    }
    func reading(_ request: ReadingRequest, onPartial: @escaping @Sendable (String) async -> Void) async throws -> ReadingResponse {
        try Task.checkCancellation()
        do {
            let activeTransport: any JEVTransport
            if let transport { activeTransport = transport }
            else {
                guard let key = try keyProvider(), !key.isEmpty else { throw DirectJEVError.missingKey }
                activeTransport = JEVHTTPTransport(key: key)
            }
            return try await withThrowingTaskGroup(of: ReadingResponse.self) { group in
                group.addTask { try await compose(request, transport: activeTransport, onPartial: onPartial) }
                group.addTask {
                    try await Task.sleep(for: .seconds(max(0.001, deadline)))
                    throw DirectJEVError.deadline
                }
                defer { group.cancelAll() }
                guard let reply = try await group.next() else { throw DirectJEVError.composition }
                return reply
            }
        } catch is CancellationError {
            // Deadline cancels its network child; actual user cancellation must not save a turn.
            try Task.checkCancellation()
            return .authoredFallback(for: request, reason: "deadline")
        } catch let error as URLError {
            try Task.checkCancellation()
            return .authoredFallback(for: request, reason: error.code == .timedOut ? "deadline" : "transport_error")
        } catch {
            try Task.checkCancellation()
            return .authoredFallback(for: request, reason: (error as? DirectJEVError)?.reason ?? "resources")
        }
    }
    private func compose(_ request: ReadingRequest, transport: any JEVTransport, onPartial: @escaping @Sendable (String) async -> Void) async throws -> ReadingResponse {
        let composer = try JEVComposer(request: request)
        var lastPartial = ""
        let clock = ContinuousClock(), start = ContinuousClock.now
        // Grammar owns tighter character limits; this hard ceiling also bounds unexpected resource changes.
        for _ in 0..<49 {
            try Task.checkCancellation()
            let next = try composer.next()
            if let text = next.text, let version = next.version {
                let response = ReadingResponse(requestId: request.requestId, characterId: request.characterId,
                    catalogVersion: version, status: "complete",
                    segments: [.init(candidateId: request.characterId.rawValue + ".composed", text: text)],
                    stopReason: "rule_complete", origin: "jev", generationStatus: "complete")
                _ = try response.validatedText(for: request)
                return response
            }
            let elapsed = start.duration(to: clock.now).components
            let remaining = deadline - Double(elapsed.seconds) - Double(elapsed.attoseconds) / 1e18
            guard remaining > 0, let payload = next.payload else { throw DirectJEVError.deadline }
            let data = try await transport.send(payload, timeout: min(25, remaining))
            try Task.checkCancellation()
            try composer.accept(data)
            let partial = try composer.snapshot()
            if !partial.isEmpty && partial != lastPartial {
                try Task.checkCancellation()
                await onPartial(partial)
                lastPartial = partial
            }
        }
        throw DirectJEVError.composition
    }
}
