import SwiftUI
import CoreMotion

enum Media {
    static var entranceScoredVideoURL: URL? { url("entrance-scored", ext: "mov") }
    static var entranceVideoURL: URL? { entranceScoredVideoURL ?? url("entrance", ext: "mov") ?? url("entrance", ext: "mp4") }
    static func url(_ name: String, ext: String = "png") -> URL? {
        Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Media")
    }
    static func image(_ name: String) -> UIImage? {
        url(name).flatMap { UIImage(contentsOfFile: $0.path) }
    }
}

/// Normalized camera pose. A single amplitude limit bounds translation and perspective together.
struct SpatialPose: Equatable {
    var x: Double = 0
    var y: Double = 0
    static func from(roll: Double, pitch: Double) -> Self {
        guard roll.isFinite, pitch.isFinite else { return .init() }
        let limit = 10.0 * Double.pi / 180
        return .init(x: max(-1, min(1, roll / limit)), y: max(-1, min(1, pitch / limit)))
    }
    func smoothed(toward target: Self, elapsed: Double) -> Self {
        let factor = 1 - exp(-max(0, min(elapsed, 0.1)) / 0.085)
        return .init(x: x + (target.x - x) * factor, y: y + (target.y - y) * factor)
    }
}

@MainActor @Observable
final class SceneMotion {
    var pose = SpatialPose()
    private let manager = CMMotionManager()
    private var baseline: CMAttitude?
    private var lastTimestamp: TimeInterval?
    func start() {
        guard manager.isDeviceMotionAvailable, !manager.isDeviceMotionActive else { return }
        baseline = nil
        lastTimestamp = nil
        // A 60 Hz pose stream only invalidates this local scene, not the text or composer.
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            guard let baseline = self.baseline else {
                self.baseline = motion.attitude.copy() as? CMAttitude
                self.lastTimestamp = motion.timestamp
                return
            }
            guard let relative = motion.attitude.copy() as? CMAttitude else { return }
            relative.multiply(byInverseOf: baseline)
            let target = SpatialPose.from(roll: relative.roll, pitch: relative.pitch)
            let elapsed = motion.timestamp - (self.lastTimestamp ?? motion.timestamp - 1 / 60)
            self.lastTimestamp = motion.timestamp
            self.pose = self.pose.smoothed(toward: target, elapsed: elapsed)
        }
    }
    func stop() {
        manager.stopDeviceMotionUpdates()
        baseline = nil
        lastTimestamp = nil
        pose = .init()
    }
}

struct OracleScene: View {
    let character: OracleCharacter
    let effectsEnabled: Bool
    let motionActive: Bool
    let previewPose: SpatialPose?
    let onPrepared: ((SpatialArtwork.Mode, String) -> Void)?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var motion: SceneMotion
    private let ownsMotion: Bool
    @State private var artwork: SpatialArtwork

    init(character: OracleCharacter, effectsEnabled: Bool, motionActive: Bool = true,
         previewPose: SpatialPose? = nil, motionSource: SceneMotion? = nil,
         preparedArtwork: SpatialArtwork? = nil, onPrepared: ((SpatialArtwork.Mode, String) -> Void)? = nil) {
        self.character = character
        self.effectsEnabled = effectsEnabled
        self.motionActive = motionActive
        self.previewPose = previewPose
        self.onPrepared = onPrepared
        ownsMotion = motionSource == nil
        _motion = State(initialValue: motionSource ?? SceneMotion())
        _artwork = State(initialValue: preparedArtwork ?? SpatialArtwork.initial(character))
    }

    private var pose: SpatialPose {
        guard effectsEnabled && !reduceMotion && artwork.mode == .depth else { return .init() }
        return previewPose ?? motion.pose
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Palette.canvas
                if let master = artwork.master {
                    let scale = max(geometry.size.width / artwork.canvas.width, geometry.size.height / artwork.canvas.height) * 1.20
                    let canvasSize = CGSize(width: artwork.canvas.width * scale, height: artwork.canvas.height * scale)
                    Image(uiImage: master).resizable()
                        .frame(width: canvasSize.width, height: canvasSize.height)
                        .layerEffect(ShaderLibrary.sceneDepth(
                            .float2(canvasSize), .float2(Float(pose.x), Float(pose.y)),
                            .image(Image(uiImage: artwork.depth ?? master))),
                            maxSampleOffset: CGSize(width: 40, height: 26),
                            isEnabled: artwork.mode == .depth && effectsEnabled && !reduceMotion)
                        // One shared projective tilt for the entire room, never separate object planes.
                        .rotation3DEffect(.degrees(-pose.y * 2.2), axis: (x: 1, y: 0, z: 0), perspective: 0.4)
                        .rotation3DEffect(.degrees(pose.x * 3.2), axis: (x: 0, y: 1, z: 0), perspective: 0.4)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                } else {
                    DevelopmentScene(character: character)
                }
            }
            .compositingGroup()
            .layerEffect(ShaderLibrary.dreamLens(.float2(geometry.size), .float(0)),
                         maxSampleOffset: CGSize(width: 12, height: 0), isEnabled: effectsEnabled && !reduceMotion)
            .layerEffect(ShaderLibrary.dreamLens(.float2(geometry.size), .float(1)),
                         maxSampleOffset: CGSize(width: 50, height: 50), isEnabled: effectsEnabled && !reduceMotion)
            .overlay {
                LinearGradient(colors: [Palette.canvas.opacity(0.15), .clear, Palette.canvas.opacity(0.30), Palette.canvas.opacity(0.85)],
                               startPoint: .top, endPoint: .bottom)
            }
            .clipped()
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .task(id: character) {
            let prepared = await SpatialArtworkLoader.shared.load(character)
            guard !Task.isCancelled else { return }
            artwork = prepared
            onPrepared?(prepared.mode, prepared.detail)
        }
        .onAppear { updateMotion() }
        .onDisappear { if ownsMotion { motion.stop() } }
        .onChange(of: scenePhase) { _, _ in updateMotion() }
        .onChange(of: effectsEnabled) { _, _ in updateMotion() }
        .onChange(of: motionActive) { _, _ in updateMotion() }
        .onChange(of: reduceMotion) { _, _ in updateMotion() }
    }

    private func updateMotion() {
        // Shared motion belongs to the conversation, never to a transient character view.
        guard ownsMotion else { return }
        if effectsEnabled && motionActive && previewPose == nil && !reduceMotion && scenePhase == .active { motion.start() }
        else { motion.stop() }
    }
}

struct DevelopmentScene: View {
    let character: OracleCharacter
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RadialGradient(colors: [Palette.accent(character).opacity(0.26), Palette.canvas], center: .init(x: 0.5, y: 0.35), startRadius: 15, endRadius: geometry.size.height * 0.6)
                switch character {
                case .stone:
                    Rectangle().fill(LinearGradient(colors: [Color(white: 0.18), Color(white: 0.055)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geometry.size.width * 0.27, height: geometry.size.height * 0.37)
                        .overlay(alignment: .leading) { Rectangle().fill(Palette.accent(character).opacity(0.4)).frame(width: 1) }
                        .shadow(color: Palette.accent(character).opacity(0.12), radius: 36, x: -14, y: 0)
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.38)
                case .oracle, .jester:
                    Image(systemName: character == .oracle ? "door.left.hand.open" : "theatermasks")
                        .font(.system(size: 100, weight: .ultraLight))
                        .foregroundStyle(Palette.accent(character).opacity(0.35))
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.36)
                case .fool:
                    // Explicit development placeholder until a dedicated character master is supplied.
                    Image(systemName: "sparkle")
                        .font(.system(size: 90, weight: .ultraLight))
                        .foregroundStyle(Palette.accent(character).opacity(0.35))
                        .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.36)
                }
            }
        }
    }
}
