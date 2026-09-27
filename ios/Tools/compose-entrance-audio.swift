// Run from the repository root. Original movie and sound files are never modified.
import AVFoundation

let movieURL = URL(fileURLWithPath: "entrance.mov")
let soundURL = URL(fileURLWithPath: "Cymatics - ACCENT Amore - 117 BPM F Maj.wav")
let outputURL = URL(fileURLWithPath: "ios/JEV/Resources/Media/entrance-scored.mov")
let movie = AVURLAsset(url: movieURL), sound = AVURLAsset(url: soundURL)
let duration = try await movie.load(.duration)
let soundDuration = try await sound.load(.duration)
let sourceVideo = try await movie.loadTracks(withMediaType: .video).first!
let sourceAudio = try await sound.loadTracks(withMediaType: .audio).first!
let composition = AVMutableComposition()
let video = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
try video.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: sourceVideo, at: .zero)
video.preferredTransform = try await sourceVideo.load(.preferredTransform)
let audio = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
try audio.insertTimeRange(CMTimeRange(start: .zero, duration: CMTimeMinimum(duration, soundDuration)), of: sourceAudio, at: .zero)
let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
if FileManager.default.fileExists(atPath: outputURL.path) { try FileManager.default.removeItem(at: outputURL) }
try await exporter.export(to: outputURL, as: .mov)
let result = AVURLAsset(url: outputURL)
let outputDuration = try await result.load(.duration)
let tracks = try await result.loadTracks(withMediaType: .audio)
print("Movie: \(outputDuration.seconds)s; audio: \(soundDuration.seconds)s; audio tracks: \(tracks.count). Video exported without re-encoding.")
