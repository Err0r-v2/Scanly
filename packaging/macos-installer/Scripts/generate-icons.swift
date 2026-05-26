#!/usr/bin/env swift
import AppKit
import CoreGraphics

// Generates the Scanly Deploy app icon (.icns + iconset) and the Scanly
// AppLoad tile (icon.png 512×512). Sumi-e palette: paper / ink / red seal.

let paper      = NSColor(red: 0.984, green: 0.980, blue: 0.961, alpha: 1)
let paperDeep  = NSColor(red: 0.937, green: 0.929, blue: 0.898, alpha: 1)
let paperEdge  = NSColor(red: 0.667, green: 0.640, blue: 0.592, alpha: 1)
let ink        = NSColor(red: 0.024, green: 0.024, blue: 0.024, alpha: 1)
let inkSoft    = NSColor(red: 0.125, green: 0.125, blue: 0.118, alpha: 1)
let seal       = NSColor(red: 0.435, green: 0.094, blue: 0.059, alpha: 1)

// MARK: - Helpers

@discardableResult
func savePNG(_ image: NSImage, to path: String) -> Bool {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let data = rep.representation(using: .png, properties: [:]) else { return false }
    return (try? data.write(to: URL(fileURLWithPath: path))) != nil
}

func draw(_ size: CGFloat, _ body: (CGContext, CGFloat) -> Void) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    body(ctx, size)
    image.unlockFocus()
    return image
}

func drawPaperBackground(_ ctx: CGContext, _ s: CGFloat) {
    paper.setFill()
    ctx.fill(CGRect(x: 0, y: 0, width: s, height: s))
    // Subtle vignette near the corners , a hand-pressed paper feel.
    let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                          colors: [paper.withAlphaComponent(0).cgColor,
                                   paperDeep.withAlphaComponent(0.45).cgColor] as CFArray,
                          locations: [0, 1])!
    ctx.drawRadialGradient(grad,
                           startCenter: CGPoint(x: s * 0.5, y: s * 0.5), startRadius: s * 0.25,
                           endCenter:   CGPoint(x: s * 0.5, y: s * 0.5), endRadius:   s * 0.7,
                           options: [])
}

func drawSeal(_ ctx: CGContext, _ s: CGFloat, at center: CGPoint, sealSize: CGFloat,
              glyph: String = "印", rotation: CGFloat = -7) {
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y)
    ctx.rotate(by: rotation * .pi / 180)
    let rect = CGRect(x: -sealSize / 2, y: -sealSize / 2, width: sealSize, height: sealSize)
    seal.setFill()
    ctx.fill(rect)
    // Inner inset stroke (carved seal look)
    seal.withAlphaComponent(0.65).setStroke()
    ctx.setLineWidth(sealSize * 0.05)
    ctx.stroke(rect.insetBy(dx: sealSize * 0.10, dy: sealSize * 0.10))
    // Glyph
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont(name: "Hiragino Mincho ProN", size: sealSize * 0.55)
            ?? NSFont.boldSystemFont(ofSize: sealSize * 0.55),
        .foregroundColor: paper,
    ]
    let str = NSAttributedString(string: glyph, attributes: attrs)
    let sz = str.size()
    str.draw(at: CGPoint(x: -sz.width / 2, y: -sz.height / 2 - sealSize * 0.04))
    ctx.restoreGState()
}

// MARK: - Scanly tile (AppLoad icon.png, 512×512)
//
// Composition: a brush-stroke "S" framed inside a manga panel border,
// with the seal stamped over the bottom-right corner.

func renderScanlyTile(_ size: CGFloat) -> NSImage {
    return draw(size) { ctx, s in
        drawPaperBackground(ctx, s)

        let pad = s * 0.10
        let frame = CGRect(x: pad, y: pad, width: s - 2 * pad, height: s - 2 * pad)

        // Outer frame.
        ink.setStroke()
        ctx.setLineWidth(s * 0.018)
        ctx.stroke(frame)

        // Inner double border, hand-pressed (offset inwards).
        ctx.setLineWidth(s * 0.006)
        inkSoft.setStroke()
        ctx.stroke(frame.insetBy(dx: s * 0.025, dy: s * 0.025))

        // Big serif "S" centered.
        let s_size = s * 0.62
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "Didot", size: s_size)
                ?? NSFont(name: "Times New Roman Bold", size: s_size)
                ?? NSFont.boldSystemFont(ofSize: s_size),
            .foregroundColor: ink,
        ]
        let str = NSAttributedString(string: "S", attributes: attrs)
        let sz = str.size()
        str.draw(at: CGPoint(x: (s - sz.width) / 2,
                             y: (s - sz.height) / 2 - s * 0.02))

        // "SCANLY" lockup below the S? No , keep it iconic, glyph only.

        // Top-left small label "MANGA"
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "Menlo-Bold", size: s * 0.038)
                ?? NSFont.boldSystemFont(ofSize: s * 0.038),
            .foregroundColor: ink,
            .kern: 2.0,
        ]
        let label = NSAttributedString(string: "MANGA", attributes: labelAttrs)
        label.draw(at: CGPoint(x: frame.minX + s * 0.04,
                               y: frame.maxY - s * 0.07))

        // Bottom-right seal.
        let sealSize = s * 0.20
        drawSeal(ctx, s,
                 at: CGPoint(x: frame.maxX - sealSize * 0.55,
                             y: frame.minY + sealSize * 0.55),
                 sealSize: sealSize,
                 glyph: "印")
    }
}

// MARK: - Deployer icon
//
// Composition: a tablet outline with an arrow descending into it,
// the seal in the top-right corner, "DEPLOY" wordmark at the bottom.

func renderDeployerIcon(_ size: CGFloat) -> NSImage {
    return draw(size) { ctx, s in
        drawPaperBackground(ctx, s)

        // Layout: arrow at top (≈ y in [0.78, 0.92]), tablet in the middle
        // (≈ y in [0.22, 0.74]), "DEPLOY" wordmark at the bottom.
        // Origin is bottom-left, so larger y = higher on the icon.

        // ---- Tablet body (portrait shape, centred horizontally).
        let tw = s * 0.46
        let th = s * 0.52
        let tx = (s - tw) / 2
        let ty = s * 0.22
        let tablet = CGRect(x: tx, y: ty, width: tw, height: th)
        ink.setStroke()
        ctx.setLineWidth(s * 0.022)
        ctx.stroke(tablet)

        // Inner double-stroke (manga panel motif).
        ctx.setLineWidth(s * 0.006)
        inkSoft.setStroke()
        ctx.stroke(tablet.insetBy(dx: s * 0.018, dy: s * 0.018))

        // ---- Large Scanly "S" filling the tablet's screen.
        let sFont = NSFont(name: "Didot", size: th * 0.78)
            ?? NSFont(name: "Times New Roman Bold", size: th * 0.78)
            ?? NSFont.boldSystemFont(ofSize: th * 0.78)
        let sAttrs: [NSAttributedString.Key: Any] = [
            .font: sFont, .foregroundColor: ink,
        ]
        let glyph = NSAttributedString(string: "S", attributes: sAttrs)
        let gsz = glyph.size()
        glyph.draw(at: CGPoint(x: tablet.midX - gsz.width / 2,
                               y: tablet.midY - gsz.height / 2 - s * 0.01))

        // ---- Arrow above, pointing down into the tablet.
        ink.setStroke()
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.setLineWidth(s * 0.024)
        let ax = s / 2
        let arrowTop = s * 0.92
        let arrowBot = tablet.maxY + s * 0.05
        ctx.move(to: CGPoint(x: ax, y: arrowTop))
        ctx.addLine(to: CGPoint(x: ax, y: arrowBot))
        ctx.strokePath()
        let head = s * 0.045
        ctx.move(to: CGPoint(x: ax - head, y: arrowBot + head))
        ctx.addLine(to: CGPoint(x: ax, y: arrowBot))
        ctx.addLine(to: CGPoint(x: ax + head, y: arrowBot + head))
        ctx.strokePath()

        // ---- "DEPLOY" wordmark beneath the tablet.
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "Menlo-Bold", size: s * 0.062)
                ?? NSFont.boldSystemFont(ofSize: s * 0.062),
            .foregroundColor: ink,
            .kern: 4.0,
        ]
        let label = NSAttributedString(string: "DEPLOY", attributes: labelAttrs)
        let lsz = label.size()
        label.draw(at: CGPoint(x: (s - lsz.width) / 2,
                               y: tablet.minY - lsz.height - s * 0.03))

        // ---- Seal top-right.
        let sealSize = s * 0.18
        drawSeal(ctx, s,
                 at: CGPoint(x: s - sealSize * 0.65,
                             y: s - sealSize * 0.65),
                 sealSize: sealSize,
                 glyph: "印")
    }
}

// MARK: - Pipeline

let here = (CommandLine.arguments.dropFirst().first ?? FileManager.default.currentDirectoryPath)
print("Generating into \(here)")

// 1. Scanly tile (single 512×512 PNG for AppLoad).
let scanlyDir = "\(here)/../appload/scanly"
let scanlyTile = renderScanlyTile(512)
savePNG(scanlyTile, to: "\(scanlyDir)/icon.png")
print("→ wrote \(scanlyDir)/icon.png")

// 2. Deployer iconset → icns.
let iconsetDir = "\(here)/Resources/AppIcon.iconset"
try? FileManager.default.removeItem(atPath: iconsetDir)
try? FileManager.default.createDirectory(atPath: iconsetDir, withIntermediateDirectories: true)

let sizes: [(Int, String)] = [
    (16,  "icon_16x16.png"),
    (32,  "icon_16x16@2x.png"),
    (32,  "icon_32x32.png"),
    (64,  "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024,"icon_512x512@2x.png"),
]
for (sz, name) in sizes {
    let img = renderDeployerIcon(CGFloat(sz))
    savePNG(img, to: "\(iconsetDir)/\(name)")
}
print("→ wrote iconset to \(iconsetDir)")

let icnsPath = "\(here)/Resources/AppIcon.icns"
let p = Process()
p.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
p.arguments = ["-c", "icns", iconsetDir, "-o", icnsPath]
try p.run(); p.waitUntilExit()
print("→ wrote \(icnsPath)")
