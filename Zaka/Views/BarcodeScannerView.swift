import SwiftUI
import VisionKit

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onFound: (String) -> Void

    static var isSupported: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: DataScannerViewController, context: Context) {
        try? controller.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onFound: onFound)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onFound: (String) -> Void
        private var hasReported = false

        init(onFound: @escaping (String) -> Void) {
            self.onFound = onFound
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            guard !hasReported else { return }
            for item in addedItems {
                guard case let .barcode(barcode) = item,
                      let value = barcode.payloadStringValue,
                      !value.isEmpty else { continue }
                hasReported = true
                onFound(value)
                return
            }
        }
    }
}

struct ScannerSheet: View {
    let onFound: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if BarcodeScannerView.isSupported {
                    BarcodeScannerView { value in
                        onFound(value)
                        dismiss()
                    }
                    .ignoresSafeArea(edges: .bottom)
                } else {
                    ContentUnavailableView(
                        "Camera unavailable",
                        systemImage: "camera.fill",
                        description: Text("Scanning needs a camera, so it does not work in the simulator. Type the number instead.")
                    )
                }
            }
            .navigationTitle("Scan card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
