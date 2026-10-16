import SwiftUI

struct CardDetailView: View {
    let card: LoyaltyCard

    @Environment(\.dismiss) private var dismiss
    @State private var previousBrightness: CGFloat?
    @State private var editing = false

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                VStack(spacing: 28) {
                    Spacer(minLength: 0)

                    VStack(spacing: 6) {
                        Text(card.name)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        Text(card.symbology.label)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 16) {
                        BarcodeView(number: card.number, symbology: card.symbology)
                            .frame(height: card.symbology == .qr ? 240 : 130)

                        Text(card.number)
                            .font(.system(size: 17, weight: .medium, design: .monospaced))
                            .foregroundStyle(.black)
                            .textSelection(.enabled)
                    }
                    .padding(22)
                    .background(.white, in: .rect(cornerRadius: 22))
                    .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
                    .padding(.horizontal, 20)

                    Text("Screen brightness turned up for the scanner")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 0)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") { editing = true }
                }
            }
            .sheet(isPresented: $editing) {
                CardFormView(editing: card) { editing = false }
            }
        }
        .onAppear(perform: brighten)
        .onDisappear(perform: restore)
    }

    private func brighten() {
        guard let screen = Screens.current, previousBrightness == nil else { return }
        previousBrightness = screen.brightness
        screen.brightness = 1
    }

    private func restore() {
        guard let screen = Screens.current, let previous = previousBrightness else { return }
        screen.brightness = previous
        previousBrightness = nil
    }
}

enum Screens {
    static var current: UIScreen? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .screen
    }
}
