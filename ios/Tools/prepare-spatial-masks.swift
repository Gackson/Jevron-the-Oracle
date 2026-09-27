// Produces segmentation DATA, not a repainted or resampled subject image.
// Usage: swift prepare-spatial-masks.swift <Media-directory>
import Foundation
import Vision
import CoreVideo
import CryptoKit

let folder = URL(fileURLWithPath: CommandLine.arguments[1])
for id in ["oracle", "stone", "jester"] {
    let source = folder.appendingPathComponent("\(id)-master.png")
    let bytes = try Data(contentsOf: source)
    let request = VNGenerateForegroundInstanceMaskRequest()
    let handler = VNImageRequestHandler(url: source)
    try handler.perform([request])
    guard let observation = request.results?.first, !observation.allInstances.isEmpty else {
        fatalError("No foreground for \(id)")
    }
    let mask = try observation.generateScaledMaskForImage(forInstances: observation.allInstances, from: handler)
    CVPixelBufferLockBaseAddress(mask, .readOnly)
    let width = CVPixelBufferGetWidth(mask), height = CVPixelBufferGetHeight(mask)
    let stride = CVPixelBufferGetBytesPerRow(mask)
    let format = CVPixelBufferGetPixelFormatType(mask)
    let pointer = CVPixelBufferGetBaseAddress(mask)!
    var output = Data("JEVMSK01".utf8)
    for dimension in [UInt32(width), UInt32(height)] {
        var little = dimension.littleEndian
        withUnsafeBytes(of: &little) { output.append(contentsOf: $0) }
    }
    output.append(contentsOf: SHA256.hash(data: bytes))
    var nonzero = 0
    for y in 0..<height {
        let row = pointer.advanced(by: y * stride)
        for x in 0..<width {
            let value: UInt8
            if format == kCVPixelFormatType_OneComponent32Float {
                value = UInt8(max(0, min(255, (row.assumingMemoryBound(to: Float.self)[x] * 255).rounded())))
            } else if format == kCVPixelFormatType_OneComponent8 {
                value = row.assumingMemoryBound(to: UInt8.self)[x]
            } else { fatalError("Unsupported mask format \(format)") }
            output.append(value)
            if value > 127 { nonzero += 1 }
        }
    }
    CVPixelBufferUnlockBaseAddress(mask, .readOnly)
    let coverage = Double(nonzero) / Double(width * height)
    guard coverage > 0.02 && coverage < 0.85 else { fatalError("Invalid foreground coverage") }
    try output.write(to: folder.appendingPathComponent("\(id)-foreground-v2.mask"), options: .atomic)
    print("\(id): \(width)x\(height), foreground \(Int(coverage*100))%, SHA256-bound mask data")
}
