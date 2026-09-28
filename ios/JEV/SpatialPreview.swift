import SwiftUI

/// The same compositor with a controllable pose, for inspecting depth without sensor hardware.
struct SpatialPreview: View {
    @AppStorage("replyLanguage") private var language = "en"
    private var copy: InterfaceCopy { .init(language: language) }
    @State private var character: OracleCharacter = .oracle
    @State private var horizontal = 0.0
    @State private var vertical = 0.0
    @State private var mode = "Preparing scene depth…"
    @State private var detail = ""
    @State private var showControls = true

    var body: some View {
        ZStack {
            OracleScene(character: character, effectsEnabled: true, motionActive: false,
                        previewPose: .init(x: horizontal, y: vertical)) { state, information in
                mode = state.rawValue
                detail = information
            }
            .id(character)
            VStack {
                Picker(copy["Character"], selection: $character) {
                    ForEach(OracleCharacter.allCases) { Text($0.name).tag($0) }
                }.pickerStyle(.segmented).padding(.horizontal, 20)
                Button(copy[showControls ? "Hide controls" : "Show controls"]) { showControls.toggle() }
                    .font(.footnote).padding(10)
                    .background(Palette.canvas.opacity(0.85), in: Capsule())
                    .accessibilityIdentifier("toggleSpatialControls")
                Spacer()
                if showControls { VStack(spacing: 14) {
                    Text(copy[mode]).font(.footnote).accessibilityIdentifier("spatialMode")
                    Text(copy[detail]).font(.caption2).foregroundStyle(Palette.secondary).multilineTextAlignment(.center)
                    HStack {
                        Image(systemName: "arrow.left.and.right").font(.system(size: 16)).frame(width: 24)
                        Slider(value: $horizontal, in: -1...1).accessibilityLabel(copy["Horizontal tilt"]).accessibilityIdentifier("horizontalTilt")
                    }
                    HStack {
                        Image(systemName: "arrow.up.and.down").font(.system(size: 16)).frame(width: 24)
                        Slider(value: $vertical, in: -1...1).accessibilityLabel(copy["Vertical tilt"]).accessibilityIdentifier("verticalTilt")
                    }
                    Button(copy["Center"]) { horizontal = 0; vertical = 0 }
                    Text(copy["Move the sliders to inspect the same depth effect used when tilting your phone."])
                        .font(.caption).foregroundStyle(Palette.secondary).multilineTextAlignment(.center)
                }
                .padding(20).background(Palette.canvas.opacity(0.94), in: RoundedRectangle(cornerRadius: 24))
                .padding(20)
                }
            }
        }
        .foregroundStyle(Palette.ink)
        .navigationTitle(copy["Spatial preview"]).navigationBarTitleDisplayMode(.inline)
        .onChange(of: character) { _, _ in mode = "Preparing scene depth…"; detail = ""; horizontal = 0; vertical = 0 }
    }
}
