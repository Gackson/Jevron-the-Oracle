import Foundation
import UIKit
import CryptoKit

/// Offline model-derived inverse depth. Every sample belongs to the original full image.
struct SceneDepth {
    let width: Int
    let height: Int
    let values: [Float]
    init(data: Data, source: Data) throws {
        guard data.count >= 48, String(data: data.prefix(8), encoding: .utf8) == "JEVDEP01" else { throw DepthError.invalid }
        func integer(_ start: Int) -> Int { (0..<4).reduce(0) { $0 | (Int(data[start + $1]) << ($1 * 8)) } }
        let w = integer(8), h = integer(12)
        guard w > 1, h > 1, w <= 2048, h <= 2048, data.count == 48 + w * h * 2,
              data.subdata(in: 16..<48) == Data(SHA256.hash(data: source)) else { throw DepthError.invalid }
        width = w; height = h
        values = (0..<w*h).map { Float(UInt16(data[48+$0*2]) | UInt16(data[49+$0*2]) << 8) / 65535 }
    }
    func image() -> UIImage? {
        // Linear gray keeps numerical inverse depth linear through SwiftUI's texture upload.
        let bytes = values.map { UInt8(($0 * 255).rounded()) }
        guard let provider = CGDataProvider(data: Data(bytes) as CFData),
              let image = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 8,
                                  bytesPerRow: width, space: CGColorSpace(name: CGColorSpace.linearGray)!,
                                  bitmapInfo: [], provider: provider, decode: nil,
                                  shouldInterpolate: true, intent: .defaultIntent) else { return nil }
        return UIImage(cgImage: image)
    }
    enum DepthError: Error { case invalid }
}

struct SpatialArtwork {
    enum Mode: String { case depth = "Continuous scene depth", flat = "Still image", missing = "Artwork missing" }
    let master: UIImage?
    let depth: UIImage?
    let mode: Mode
    let detail: String
    var canvas: CGSize { master?.size ?? CGSize(width: 853, height: 1844) }
    static func initial(_ character: OracleCharacter) -> Self {
        let image = Media.image("\(character.rawValue)-master")
        return .init(master: image, depth: nil, mode: image == nil ? .missing : .flat, detail: "Preparing scene depth…")
    }
}

actor SpatialArtworkLoader {
    static let shared = SpatialArtworkLoader()
    private var cache: [OracleCharacter: SpatialArtwork] = [:]
    func load(_ character: OracleCharacter) -> SpatialArtwork {
        if let cached = cache[character] { return cached }
        let initial = SpatialArtwork.initial(character)
        guard let source = Media.url("\(character.rawValue)-master"),
              let url = Media.url("\(character.rawValue)-scene", ext: "depth"),
              let data = try? Data(contentsOf: url), let rgb = try? Data(contentsOf: source),
              let field = try? SceneDepth(data: data, source: rgb), let depth = field.image() else {
            return .init(master: initial.master, depth: nil, mode: initial.mode, detail: initial.master == nil ? "Dedicated artwork is not installed. Development preview only." : "No matching depth data. The complete image stays still.")
        }
        let result = SpatialArtwork(master: initial.master, depth: depth, mode: .depth,
                                    detail: "One connected scene • original contact edges and shadows")
        cache[character] = result
        return result
    }
}
