import Foundation
import Speech
import AVFAudio
import Observation

@MainActor @Observable
final class SpeechInput {
    var isRecording = false
    var isPreparing = false
    var message: String?
    private let engine = AVAudioEngine()
    private var recognition: SFSpeechRecognitionTask?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var session = UUID()
    private var tapInstalled = false
    private var timeout: Task<Void, Never>?
    private var finalizer: Task<Void, Never>?
    private var completion: (@MainActor (String?) -> Void)?
    private var latestText = ""
    private let testTranscript: String?

    init(testTranscript: String? = nil) { self.testTranscript = testTranscript }

    func start(locale: String = "en-US", onText: @escaping @MainActor (String) -> Void, onCompletion: (@MainActor (String?) -> Void)? = nil) async {
        guard !isRecording && !isPreparing else { return }
        isPreparing = true
        message = nil
        let token = UUID()
        session = token
        completion = onCompletion
        latestText = ""
        // Explicit test injection exercises the same finish/cancellation lifecycle without a microphone.
        if let testTranscript {
            try? await Task.sleep(for: .milliseconds(100))
            guard session == token else { return }
            isPreparing = false
            isRecording = true
            latestText = testTranscript
            onText(testTranscript)
            return
        }
        let authorization = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
        guard session == token else { return }
        guard authorization == .authorized else {
            stop()
            message = "Speech permission is off."
            return
        }
        let allowed = await AVAudioApplication.requestRecordPermission()
        guard session == token else { return }
        guard allowed, let recognizer = SFSpeechRecognizer(locale: Locale(identifier: locale)), recognizer.isAvailable else {
            stop()
            message = "Speech is unavailable."
            return
        }
        do {
            let audio = AVAudioSession.sharedInstance()
            try audio.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audio.setActive(true)
            let bufferRequest = SFSpeechAudioBufferRecognitionRequest()
            bufferRequest.shouldReportPartialResults = true
            request = bufferRequest
            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            guard format.sampleRate > 0 && format.channelCount > 0 else { throw ReadingError.unavailable }
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                bufferRequest.append(buffer)
            }
            tapInstalled = true
            recognition = recognizer.recognitionTask(with: bufferRequest) { [weak self] result, error in
                let text = result?.bestTranscription.formattedString
                let final = result?.isFinal ?? false
                Task { @MainActor in
                    guard let self, self.session == token else { return }
                    if let text { self.latestText = text; onText(text) }
                    if error != nil { self.stop() }
                    else if final { self.complete() }
                }
            }
            engine.prepare()
            try engine.start()
            isPreparing = false
            isRecording = true
            timeout = Task { [weak self] in
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled else { return }
                self?.finish()
            }
        } catch {
            stop()
            message = "Microphone unavailable."
        }
    }

    /// Stop capturing, briefly allow the recognizer's final transcription, then invalidate callbacks.
    func finish() {
        guard isRecording else { stop(); return }
        timeout?.cancel()
        timeout = nil
        stopCapture()
        isRecording = false
        isPreparing = true
        request?.endAudio()
        finalizer = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(800))
            guard !Task.isCancelled else { return }
            self?.complete()
        }
    }

    private func complete() { end(with: latestText) }

    func stop() { end(with: nil) }

    private func end(with text: String?) {
        let finished = completion
        completion = nil
        session = UUID()
        timeout?.cancel()
        finalizer?.cancel()
        stopCapture()
        request?.endAudio()
        recognition?.cancel()
        recognition = nil
        request = nil
        isRecording = false
        isPreparing = false
        finished?(text)
    }

    private func stopCapture() {
        guard testTranscript == nil else { return }
        engine.stop()
        if tapInstalled { engine.inputNode.removeTap(onBus: 0); tapInstalled = false }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
