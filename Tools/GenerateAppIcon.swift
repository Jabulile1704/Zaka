#!/usr/bin/env swift
import AppKit
import Foundation

struct Palette {
    let groundTop: NSColor
    let groundBottom: NSColor
    let ring: NSColor
    let centre: NSColor
    let rimEdge: NSColor
    let innerEdge: NSColor
    let letter: NSColor
    let gloss: NSColor
    let glossAlpha: CGFloat

    static let light = Palette(
        groundTop: .hex("0F8E6F"),
        groundBottom: .hex("06483A"),
        ring: .hex("C3CCCF"),
        centre: .hex("D8AC3E"),
        rimEdge: .hex("7E8A8D"),
        innerEdge: .hex("8A6414"),
        letter: .hex("5E440F"),
        gloss: .white,
        glossAlpha: 0.20
    )

    static let dark = Palette(
        groundTop: .hex("17231E"),
        groundBottom: .hex("070D0B"),
        ring: .hex("8E999C"),
        centre: .hex("E0B84F"),
        rimEdge: .hex("5F696B"),
        innerEdge: .hex("2A2010"),
        letter: .hex("4A350A"),
        gloss: .hex("D8AC3E"),
        glossAlpha: 0.16
    )
}

extension NSColor {
    func darkened(by amount: CGFloat) -> NSColor {
        blended(withFraction: amount, of: .black) ?? self
    }

    func lightened(by amount: CGFloat) -> NSColor {
        blended(withFraction: amount, of: .white) ?? self
    }

    static func hex(_ value: String) -> NSColor {
        var int: UInt64 = 0
        Scanner(string: value).scanHexInt64(&int)
        return NSColor(
            srgbRed: CGFloat((int >> 16) & 0xFF) / 255,
            green: CGFloat((int >> 8) & 0xFF) / 255,
            blue: CGFloat(int & 0xFF) / 255,
            alpha: 1
        )
    }
}

func drawIcon(size: CGFloat, palette: Palette) -> CGImage {
    let unit = size / 100
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    guard let context = CGContext(
        data: nil,
        width: Int(size),
        height: Int(size),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        fatalError("Could not create the bitmap context")
    }

    context.setAllowsAntialiasing(true)
    context.interpolationQuality = .high

    if let gradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [palette.groundTop.cgColor, palette.groundBottom.cgColor] as CFArray,
        locations: [0, 1]
    ) {
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: size),
            end: CGPoint(x: size, y: 0),
            options: []
        )
    }

    if let gloss = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            palette.gloss.withAlphaComponent(palette.glossAlpha).cgColor,
            palette.gloss.withAlphaComponent(0).cgColor
        ] as CFArray,
        locations: [0, 1]
    ) {
        let centre = CGPoint(x: size * 0.24, y: size * 0.78)
        context.drawRadialGradient(
            gloss,
            startCenter: centre, startRadius: 0,
            endCenter: centre, endRadius: size * 0.62,
            options: []
        )
    }

    let middle = CGPoint(x: size / 2, y: size / 2)

    func circle(radius: CGFloat) -> CGPath {
        CGPath(
            ellipseIn: CGRect(
                x: middle.x - radius, y: middle.y - radius,
                width: radius * 2, height: radius * 2
            ),
            transform: nil
        )
    }

    context.addPath(circle(radius: 42 * unit))
    context.setFillColor(palette.ring.cgColor)
    context.fillPath()

    context.saveGState()
    context.addPath(circle(radius: 39.75 * unit))
    context.setStrokeColor(palette.ring.darkened(by: 0.26).cgColor)
    context.setLineWidth(4.5 * unit)
    context.setLineDash(phase: 0, lengths: [2.4 * unit, 2.4 * unit])
    context.strokePath()
    context.restoreGState()

    context.addPath(circle(radius: 37 * unit))
    context.setFillColor(palette.ring.lightened(by: 0.10).cgColor)
    context.fillPath()

    context.addPath(circle(radius: 37 * unit))
    context.setStrokeColor(palette.ring.darkened(by: 0.18).withAlphaComponent(0.55).cgColor)
    context.setLineWidth(1.2 * unit)
    context.strokePath()

    context.addPath(circle(radius: 26 * unit))
    context.setFillColor(palette.centre.cgColor)
    context.fillPath()

    context.addPath(circle(radius: 26 * unit))
    context.setStrokeColor(palette.innerEdge.withAlphaComponent(0.5).cgColor)
    context.setLineWidth(1.5 * unit)
    context.strokePath()

    context.addPath(circle(radius: 42 * unit))
    context.setStrokeColor(palette.rimEdge.darkened(by: 0.3).withAlphaComponent(0.55).cgColor)
    context.setLineWidth(1.4 * unit)
    context.strokePath()

    drawR(in: context, centre: middle, pointSize: 29 * unit, color: palette.letter)

    guard let image = context.makeImage() else {
        fatalError("Could not render the icon")
    }
    return image
}

func drawR(in context: CGContext, centre: CGPoint, pointSize: CGFloat, color: NSColor) {
    let base = NSFont.systemFont(ofSize: pointSize, weight: .heavy)
    let font = base.fontDescriptor
        .withDesign(.rounded)
        .flatMap { NSFont(descriptor: $0, size: pointSize) }
        ?? base

    let line = CTLineCreateWithAttributedString(NSAttributedString(
        string: "R",
        attributes: [.font: font, .foregroundColor: color]
    ))
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)

    context.textPosition = CGPoint(
        x: centre.x - bounds.midX,
        y: centre.y - bounds.midY
    )
    CTLineDraw(line, context)
}

func write(_ image: CGImage, to url: URL) {
    let rep = NSBitmapImageRep(cgImage: image)
    rep.size = NSSize(width: image.width, height: image.height)
    guard let data = rep.representation(using: .png, properties: [:]) else {
        fatalError("Could not encode \(url.lastPathComponent)")
    }
    do {
        try data.write(to: url)
    } catch {
        fatalError("Could not write \(url.path): \(error)")
    }
    print("wrote \(url.lastPathComponent) (\(image.width)×\(image.height))")
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconSet = root.appendingPathComponent("Zaka/Assets.xcassets/AppIcon.appiconset")

guard FileManager.default.fileExists(atPath: iconSet.path) else {
    fatalError("Run this from the project root — \(iconSet.path) is missing")
}

write(drawIcon(size: 1024, palette: .light), to: iconSet.appendingPathComponent("icon-light.png"))
write(drawIcon(size: 1024, palette: .dark), to: iconSet.appendingPathComponent("icon-dark.png"))
