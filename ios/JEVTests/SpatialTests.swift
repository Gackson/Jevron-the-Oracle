import XCTest
import AVFoundation
@testable import JEV

final class SpatialTests: XCTestCase {
    func testEntranceSoundtrackStartsWithVideoAndPreservesDuration() async throws {
        let original = AVURLAsset(url: try XCTUnwrap(Media.url("entrance", ext: "mov")))
        let combined = AVURLAsset(url: try XCTUnwrap(Media.entranceVideoURL))
        XCTAssertEqual(Media.entranceVideoURL, Media.entranceScoredVideoURL)
        let originalDuration = try await original.load(.duration)
        let combinedDuration = try await combined.load(.duration)
        XCTAssertEqual(combinedDuration.seconds, originalDuration.seconds, accuracy: 0.001)
        let tracks = try await combined.loadTracks(withMediaType: .audio)
        XCTAssertEqual(tracks.count, 1)
        let audio = try XCTUnwrap(tracks.first)
        let range = try await audio.load(.timeRange)
        XCTAssertEqual(range.start.seconds, 0, accuracy: 0.001)
        XCTAssertEqual(range.duration.seconds, 4.102562, accuracy: 0.01)
        let videos = try await combined.loadTracks(withMediaType: .video)
        let video = try XCTUnwrap(videos.first)
        let size = try await video.load(.naturalSize)
        XCTAssertEqual(size, CGSize(width: 720, height: 1280))
    }

    func testPoseClampsAndRejectsInvalidSensorValues() {
        XCTAssertEqual(SpatialPose.from(roll: 9, pitch: -9), .init(x: 1, y: -1))
        XCTAssertEqual(SpatialPose.from(roll: .nan, pitch: 0), .init())
        XCTAssertEqual(SpatialPose.from(roll: 0, pitch: .infinity), .init())
    }

    func testCharacterNavigationWrapsInBothDirections() {
        let characters = OracleCharacter.allCases
        XCTAssertEqual(characters.first!.advanced(by: -1), characters.last!)
        XCTAssertEqual(characters.last!.advanced(by: 1), characters.first!)
        for character in characters {
            XCTAssertEqual(character.advanced(by: characters.count), character)
            XCTAssertTrue(character.name.hasPrefix("The "))
        }
        XCTAssertEqual(OracleCharacter.oracle.name, "The Oracle")
    }

    func testSmoothingIsFrameRateIndependent() {
        let target = SpatialPose(x: 1, y: -0.5)
        var thirty = SpatialPose()
        var sixty = SpatialPose()
        for _ in 0..<30 { thirty = thirty.smoothed(toward: target, elapsed: 1.0 / 30) }
        for _ in 0..<60 { sixty = sixty.smoothed(toward: target, elapsed: 1.0 / 60) }
        XCTAssertEqual(thirty.x, sixty.x, accuracy: 0.000001)
        XCTAssertEqual(thirty.y, sixty.y, accuracy: 0.000001)
        XCTAssertLessThan(sixty.x, 1)
    }

    func testAllScenesUseContinuousDepthAndOriginalImage() async throws {
        for character in OracleCharacter.allCases {
            let artwork = await SpatialArtworkLoader.shared.load(character)
            XCTAssertEqual(artwork.mode, .depth, "\(character): \(artwork.detail)")
            XCTAssertNotNil(artwork.master)
            XCTAssertNotNil(artwork.depth)
        }
    }

    func testDepthRejectsStaleArtworkAndTruncatedData() throws {
        let data = try Data(contentsOf: XCTUnwrap(Media.url("oracle-scene", ext: "depth")))
        let source = try Data(contentsOf: XCTUnwrap(Media.url("oracle-master")))
        let decoded = try SceneDepth(data: data, source: source)
        XCTAssertEqual(decoded.width, 518)
        XCTAssertEqual(decoded.height, 392)
        XCTAssertThrowsError(try SceneDepth(data: data, source: Data("different image".utf8)))
        XCTAssertThrowsError(try SceneDepth(data: Data(data.prefix(30)), source: source))
    }

    func testDepthWarpCannotFoldOrTearAtMaximumDiagonalTilt() throws {
        for character in OracleCharacter.allCases {
            let data = try Data(contentsOf: XCTUnwrap(Media.url("\(character.rawValue)-scene", ext: "depth")))
            let source = try Data(contentsOf: XCTUnwrap(Media.url("\(character.rawValue)-master")))
            let field = try SceneDepth(data: data, source: source)
            var maxDX: Float = 0, maxDY: Float = 0
            for y in 0..<field.height { for x in 0..<field.width {
                let v = field.values[y * field.width + x]
                XCTAssertTrue(v.isFinite && (0...1).contains(v))
                if x > 0 { maxDX = max(maxDX, abs(v - field.values[y * field.width + x - 1])) }
                if y > 0 { maxDY = max(maxDY, abs(v - field.values[(y - 1) * field.width + x])) }
            }}
            // Match shader UV baseline. Include 8-bit upload quantization, then bilinear sampling.
            let contraction = (maxDX + 1/255) * Float(field.width) * 0.050
                            + (maxDY + 1/255) * Float(field.height) * 0.020
            XCTAssertLessThan(contraction, 0.85, "\(character) may fold at a depth edge")
        }
    }
}
