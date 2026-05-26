import SwiftUI

// Sumi-e palette, same as the reader.
enum Theme {
    // Paper greys
    static let paper      = Color(hex: 0xFBFAF5)
    static let paperDeep  = Color(hex: 0xEFEDE5)
    static let paperEdge  = Color(hex: 0xAAA397)
    // Ink
    static let ink        = Color(hex: 0x060606)
    static let inkSoft    = Color(hex: 0x20201E)
    static let inkMute    = Color(hex: 0x383733)
    static let inkFaint   = Color(hex: 0x666159)
    // Accents
    static let accent     = Color(hex: 0x9B2F18)
    static let accentSoft = Color(hex: 0xB65A3B)
    static let highlight  = Color(hex: 0x8F7A38)
    static let seal       = Color(hex: 0x6F180F)

    // Type
    static let serif = "Newsreader"
    static let mono  = "JetBrains Mono"
    static let sans  = "Inter Tight"

    static func display(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(serif, size: size).weight(weight)
    }
    static func body(_ size: CGFloat = 13) -> Font {
        .custom(sans, size: size)
    }
    static func code(_ size: CGFloat = 12) -> Font {
        .custom(mono, size: size)
    }
    static func label(_ size: CGFloat = 11) -> Font {
        .custom(mono, size: size).weight(.medium)
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8)  & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
