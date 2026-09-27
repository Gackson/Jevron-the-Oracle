// Run from the repository root: swift ios/Tools/extract-entrance-poster.swift
import AVFoundation
import AppKit

let source = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "ios/JEV/Resources/Media/entrance.mov"
let destination = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "ios/JEV/Resources/Media/entrance-poster.png"
let generator = AVAssetImageGenerator(asset: AVURLAsset(url: URL(fileURLWithPath: source)))
generator.appliesPreferredTrackTransform = true
generator.requestedTimeToleranceBefore = .zero
generator.requestedTimeToleranceAfter = .zero
let (frame, _) = try await generator.image(at: .zero)
let bitmap = NSBitmapImageRep(cgImage: frame)
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: destination))
print("Extracted exact first frame: \(frame.width) × \(frame.height)")
