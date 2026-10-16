import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct BarcodeView: View {
    let number: String
    let symbology: BarcodeSymbology

    var body: some View {
        switch symbology {
        case .ean13:
            if let modules = EAN13.modules(for: number) {
                ModuleBarcode(modules: modules)
            } else {
                BarcodeUnavailable(reason: "Not a valid 13-digit code")
            }
        case .code128, .qr:
            if let image = GeneratedBarcode.image(for: number, symbology: symbology) {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
            } else {
                BarcodeUnavailable(reason: "Could not draw this code")
            }
        }
    }
}

private struct ModuleBarcode: View {
    let modules: [Bool]

    private let quietLeft = 9
    private let quietRight = 7

    var body: some View {
        Canvas { context, size in
            let total = CGFloat(modules.count + quietLeft + quietRight)
            let unit = size.width / total

            for (index, isBar) in modules.enumerated() where isBar {
                let x = (CGFloat(index) + CGFloat(quietLeft)) * unit
                context.fill(
                    Path(CGRect(x: x, y: 0, width: unit, height: size.height)),
                    with: .color(.black)
                )
            }
        }
        .background(.white)
    }
}

private struct BarcodeUnavailable: View {
    let reason: String

    var body: some View {
        ContentUnavailableView(
            "No barcode",
            systemImage: "barcode",
            description: Text(reason)
        )
    }
}

nonisolated enum GeneratedBarcode {
    static func image(for number: String, symbology: BarcodeSymbology) -> CGImage? {
        guard let data = number.data(using: .ascii) else { return nil }

        let output: CIImage?
        switch symbology {
        case .code128:
            let filter = CIFilter.code128BarcodeGenerator()
            filter.message = data
            filter.quietSpace = 8
            output = filter.outputImage
        case .qr:
            let filter = CIFilter.qrCodeGenerator()
            filter.message = data
            filter.correctionLevel = "M"
            output = filter.outputImage
        case .ean13:
            return nil
        }

        guard let image = output else { return nil }
        return CIContext().createCGImage(image, from: image.extent)
    }
}
