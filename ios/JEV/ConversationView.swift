import SwiftUI
import AVFAudio

struct RootView: View {
    @AppStorage("selectedCharacter") private var savedCharacter = "oracle"
    @AppStorage("replyLanguage") private var replyLanguage = "en"
    @AppStorage("previewMode") private var previewMode = false
    @AppStorage("sceneEffects") private var effects = true
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var store = ConversationStore()
    @State private var speech = SpeechInput(testTranscript:
        ProcessInfo.processInfo.arguments.contains("--uitesting") && ProcessInfo.processInfo.arguments.contains("--uitesting-speech")
            ? "What if I begin today?" : nil)
    @State private var voicePressID: UUID?
    @State private var voiceReleased = false
    @State private var voiceCompleted = false
    @State private var voiceFinalText: String?
    @State private var showEntrance = true
    @State private var enteringConversation = false
    @State private var entranceOpacity = 1.0
    @State private var showSettings = false
    @State private var sceneMotion = SceneMotion()
    @State private var sceneArtwork: [OracleCharacter: SpatialArtwork] = [:]
    @State private var isSwitching = false
    @State private var outgoingCharacter: OracleCharacter?
    @State private var switchProgress: Double = 1
    @State private var switchTask: Task<Void, Never>?
    @State private var visibleTurn: UUID?
    @State private var viewedPositions: [OracleCharacter: UUID] = [:]
    @State private var seenReveals: Set<UUID> = []
    @FocusState private var inputFocused: Bool

    private var currentClient: (any ReadingClient)? {
        if previewMode {
            if ProcessInfo.processInfo.arguments.contains("--uitesting-slow-reply") {
                return PreviewReadingClient(initialDelay: .seconds(3), wordInterval: .seconds(1))
            }
            return PreviewReadingClient()
        }
        return DirectJEVClient()
    }
    private var copy: InterfaceCopy { .init(language: replyLanguage) }

    private var isLatest: Bool { visibleTurn == nil || visibleTurn == store.displayHistory.last?.id }

    var body: some View {
        ZStack {
            if !showEntrance || enteringConversation {
                conversation
                    .disabled(enteringConversation)
                    .transition(.identity)
            }
            if showEntrance {
                EntranceView {
                    guard !enteringConversation else { return }
                    store.select(.oracle)
                    savedCharacter = OracleCharacter.oracle.rawValue
                    enteringConversation = true
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: EntranceView.dissolveDuration), completionCriteria: .logicallyComplete) {
                        entranceOpacity = 0
                    } completion: {
                        showEntrance = false
                        enteringConversation = false
                        entranceOpacity = 1
                    }
                }
                .opacity(entranceOpacity)
                .transition(.identity)
                .zIndex(1)
            }
        }
        .foregroundStyle(Palette.ink)
        .sheet(isPresented: $showSettings) {
            SettingsView(preview: $previewMode, effects: $effects, language: $replyLanguage) {
                store.clearConversation()
                visibleTurn = nil
            }
        }
        .environment(\.locale, Locale(identifier: replyLanguage))
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("--uitesting") {
                if !ProcessInfo.processInfo.arguments.contains("--uitesting-keep-language") { replyLanguage = "en" }
                previewMode = true
                savedCharacter = "oracle"
                effects = ProcessInfo.processInfo.arguments.contains("--uitesting-fixed-tilt")
            }
            store.select(OracleCharacter(rawValue: savedCharacter) ?? .oracle)
            // A cold launch always begins at the curtain; foregrounding preserves the current view.
            showEntrance = true
        }
        .onChange(of: scenePhase) { _, phase in
            updateSceneMotion()
            if phase != .active { cancelVoicePress(); speech.stop(); store.cancel() }
        }
        .onChange(of: showSettings) { _, showing in
            updateSceneMotion()
            if showing { cancelVoicePress(); speech.stop(); store.cancel(); inputFocused = false }
        }
        .onChange(of: speech.isRecording) { _, recording in
            updateSceneMotion()
            if recording && voicePressID != nil { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
        }
        .onChange(of: showEntrance) { _, _ in updateSceneMotion() }
        .onChange(of: inputFocused) { _, _ in updateSceneMotion() }
        .onChange(of: effects) { _, _ in updateSceneMotion() }
        .onChange(of: reduceMotion) { _, _ in updateSceneMotion() }
        .onDisappear { sceneMotion.stop(); switchTask?.cancel() }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)) { _ in cancelVoicePress(); speech.stop() }
        .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)) { notification in
            if let raw = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
               raw == AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue { cancelVoicePress(); speech.stop() }
        }
    }

    private var isFixedTiltTest: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting") && ProcessInfo.processInfo.arguments.contains("--uitesting-fixed-tilt")
    }

    private func updateSceneMotion() {
        let active = effects && !showEntrance && !inputFocused && !speech.isRecording && !showSettings
            && !reduceMotion && scenePhase == .active
        if active {
            if isFixedTiltTest { sceneMotion.pose = .init(x: 0.75, y: -0.5) }
            else { sceneMotion.start() }
        } else { sceneMotion.stop() }
        // Character changes never stop or recalibrate this shared sensor session.
    }

    private var conversation: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    OracleScene(character: store.selected, effectsEnabled: effects,
                                motionSource: sceneMotion, preparedArtwork: sceneArtwork[store.selected])
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .id(store.selected)
                    if let outgoingCharacter {
                        OracleScene(character: outgoingCharacter, effectsEnabled: effects,
                                    motionSource: sceneMotion, preparedArtwork: sceneArtwork[outgoingCharacter])
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .opacity(1 - switchProgress)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .modifier(DreamDissolve(progress: switchProgress))
            }
            .ignoresSafeArea()
            VStack(spacing: 0) {
                navigation
                GeometryReader { geometry in
                    if store.displayHistory.isEmpty {
                        VStack(spacing: 12) {
                            Spacer(minLength: 0)
                            Text(copy[store.selected.invitation])
                                .font(OracleTypography.serif(.title2, text: copy[store.selected.invitation]))
                                .multilineTextAlignment(.center)
                            Text(copy[store.selected.rule]).font(.footnote).foregroundStyle(Palette.secondary)
                        }
                        .padding(.horizontal, 30).padding(.bottom, 36)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    } else {
                        ScrollView(.vertical) {
                            LazyVStack(spacing: 0) {
                                ForEach(store.displayHistory) { turn in
                                    turnPage(turn, height: geometry.size.height)
                                        .id(turn.id)
                                }
                            }.scrollTargetLayout()
                        }
                        .scrollIndicators(.hidden)
                        .scrollTargetBehavior(.paging)
                        .scrollPosition(id: $visibleTurn)
                        .scrollDismissesKeyboard(.interactively)
                        .accessibilityIdentifier("historyScroll")
                    }
                }
                statusArea
            }
            .disabled(isSwitching)
            .contentShape(Rectangle())
            .simultaneousGesture(TapGesture().onEnded { inputFocused = false })
            // Keep the whole composer in one keyboard-aware layout, outside the dismissal gesture.
            .safeAreaInset(edge: .bottom, spacing: 0) { composer }
        }
        .simultaneousGesture(DragGesture(minimumDistance: 35).onEnded { value in
            guard !inputFocused && !speech.isRecording && !speech.isPreparing,
                  abs(value.translation.width) > abs(value.translation.height) * 1.6,
                  abs(value.translation.width) > 65 else { return }
            switchCharacter(value.translation.width < 0 ? 1 : -1)
        })
        .onChange(of: store.displayHistory.count) { old, new in
            guard new > old else { return }
            let previousLast = store.displayHistory.dropLast().last?.id
            if visibleTurn == nil || visibleTurn == previousLast { visibleTurn = store.displayHistory.last?.id }
        }
        .onChange(of: visibleTurn) { old, new in
            if let old { seenReveals.insert(old) }
            if let new { viewedPositions[store.selected] = new }
        }
    }

    private var navigation: some View {
        VStack(spacing: 12) {
            HStack {
                Menu {
                    ForEach(OracleCharacter.allCases) { character in
                        Button { changeCharacter(character) } label: {
                            if character == store.selected {
                                Label(character.name, systemImage: "checkmark")
                            } else {
                                Text(character.name)
                            }
                        }
                        .accessibilityIdentifier("character_\(character.rawValue)")
                    }
                    Divider()
                    Button(copy["About "] + OracleBrand.name) {
                        speech.stop(); store.cancel(); inputFocused = false
                        showEntrance = true
                    }
                } label: {
                    Text(store.selected.name)
                        .font(.system(size: 18, design: .serif)).tracking(3)
                        .frame(minWidth: 44, minHeight: 44, alignment: .leading)
                        .padding(.horizontal, 16)
                        .modifier(OracleControlGlass())
                }
                .accessibilityLabel(copy.selectedCharacter(store.selected.name))
                .accessibilityIdentifier("characterMenu")
                .accessibilityValue(isFixedTiltTest ? "tilt:\(sceneMotion.pose.x),\(sceneMotion.pose.y)" : "")
                Spacer()
                Button { showSettings = true } label: { Image(systemName: "ellipsis").font(.system(size: 20)).frame(width: 44, height: 44) }
                    .modifier(OracleControlGlass())
                    .accessibilityLabel(copy["Settings"]).accessibilityIdentifier("settingsButton")
            }
            if previewMode || Media.url("\(store.selected.rawValue)-master") == nil {
                Text(copy[previewMode ? "PREVIEW · SAMPLE REPLIES" : "ARTWORK PREVIEW"])
                    .font(.system(size: 10, weight: .medium)).tracking(1.6).foregroundStyle(Palette.secondary)
            }
        }
        .padding(.horizontal, 22).padding(.top, 3)
    }

    private func turnPage(_ turn: ReadingTurn, height: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer(minLength: typeSize.isAccessibilitySize ? 12 : max(20, height * 0.44))
                Text(turn.question).font(.footnote).foregroundStyle(Palette.secondary)
                    .multilineTextAlignment(.center).textSelection(.enabled)
                if turn.answer.isEmpty && turn.id == store.activeRequest {
                    Text(copy["Listening for an echo…"])
                        .font(OracleTypography.serif(.title2, text: copy["Listening for an echo…"]))
                        .modifier(EchoBreath(accent: Palette.accent(store.selected), active: true))
                        .accessibilityIdentifier("waitingEcho")
                } else {
                    WordReveal(text: turn.answer,
                               animate: turn.id == store.latestRevealingID && !seenReveals.contains(turn.id),
                               accent: Palette.accent(store.selected), streaming: turn.id == store.activeRequest)
                }
                Text(turn.isPreview ? copy["Sample reply"] : turn.isAuthoredFallback ? turn.fallbackLabel(language: replyLanguage) : turn.date.formatted(.dateTime.hour().minute().locale(Locale(identifier: replyLanguage))))
                    .font(.caption2).foregroundStyle(Palette.secondary)
                    .opacity(turn.id == store.activeRequest ? 0 : 1)
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 30)
            .frame(minHeight: height)
        }
        .scrollIndicators(typeSize.isAccessibilitySize ? .visible : .hidden)
        .frame(height: height)
    }

    @ViewBuilder private var statusArea: some View {
        if let error = store.errorMessage ?? speech.message {
            Text(copy[error]).font(.footnote).foregroundStyle(Palette.ink).multilineTextAlignment(.center)
                .padding(.horizontal, 26).padding(.bottom, 8).accessibilityIdentifier("errorMessage")
        }
        if store.displayHistory.count > 1 {
            HStack(spacing: 16) {
                Button { moveHistory(-1) } label: { Image(systemName: "chevron.up").frame(width: 44, height: 44) }
                    .accessibilityLabel(copy["Earlier reply"]).accessibilityIdentifier("earlierReply")
                    .disabled(visibleIndex == 0)
                if !isLatest {
                    Button(copy["Back to latest"]) { visibleTurn = store.displayHistory.last?.id }
                        .font(.caption).accessibilityIdentifier("backToLatest")
                } else {
                    Text(copy.echoes(store.displayHistory.count)).font(.caption).foregroundStyle(Palette.secondary)
                }
                Button { moveHistory(1) } label: { Image(systemName: "chevron.down").frame(width: 44, height: 44) }
                    .accessibilityLabel(copy["Later reply"]).disabled(isLatest)
            }
        }
    }

    private var composer: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 4) {
                Button {
                    if speech.isRecording { speech.finish() }
                    else if speech.isPreparing { speech.stop() }
                    else {
                        inputFocused = false
                        let character = store.selected
                        let original = store.draft
                        Task {
                            await speech.start(locale: (AnswerLanguage(rawValue: replyLanguage) ?? .english).speechLocale, onText: { text in
                                guard store.selected == character else { return }
                                store.draft = original.isEmpty ? text : original + " " + text
                            })
                        }
                    }
                } label: {
                    Image(systemName: speech.isRecording || speech.isPreparing ? "stop.fill" : "mic")
                        .font(.system(size: 20))
                        .frame(width: 44, height: 44)
                }
                .disabled(store.isWaiting)
                .accessibilityLabel(copy[speech.isRecording || speech.isPreparing ? "Stop listening" : "Speak your question"])
                .accessibilityIdentifier("speechButton")
                TextField(copy[typeSize.isAccessibilitySize ? "Ask" : "Your question"], text: Binding(get: { store.draft }, set: { store.draft = $0 }), axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.body).lineLimit(1...(typeSize.isAccessibilitySize ? 2 : 4))
                    .padding(.vertical, 12)
                    .focused($inputFocused)
                    .disabled(store.isWaiting || (voicePressID == nil && (speech.isRecording || speech.isPreparing)))
                    .accessibilityIdentifier("questionInput")
                    .accessibilityHint(copy["Tap to type. Touch and hold to speak, then release to send."])
                    .overlay {
                        if !inputFocused && (!speech.isRecording && !speech.isPreparing || voicePressID != nil) {
                            HoldToSpeakSurface(onTap: { inputFocused = true }, onBegin: beginVoicePress,
                                               onEnd: endVoicePress, onCancel: cancelVoicePress)
                                .allowsHitTesting(!store.isWaiting && !isSwitching)
                        }
                    }
                Button(action: send) {
                    Image(systemName: "arrow.up").font(.system(size: 17, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .tint(OracleBrand.citron)
                .foregroundStyle(store.canSend ? Palette.canvas : Palette.secondary)
                .frame(width: 44, height: 44)
                .disabled(!store.canSend || speech.isRecording || speech.isPreparing)
                .accessibilityLabel(copy["Send question"]).accessibilityIdentifier("sendButton")
            }
            .padding(.horizontal, 7).padding(.vertical, 3)
            .modifier(ComposerGlass())
            .overlay {
                RoundedRectangle(cornerRadius: 28)
                    .strokeBorder(Palette.accent(store.selected).opacity(voicePressID == nil ? 0 : 0.7), lineWidth: 1)
                    .allowsHitTesting(false)
            }
        }
        .padding(.horizontal, 20).padding(.top, 4).padding(.bottom, 12)
    }

    private func beginVoicePress() {
        guard !store.isWaiting, !isSwitching, !speech.isRecording, !speech.isPreparing, voicePressID == nil else { return }
        let id = UUID(), character = store.selected
        let original = store.draft
        voicePressID = id
        voiceReleased = false
        voiceCompleted = false
        voiceFinalText = nil
        inputFocused = false
        Task {
            guard voicePressID == id else { return }
            await speech.start(locale: (AnswerLanguage(rawValue: replyLanguage) ?? .english).speechLocale) { text in
                guard voicePressID == id, store.selected == character else { return }
                store.draft = original.isEmpty ? text : original + " " + text
            } onCompletion: { text in
                guard voicePressID == id, store.selected == character else { return }
                voiceCompleted = true
                voiceFinalText = text
                if voiceReleased { submitVoicePress() }
            }
        }
    }

    private func endVoicePress() {
        guard voicePressID != nil else { return }
        voiceReleased = true
        if voiceCompleted { submitVoicePress() }
        else { speech.finish() }
    }

    private func submitVoicePress() {
        let hasSpeech = !(voiceFinalText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        voicePressID = nil
        voiceFinalText = nil
        if hasSpeech && store.canSend { send() }
    }

    private func cancelVoicePress() {
        guard voicePressID != nil else { return }
        voicePressID = nil
        voiceFinalText = nil
        speech.stop()
    }

    private var visibleIndex: Int { store.displayHistory.firstIndex(where: { $0.id == visibleTurn }) ?? max(0, store.displayHistory.count - 1) }
    private func moveHistory(_ delta: Int) {
        let next = visibleIndex + delta
        guard store.displayHistory.indices.contains(next) else { return }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) { visibleTurn = store.displayHistory[next].id }
    }
    private func changeCharacter(_ character: OracleCharacter) {
        guard character != store.selected, !isSwitching else { return }
        cancelVoicePress()
        speech.stop()
        inputFocused = false
        store.cancel()
        if let visibleTurn { viewedPositions[store.selected] = visibleTurn; seenReveals.insert(visibleTurn) }
        func select() {
            store.select(character)
            savedCharacter = character.rawValue
            visibleTurn = viewedPositions[character] ?? store.displayHistory.last?.id
        }
        if reduceMotion { select(); return }
        isSwitching = true
        switchTask = Task { @MainActor in
            let previous = store.selected
            let previousArtwork = await SpatialArtworkLoader.shared.load(previous)
            let nextArtwork = await SpatialArtworkLoader.shared.load(character)
            guard !Task.isCancelled else { isSwitching = false; return }
            // Both layers are depth-ready in their very first frame, at one continuous camera pose.
            sceneArtwork[previous] = previousArtwork
            sceneArtwork[character] = nextArtwork
            outgoingCharacter = store.selected
            switchProgress = 0
            select()
            // Mount both full-screen scenes before starting one shared transition clock.
            do { try await Task.sleep(for: .milliseconds(20)) }
            catch { outgoingCharacter = nil; switchProgress = 1; isSwitching = false; return }
            withAnimation(.easeInOut(duration: 0.72), completionCriteria: .logicallyComplete) {
                switchProgress = 1
            } completion: {
                outgoingCharacter = nil
                isSwitching = false
            }
        }
    }
    private func switchCharacter(_ delta: Int) {
        changeCharacter(store.selected.advanced(by: delta))
    }
    private func send() {
        guard !isSwitching else { return }
        speech.stop()
        inputFocused = false
        guard let client = currentClient else { store.errorMessage = ReadingError.invalidEndpoint.localizedDescription; return }
        if let visibleTurn { seenReveals.insert(visibleTurn) }
        visibleTurn = store.displayHistory.last?.id
        store.send(using: client, language: AnswerLanguage(rawValue: replyLanguage) ?? .english)
    }
}

/// Blur follows the same interpolated progress as the dissolve, with no separate phases.
private struct DreamDissolve: AnimatableModifier {
    var progress: Double
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    func body(content: Content) -> some View {
        content.blur(radius: 18 * sin(.pi * min(1, max(0, progress))), opaque: true)
    }
}

private struct ComposerGlass: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 28))
        } else {
            content.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
        }
    }
}

private struct SettingsView: View {
    @Binding var preview: Bool
    @Binding var effects: Bool
    @Binding var language: String
    let onClear: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var confirmClear = false
    @State private var apiKey = ""
    @State private var keyConfigured = DirectJEVClient.isConfigured
    @State private var keyMessage: String?
    private var copy: InterfaceCopy { .init(language: language) }
    var body: some View {
        NavigationStack {
            Form {
                Section(copy["Reply language"]) {
                    Picker(copy["Language"], selection: $language) {
                        ForEach(AnswerLanguage.allCases) { option in
                            Text(option.title).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("replyLanguagePicker")
                }
                Section(copy["Experience"]) {
                    Toggle(copy["Depth & dream effects"], isOn: $effects)
                    NavigationLink(copy["Spatial preview"]) { SpatialPreview() }
                        .accessibilityIdentifier("spatialPreview")
                }
                Section(copy["Connection"]) {
                    Toggle(copy["Sample replies"], isOn: $preview)
                    Text(copy[keyConfigured ? "API key saved on this device" : "Add your API key to begin"])
                        .font(.footnote).accessibilityIdentifier("jevAPIKeyStatus")
                    SecureField(copy[keyConfigured ? "Replace API key" : "API key"], text: $apiKey)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .accessibilityIdentifier("jevAPIKeyInput")
                    Button(copy[keyConfigured ? "Replace key" : "Save key"]) {
                        do { try JEVKeychain.save(apiKey); apiKey = ""; keyConfigured = true; keyMessage = nil }
                        catch { keyMessage = error.localizedDescription }
                    }
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("saveJEVAPIKey")
                    if keyConfigured {
                        Button(copy["Delete key"], role: .destructive) {
                            do { try JEVKeychain.delete(); apiKey = ""; keyConfigured = false; keyMessage = nil }
                            catch { keyMessage = error.localizedDescription }
                        }.accessibilityIdentifier("deleteJEVAPIKey")
                    }
                }
                Section {
                    Button(copy["Clear this conversation"], role: .destructive) { confirmClear = true }
                } footer: { Text(copy["Questions and replies stay in memory for this session. Your API key is stored in this device’s Keychain; character and display preferences are saved locally."]) }
                Section(copy["Artwork"]) {
                    Text(copy[Media.entranceVideoURL == nil
                         ? "Character artwork is installed. Entry dissolves into The Oracle when the curtain video is unavailable."
                         : "Character images and the curtain video are loaded from the app’s media folder. Missing images show a development scene."])
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle(copy["Settings"]).navigationBarTitleDisplayMode(.inline)
            .onDisappear { apiKey = "" }
            .alert(copy["Couldn’t update API key"], isPresented: Binding(get: { keyMessage != nil }, set: { if !$0 { keyMessage = nil } })) {
                Button(copy["OK"]) { keyMessage = nil }
            } message: { Text(copy[keyMessage ?? ""]) }
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(copy["Done"]) { dismiss() }.accessibilityIdentifier("settingsDone") } }
            .confirmationDialog(copy["Clear this character’s conversation?"], isPresented: $confirmClear, titleVisibility: .visible) {
                Button(copy["Clear conversation"], role: .destructive) { onClear() }
                Button(copy["Cancel"], role: .cancel) {}
            }
        }
    }
}

/// When the editor is idle, distinguish a tap from a sustained press before focusing it.
/// Once editing, the native text selection gestures remain available.
private struct HoldToSpeakSurface: UIViewRepresentable {
    let onTap: () -> Void
    let onBegin: () -> Void
    let onEnd: () -> Void
    let onCancel: () -> Void

    final class Surface: UIView {
        var actions: HoldToSpeakSurface?
        private var holding = false
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            isAccessibilityElement = false
            accessibilityElementsHidden = true
            let hold = UILongPressGestureRecognizer(target: self, action: #selector(press(_:)))
            hold.minimumPressDuration = 0.35
            hold.allowableMovement = 18
            addGestureRecognizer(hold)
            let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
            tap.require(toFail: hold)
            addGestureRecognizer(tap)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        @objc private func tap() { actions?.onTap() }
        @objc private func press(_ recognizer: UILongPressGestureRecognizer) {
            switch recognizer.state {
            case .began:
                holding = true
                actions?.onBegin()
            case .ended:
                guard holding else { return }
                holding = false
                actions?.onEnd()
            case .cancelled, .failed:
                cancel()
            default: break
            }
        }
        func cancel() {
            guard holding else { return }
            holding = false
            actions?.onCancel()
        }
    }
    func makeUIView(context: Context) -> Surface {
        let view = Surface()
        view.actions = self
        return view
    }
    func updateUIView(_ view: Surface, context: Context) { view.actions = self }
    static func dismantleUIView(_ view: Surface, coordinator: ()) {
        view.cancel()
        view.actions = nil
    }
}
