import Foundation

nonisolated enum BarcodeSymbology: String, CaseIterable, Identifiable, Codable {
    case ean13
    case code128
    case qr

    var id: String { rawValue }

    var label: String {
        switch self {
        case .ean13: "EAN-13"
        case .code128: "Code 128"
        case .qr: "QR"
        }
    }

    var hint: String {
        switch self {
        case .ean13: "13 digits, the usual retail barcode"
        case .code128: "Letters and digits"
        case .qr: "Square code"
        }
    }

    static func detected(for number: String) -> BarcodeSymbology {
        EAN13.isValid(number) ? .ean13 : .code128
    }

    func accepts(_ number: String) -> Bool {
        switch self {
        case .ean13: EAN13.isValid(number)
        case .code128: !number.isEmpty && number.allSatisfy { $0.isASCII }
        case .qr: !number.isEmpty
        }
    }
}
