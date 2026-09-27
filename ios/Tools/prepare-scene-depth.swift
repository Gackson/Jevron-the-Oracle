// Offline numeric depth estimation. Does not repaint, cut out, or regenerate RGB artwork.
// Usage: swift prepare-scene-depth.swift MODEL.mlpackage MEDIA_DIR OUTPUT_DIR [CHARACTER ...]
import Foundation
import CoreML
import CoreImage
import ImageIO
import CryptoKit
import UniformTypeIdentifiers

let args = CommandLine.arguments
let compiled = try MLModel.compileModel(at: URL(fileURLWithPath: args[1]))
let config = MLModelConfiguration()
config.computeUnits = .all
let model = try MLModel(contentsOf: compiled, configuration: config)
let input = model.modelDescription.inputDescriptionsByName.first { $0.value.type == .image }!
let shape = input.value.imageConstraint!
let context = CIContext()
let output = URL(fileURLWithPath: args[3])
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
let characters = args.count > 4 ? Array(args.dropFirst(4)) : ["oracle", "stone", "jester", "fool"]
for name in characters {
    let url = URL(fileURLWithPath: args[2]).appendingPathComponent("\(name)-master.png")
    let data = try Data(contentsOf: url)
    let image = CIImage(data: data)!
    let resized = image.transformed(by: CGAffineTransform(scaleX: CGFloat(shape.pixelsWide) / image.extent.width,
                                                          y: CGFloat(shape.pixelsHigh) / image.extent.height))
    var buffer: CVPixelBuffer?
    CVPixelBufferCreate(nil, shape.pixelsWide, shape.pixelsHigh, kCVPixelFormatType_32BGRA,
                        [kCVPixelBufferIOSurfacePropertiesKey: [:]] as CFDictionary, &buffer)
    context.render(resized, to: buffer!)
    let result = try model.prediction(from: MLDictionaryFeatureProvider(dictionary: [input.key: MLFeatureValue(pixelBuffer: buffer!)]))
    let feature = result.featureValue(for: result.featureNames.first!)!
    let predicted = feature.imageBufferValue!
    let width = CVPixelBufferGetWidth(predicted), height = CVPixelBufferGetHeight(predicted)
    CVPixelBufferLockBaseAddress(predicted, .readOnly)
    let format = CVPixelBufferGetPixelFormatType(predicted)
    guard format == kCVPixelFormatType_OneComponent32Float || format == kCVPixelFormatType_OneComponent16Half else { fatalError("Unexpected depth pixel format: \(format)") }
    let base = CVPixelBufferGetBaseAddress(predicted)!
    let stride = CVPixelBufferGetBytesPerRow(predicted)
    var floats = [Float](repeating: 0, count: width * height)
    for y in 0..<height {
        let row = base.advanced(by: y * stride)
        for x in 0..<width {
            floats[y * width + x] = format == kCVPixelFormatType_OneComponent32Float
                ? row.assumingMemoryBound(to: Float.self)[x]
                : Float(Float16(bitPattern: row.assumingMemoryBound(to: UInt16.self)[x]))
        }
    }
    CVPixelBufferUnlockBaseAddress(predicted, .readOnly)
    let sorted = floats.sorted(); let low = sorted[sorted.count / 100], high = sorted[sorted.count * 99 / 100]
    floats = floats.map { max(0, min(1, ($0 - low) / max(0.0001, high - low))) }
    // Smooth only the numeric geometry. The original RGB edges stay untouched.
    // A bounded Lipschitz field prevents inverse reprojection from folding at silhouettes.
    for _ in 0..<3 {
        var filtered = floats
        for y in 1..<height-1 { for x in 1..<width-1 {
            let i = y * width + x
            filtered[i] = (floats[i] * 4 + floats[i-1] + floats[i+1] + floats[i-width] + floats[i+width]) / 8
        }}
        floats = filtered
    }
    // Symmetric slope projection preserves depth at contacts without eroding subjects.
    let slope: Float = 0.012
    for _ in 0..<320 {
        for y in 0..<height { for x in 0..<width {
            let i = y * width + x
            for j in [x + 1 < width ? i + 1 : i, y + 1 < height ? i + width : i] where j != i {
                let diff = floats[i] - floats[j]
                if abs(diff) > slope {
                    let correction = (abs(diff) - slope) * (diff > 0 ? Float(0.5) : Float(-0.5))
                    floats[i] -= correction; floats[j] += correction
                }
            }
        }}
    }
    var bytes = Data("JEVDEP01".utf8)
    for dimension in [width,height] { var v = UInt32(dimension).littleEndian; withUnsafeBytes(of: &v) { bytes.append(contentsOf: $0) } }
    bytes.append(contentsOf: SHA256.hash(data: data))
    // Store UInt16 little-endian relative inverse depth; white means near.
    for value in floats { var v = UInt16((value * 65535).rounded()).littleEndian; withUnsafeBytes(of: &v) { bytes.append(contentsOf: $0) } }
    try bytes.write(to: output.appendingPathComponent("\(name)-scene.depth"))
    // Human-inspectable visualization of model-derived numeric data, not replacement RGB art.
    let gray = floats.map { UInt8(($0 * 255).rounded()) }
    let provider = CGDataProvider(data: Data(gray) as CFData)!
    let preview = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: width,
                          space: CGColorSpaceCreateDeviceGray(), bitmapInfo: [], provider: provider,
                          decode: nil, shouldInterpolate: true, intent: .defaultIntent)!
    let dest = CGImageDestinationCreateWithURL(output.appendingPathComponent("\(name)-depth-preview.png") as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, preview, nil); CGImageDestinationFinalize(dest)
    print("\(name): \(width)x\(height), native Core ML depth, source bound SHA256")
}
