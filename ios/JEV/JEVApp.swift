import SwiftUI

@main
struct JEVApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                .tint(OracleBrand.citron)
        }
    }
}

enum Palette {
    static let canvas = Color(red: 0.047, green: 0.052, blue: 0.049)
    static let ink = Color(red: 0.93, green: 0.90, blue: 0.83)
    static let secondary = Color(red: 0.72, green: 0.70, blue: 0.65)
    static let surface = Color(red: 0.12, green: 0.13, blue: 0.12)
    static func accent(_ character: OracleCharacter) -> Color {
        switch character {
        case .oracle: return Color(red: 0.76, green: 0.60, blue: 0.40)
        case .stone: return Color(red: 0.60, green: 0.70, blue: 0.75)
        case .jester: return Color(red: 0.69, green: 0.36, blue: 0.38)
        case .fool: return Color(red: 0.64, green: 0.62, blue: 0.76)
        }
    }
}
