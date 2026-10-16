import XCTest
@testable import Zaka

final class LoyaltyCardTests: XCTestCase {
    func testSymbologyIsDetectedFromTheNumber() {
        XCTAssertEqual(BarcodeSymbology.detected(for: "6001087001618"), .ean13)
        XCTAssertEqual(BarcodeSymbology.detected(for: "6001087001610"), .code128, "bad check digit is not EAN-13")
        XCTAssertEqual(BarcodeSymbology.detected(for: "ABC123"), .code128)
    }

    func testAcceptance() {
        XCTAssertTrue(BarcodeSymbology.ean13.accepts("6001087001618"))
        XCTAssertFalse(BarcodeSymbology.ean13.accepts("12345"))
        XCTAssertTrue(BarcodeSymbology.code128.accepts("ABC123"))
        XCTAssertFalse(BarcodeSymbology.code128.accepts(""))
    }

    func testLastFour() {
        XCTAssertEqual(LoyaltyCard(name: "Clicks", number: "6001087001618", symbology: .ean13).lastFour, "1618")
        XCTAssertEqual(LoyaltyCard(name: "Short", number: "12", symbology: .code128).lastFour, "12")
        XCTAssertEqual(LoyaltyCard(name: "None", number: "ABC", symbology: .code128).lastFour, "")
    }

    func testSymbologySurvivesTheRawValueRoundTrip() {
        let card = LoyaltyCard(name: "Dis-Chem", number: "6001087001618", symbology: .ean13)
        XCTAssertEqual(card.symbology, .ean13)
        card.symbology = .qr
        XCTAssertEqual(card.symbologyRaw, "qr")
        XCTAssertEqual(card.symbology, .qr)
    }
}
