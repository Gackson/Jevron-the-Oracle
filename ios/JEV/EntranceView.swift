import SwiftUI
import AVFoundation
import Combine

struct EntranceView: View {
    static let dissolveDuration = 0.65
    private static let dissolveLead = 0.70
    let onEnter: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var player: AVPlayer?
    @State private var opening = false
    @State private var didFinish = false
    @State private var fallbackTask: Task<Void, Never>?
    @State private var videoReady = false
    @State private var playbackObserver: Any?
    @State private var audioTracks: [AVAssetTrack] = []
    @State private var audioSessionActive = false
    private let closedImage = Media.image("entrance-poster") ?? Media.image("entrance-closed")

    var body: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()
            GeometryReader { geometry in
                ZStack {
                    if !videoReady, let closedImage {
                        Image(uiImage: closedImage).resizable().scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    } else if closedImage == nil && !videoReady {
                        DevelopmentCurtain().accessibilityHidden(true)
                    }
                    if let player {
                        EntrancePlayer(player: player, ready: $videoReady)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .opacity(videoReady ? 1 : 0)
                            .accessibilityIdentifier("entranceVideo")
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
            }
            .ignoresSafeArea()
            LinearGradient(colors: [.clear, Palette.canvas.opacity(0.88)], startPoint: .center, endPoint: .bottom)
                .ignoresSafeArea().opacity(opening ? 0 : 1)
            GeometryReader { geometry in
            ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                OracleWordmark()
                if closedImage == nil {
                    Text("ARTWORK PREVIEW").font(.caption2).tracking(2).padding(.top, 12).foregroundStyle(Palette.secondary)
                }
                Spacer(minLength: 60)
                Text("A few words.\nA meaning\nof your own.")
                    .font(.system(.largeTitle, design: .serif)).fontWeight(.regular).lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("welcomeTitle")
                Text("Bring a question.\nFour oracles. Four ways to see.")
                    .font(.body).lineSpacing(4).foregroundStyle(Palette.secondary).padding(.top, 22)
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: enter) {
                    HStack {
                        Text("Enter").fontWeight(.medium)
                        Spacer()
                        Image(systemName: "arrow.right").font(.system(size: 20))
                    }
                    .padding(.vertical, 12).padding(.horizontal, 14)
                }
                .modifier(OraclePrimaryButton())
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .accessibilityIdentifier("enterButton")
                .padding(.top, 36)
            }
            .padding(.horizontal, 30).padding(.top, 22).padding(.bottom, 26)
            .frame(minHeight: geometry.size.height, alignment: .topLeading)
            }
            .scrollIndicators(.hidden)
            }
            .foregroundStyle(Palette.ink).opacity(opening ? 0 : 1).allowsHitTesting(!opening)
            .accessibilityHidden(opening)
            if opening {
                VStack { HStack { Spacer(); Button("Skip", action: finish).padding(16).accessibilityIdentifier("skipEntrance") }; Spacer() }
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(TapGesture().onEnded { if !opening { enter() } })
        .allowsHitTesting(!didFinish)
        .task {
            guard let movie = preparePlayer() else { return }
            if let asset = movie.currentItem?.asset {
                audioTracks = (try? await asset.loadTracks(withMediaType: .audio)) ?? []
            }
            // The same aspect-fill layer shows the paused first frame and then plays in place.
            await movie.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            if opening { movie.play() }
            _ = await SpatialArtworkLoader.shared.load(.oracle)
        }
        .onReceive(NotificationCenter.default.publisher(for: AVPlayerItem.didPlayToEndTimeNotification)) { notification in
            if let item = notification.object as? AVPlayerItem, item === player?.currentItem { finish() }
        }
        .onReceive(NotificationCenter.default.publisher(for: AVPlayerItem.failedToPlayToEndTimeNotification)) { notification in
            if let item = notification.object as? AVPlayerItem, item === player?.currentItem { finish() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active && opening && !didFinish {
                activateSound()
                player?.play()
            } else { player?.pause() }
        }
        .onDisappear {
            player?.pause()
            if let playbackObserver { player?.removeTimeObserver(playbackObserver) }
            playbackObserver = nil
            fallbackTask?.cancel()
            if audioSessionActive {
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                audioSessionActive = false
            }
        }
    }

    private func activateSound() {
        guard Media.entranceScoredVideoURL != nil else { return }
        do {
            let audio = AVAudioSession.sharedInstance()
            // A brief ambient cue respects silent mode and coexists with the user's music.
            try audio.setCategory(.ambient, mode: .default)
            try audio.setActive(true)
            audioSessionActive = true
            player?.isMuted = false
        } catch {
            // The visual entrance remains usable if another audio session prevents playback.
            player?.isMuted = true
        }
    }

    private func preparePlayer() -> AVPlayer? {
        if let player { return player }
        guard let url = Media.entranceVideoURL else { return nil }
        let movie = AVPlayer(url: url)
        movie.isMuted = true
        movie.actionAtItemEnd = .pause
        player = movie
        // Follow playback time, including pauses, rather than a wall-clock delay.
        playbackObserver = movie.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.05, preferredTimescale: 600), queue: .main) { [weak movie] time in
            guard let duration = movie?.currentItem?.duration.seconds, duration.isFinite, duration > 0,
                  time.seconds >= max(0, duration - Self.dissolveLead) else { return }
            Task { @MainActor in
                guard opening && !didFinish else { return }
                finish()
            }
        }
        return movie
    }

    private func enter() {
        guard !opening else { return }
        if reduceMotion { finish(); return }
        withAnimation(.easeOut(duration: 0.22)) { opening = true }
        guard let movie = preparePlayer() else { finish(); return }
        activateSound()
        movie.play()
        // Guard decode/startup failure, without truncating a valid movie by its duration.
        fallbackTask = Task {
            try? await Task.sleep(for: .seconds(10))
            guard !Task.isCancelled, !videoReady, scenePhase == .active else { return }
            finish()
        }
    }
    private func finish() {
        guard !didFinish else { return }
        didFinish = true
        // Keep the single audio/video timeline playing under the fade, including when skipped.
        if let player, let item = player.currentItem, !audioTracks.isEmpty {
            let mix = AVMutableAudioMix()
            let range = CMTimeRange(start: player.currentTime(), duration: CMTime(seconds: Self.dissolveDuration, preferredTimescale: 600))
            mix.inputParameters = audioTracks.map { track in
                let parameters = AVMutableAudioMixInputParameters(track: track)
                parameters.setVolumeRamp(fromStartVolume: 1, toEndVolume: 0, timeRange: range)
                return parameters
            }
            item.audioMix = mix
        }
        fallbackTask?.cancel()
        onEnter()
    }
}

private struct EntrancePlayer: UIViewRepresentable {
    let player: AVPlayer
    @Binding var ready: Bool
    class Surface: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        var observation: NSKeyValueObservation?
    }
    func makeUIView(context: Context) -> Surface {
        let view = Surface()
        view.backgroundColor = .clear
        let layer = view.layer as! AVPlayerLayer
        layer.videoGravity = .resizeAspectFill
        layer.player = player
        view.observation = layer.observe(\.isReadyForDisplay, options: [.initial, .new]) { layer, _ in
            let displayed = layer.isReadyForDisplay
            Task { @MainActor in ready = displayed }
        }
        return view
    }
    func updateUIView(_ view: Surface, context: Context) { (view.layer as? AVPlayerLayer)?.player = player }
    static func dismantleUIView(_ view: Surface, coordinator: ()) {
        view.observation = nil
        (view.layer as? AVPlayerLayer)?.player = nil
    }
}

/// Layout-only beaded curtain until the approved still is supplied.
private struct DevelopmentCurtain: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RadialGradient(colors: [Color(red: 0.27, green: 0.20, blue: 0.12), Palette.canvas], center: .init(x: 0.5, y: 0.3), startRadius: 0, endRadius: geometry.size.height * 0.7)
                Canvas { context, size in
                    for column in 0..<27 {
                        let x = CGFloat(column) * size.width / 26
                        var thread = Path()
                        thread.move(to: CGPoint(x: x, y: 0))
                        thread.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(thread, with: .color(Palette.secondary.opacity(0.09)), lineWidth: 0.5)
                        for row in 0..<55 {
                            let y = CGFloat(row) * 19 + CGFloat(column % 3) * 4
                            let bead = Path(ellipseIn: CGRect(x: x - 3, y: y, width: 6, height: 10))
                            context.fill(bead, with: .color(Palette.accent(.oracle).opacity(Double((column + row) % 4 + 1) * 0.07)))
                        }
                    }
                }
            }
        }
    }
}
