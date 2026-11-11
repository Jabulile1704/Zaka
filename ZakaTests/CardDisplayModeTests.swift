import XCTest
@testable import Zaka

final class CardDisplayModeTests: XCTestCase {
    private let ean = "6001087001618"

    func testBarcodeCardOffersBothAndOpensAsBarcode() {
        XCTAssertEqual(CardDisplayMode.available(for: ean, savedAs: .ean13), [.barcode, .qr])
        XCTAssertEqual(CardDisplayMode.initial(for: ean, savedAs: .ean13), .barcode)
    }

    func testBarcodeModeKeepsTheSavedLinearType() {
        XCTAssertEqual(CardDisplayMode.barcode.symbology(for: ean, savedAs: .ean13), .ean13)
        XCTAssertEqual(CardDisplayMode.barcode.symbology(for: ean, savedAs: .code128), .code128,
                       "a card deliberately saved as Code 128 must not be promoted to EAN-13")
    }

    func testQRModeIsAlwaysQR() {
        XCTAssertEqual(CardDisplayMode.qr.symbology(for: ean, savedAs: .ean13), .qr)
        XCTAssertEqual(CardDisplayMode.qr.symbology(for: "ABC123", savedAs: .code128), .qr)
    }

    func testCardSavedAsQROpensAsQRAndInfersALinearType() {
        XCTAssertEqual(CardDisplayMode.initial(for: ean, savedAs: .qr), .qr)
        XCTAssertEqual(CardDisplayMode.barcode.symbology(for: ean, savedAs: .qr), .ean13)
        XCTAssertEqual(CardDisplayMode.barcode.symbology(for: "ABC123", savedAs: .qr), .code128)
    }

    func testNumberThatCannotBeALinearBarcodeOffersOnlyQR() {
        let number = "KAART-Ünïcode-42"
        XCTAssertEqual(CardDisplayMode.available(for: number, savedAs: .qr), [.qr])
        XCTAssertEqual(CardDisplayMode.initial(for: number, savedAs: .qr), .qr)
    }

    func testBrokenEANFallsBackToWhatCanBeDrawn() {
        let bad = "6001087001610"
        XCTAssertEqual(CardDisplayMode.available(for: bad, savedAs: .ean13), [.qr],
                       "an invalid EAN-13 cannot be drawn as EAN-13, so only QR is offered")
        XCTAssertEqual(CardDisplayMode.initial(for: bad, savedAs: .ean13), .qr)
    }

    func testEmptyNumberOffersNothing() {
        XCTAssertTrue(CardDisplayMode.available(for: "", savedAs: .code128).isEmpty)
    }

    func testQRImageIsGeneratedForNonASCIIText() {
        XCTAssertNotNil(GeneratedBarcode.image(for: "KAART-Ünïcode-42", symbology: .qr))
        XCTAssertNil(GeneratedBarcode.image(for: "KAART-Ünïcode-42", symbology: .code128))
    }
}
