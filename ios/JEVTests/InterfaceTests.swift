import XCTest
import UIKit
import CoreText
@testable import JEV

final class InterfaceTests: XCTestCase {
    func testChineseSerifIsInstalledAndContainsChineseGlyphs() throws {
        let font = try XCTUnwrap(UIFont(name: OracleTypography.chineseSerifName, size: 22))
        let resolved = CTFontCreateForString(font as CTFont, "静候回响，碑声未至。" as CFString, CFRange(location: 0, length: 10))
        XCTAssertEqual(CTFontCopyPostScriptName(resolved) as String, OracleTypography.chineseSerifName)
        var characters = Array("静候回响，碑声未至。".utf16)
        var glyphs = Array(repeating: CGGlyph(0), count: characters.count)
        XCTAssertTrue(CTFontGetGlyphsForCharacters(font as CTFont, &characters, &glyphs, characters.count))
        XCTAssertFalse(glyphs.contains(0))
    }

    func testInterfaceLanguageDoesNotChangeNamesOrPriorAnswerContent() {
        let copy = InterfaceCopy(language: "zh-Hans")
        for character in OracleCharacter.allCases {
            XCTAssertEqual(copy[character.name], character.name)
            XCTAssertTrue(ReplyText.containsChinese(copy[character.invitation]))
            XCTAssertTrue(ReplyText.containsChinese(copy[character.rule]))
        }
        XCTAssertEqual(copy[OracleBrand.name], OracleBrand.name)
        let turn = ReadingTurn(id: UUID(), question: "Why?", answer: "An earlier English answer.", date: .now,
                               isPreview: false, origin: "authored_fallback", generationStopReason: "deadline", locale: "en")
        XCTAssertEqual(turn.fallbackLabel(language: "zh-Hans"), "回答超时 · 角色备用回复")
        XCTAssertEqual(turn.answer, "An earlier English answer.")
        XCTAssertEqual(InterfaceCopy(language: "en")["Settings"], "Settings")
    }
}
