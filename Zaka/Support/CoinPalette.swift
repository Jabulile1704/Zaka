import SwiftUI

extension Color {
    nonisolated init(hex: String) {
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        self.init(
            .sRGB,
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}

struct CoinPalette {
    let ring: Color
    let groove: Color
    let field: Color
    let centre: Color
    let letter: Color

    static let light = CoinPalette(
        ring: Color(hex: "C3CCCF"),
        groove: Color(hex: "909799"),
        field: Color(hex: "C9D1D4"),
        centre: Color(hex: "D8AC3E"),
        letter: Color(hex: "5E440F")
    )

    static let dark = CoinPalette(
        ring: Color(hex: "8E999C"),
        groove: Color(hex: "697173"),
        field: Color(hex: "99A3A6"),
        centre: Color(hex: "E0B84F"),
        letter: Color(hex: "4A350A")
    )

    static func of(_ scheme: ColorScheme) -> CoinPalette {
        scheme == .dark ? .dark : .light
    }
}

enum NotePalette {
    static func colours(_ scheme: ColorScheme) -> [Color] {
        scheme == .dark
            ? [Color(hex: "A85A1E"), Color(hex: "21537E"), Color(hex: "235F3C")]
            : [Color(hex: "D4762A"), Color(hex: "2C6EA8"), Color(hex: "2E7D4F")]
    }
}
