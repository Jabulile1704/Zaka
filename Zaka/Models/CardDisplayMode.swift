import Foundation

nonisolated enum CardDisplayMode: String, CaseIterable, Identifiable {
    case barcode
    case qr

    var id: String { rawValue }

    var label: String {
        switch self {
        case .barcode: "Barcode"
        case .qr: "QR code"
        }
    }

    var symbol: String {
        switch self {
        case .barcode: "barcode"
        case .qr: "qrcode"
        }
    }

    func symbology(for number: String, savedAs saved: BarcodeSymbology) -> BarcodeSymbology {
        switch self {
        case .qr:
            .qr
        case .barcode:
            saved == .qr ? .detected(for: number) : saved
        }
    }

    func canDraw(_ number: String, savedAs saved: BarcodeSymbology) -> Bool {
        symbology(for: number, savedAs: saved).accepts(number)
    }

    static func available(for number: String, savedAs saved: BarcodeSymbology) -> [CardDisplayMode] {
        allCases.filter { $0.canDraw(number, savedAs: saved) }
    }

    static func initial(for number: String, savedAs saved: BarcodeSymbology) -> CardDisplayMode {
        let preferred: CardDisplayMode = saved == .qr ? .qr : .barcode
        let offered = available(for: number, savedAs: saved)
        return offered.contains(preferred) ? preferred : (offered.first ?? preferred)
    }
}
