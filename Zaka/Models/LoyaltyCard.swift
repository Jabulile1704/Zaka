import Foundation
import SwiftData
import SwiftUI

@Model
final class LoyaltyCard {
    var name: String = ""
    var number: String = ""
    var symbologyRaw: String = BarcodeSymbology.code128.rawValue
    var tintHex: String = CardTint.palette[0]
    var addedAt: Date = Date.now

    init(
        name: String,
        number: String,
        symbology: BarcodeSymbology,
        tintHex: String = CardTint.palette[0],
        addedAt: Date = .now
    ) {
        self.name = name
        self.number = number
        self.symbologyRaw = symbology.rawValue
        self.tintHex = tintHex
        self.addedAt = addedAt
    }

    var symbology: BarcodeSymbology {
        get { BarcodeSymbology(rawValue: symbologyRaw) ?? .code128 }
        set { symbologyRaw = newValue.rawValue }
    }

    var tint: Color { Color(hex: tintHex) }

    var lastFour: String {
        let digits = number.filter(\.isNumber)
        return digits.count > 4 ? String(digits.suffix(4)) : digits
    }
}

nonisolated enum CardTint {
    static let palette = [
        "0F8E6F", "1E64B4", "B3246B", "C2410C",
        "6D28D9", "0E7490", "B45309", "334155"
    ]
}
