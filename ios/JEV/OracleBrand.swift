import SwiftUI

/// Shared brand artwork and native control treatments; kept apart from scene rendering.
enum OracleBrand {
    static let name = "Jevons the Oracle"
    static let citron = Color(red: 228 / 255, green: 237 / 255, blue: 135 / 255)
    static let olive = Color(red: 52 / 255, green: 69 / 255, blue: 43 / 255)
}

struct OracleWordmark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Jevons").font(.system(.title2, design: .serif))
            Text("the Oracle").font(.system(.subheadline, design: .serif))
        }
        .foregroundStyle(OracleBrand.citron)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(OracleBrand.name)
    }
}

struct OraclePrimaryButton: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *), !reduceTransparency {
            content.buttonStyle(.glassProminent)
                .tint(OracleBrand.olive).foregroundStyle(OracleBrand.citron)
        } else {
            content.buttonStyle(.borderedProminent)
                .tint(OracleBrand.olive).foregroundStyle(OracleBrand.citron)
        }
    }
}

struct OracleControlGlass: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @ViewBuilder func body(content: Content) -> some View {
        if reduceTransparency {
            content.background(Palette.surface, in: Capsule())
        } else if #available(iOS 26.0, *) {
            content.glassEffect(.regular.interactive(), in: Capsule())
        } else {
            content.background(.regularMaterial, in: Capsule())
        }
    }
}
