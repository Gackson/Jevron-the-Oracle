import AppKit
import CoreText

// Outline the system Baskerville O once: no font dependency in the shipped artwork.
let root = URL(fileURLWithPath: CommandLine.arguments[1])
let font = CTFontCreateWithName("Baskerville" as CFString, 820, nil)
var character: UniChar = 79
var glyph: CGGlyph = 0
precondition(CTFontGetGlyphsForCharacters(font, &character, &glyph, 1))
let original = CTFontCreatePathForGlyph(font, glyph, nil)!
let bounds = original.boundingBoxOfPath
let scale = 650 / bounds.height
var transform = CGAffineTransform(a: scale, b: 0, c: 0, d: scale,
    tx: 512 - bounds.midX * scale, ty: 512 - bounds.midY * scale)
let path = original.copy(using: &transform)!
var commands = [String]()
func point(_ p: CGPoint) -> String { String(format: "%.3f %.3f", p.x, 1024 - p.y) }
path.applyWithBlock { pointer in
    let e = pointer.pointee
    switch e.type {
    case .moveToPoint: commands.append("M" + point(e.points[0]))
    case .addLineToPoint: commands.append("L" + point(e.points[0]))
    case .addQuadCurveToPoint: commands.append("Q" + point(e.points[0]) + " " + point(e.points[1]))
    case .addCurveToPoint: commands.append("C" + point(e.points[0]) + " " + point(e.points[1]) + " " + point(e.points[2]))
    case .closeSubpath: commands.append("Z")
    @unknown default: break
    }
}
let d = commands.joined(separator: " ")
let mark = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"1024\" height=\"1024\" viewBox=\"0 0 1024 1024\"><path fill=\"#E4ED87\" d=\"\(d)\"/></svg>"
try mark.write(to: root.appendingPathComponent("assets/brand/oracle-o.svg"), atomically: true, encoding: .utf8)
try mark.write(to: root.appendingPathComponent("ios/JEV/OracleIcon.icon/Assets/oracle-o.svg"), atomically: true, encoding: .utf8)
let lockup = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"1024\" height=\"1024\" viewBox=\"0 0 1024 1024\"><rect width=\"1024\" height=\"1024\" fill=\"#34452B\"/><path fill=\"#E4ED87\" d=\"\(d)\"/></svg>"
try lockup.write(to: root.appendingPathComponent("assets/brand/oracle-logo.svg"), atomically: true, encoding: .utf8)
let green = CGColor(red: 52/255, green: 69/255, blue: 43/255, alpha: 1)
let yellow = CGColor(red: 228/255, green: 237/255, blue: 135/255, alpha: 1)
let bitmap = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
bitmap.setFillColor(green); bitmap.fill(CGRect(x: 0, y: 0, width: 1024, height: 1024))
bitmap.setFillColor(yellow); bitmap.addPath(path); bitmap.fillPath()
let png = NSBitmapImageRep(cgImage: bitmap.makeImage()!).representation(using: .png, properties: [:])!
try png.write(to: root.appendingPathComponent("assets/brand/oracle-logo.png"))
var page = CGRect(x: 0, y: 0, width: 1024, height: 1024)
let pdfURL = root.appendingPathComponent("ios/JEV/BrandAssets.xcassets/OracleMark.imageset/oracle-o.pdf")
let pdf = CGContext(pdfURL as CFURL, mediaBox: &page, nil)!
pdf.beginPDFPage(nil); pdf.setFillColor(yellow); pdf.addPath(path); pdf.fillPath(); pdf.endPDFPage(); pdf.closePDF()
