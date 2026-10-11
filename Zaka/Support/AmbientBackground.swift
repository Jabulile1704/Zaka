import SwiftUI

/// A soft wash of colour behind every screen.
///
/// Liquid Glass is only legible when there is something for it to refract —
/// over a flat grey it reads as a plain rounded rectangle. These blurred
/// blobs give the glass layers something to pick up.
struct AmbientBackground: View {
    @Environment(\.colorScheme) private var scheme

    private var intensity: Double { scheme == .dark ? 0.22 : 0.13 }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)

            blob(.accentColor, size: 360, x: -130, y: -290)
            blob(.orange, size: 300, x: 160, y: -120)
            blob(.purple, size: 340, x: -110, y: 300)
            blob(.teal, size: 280, x: 150, y: 420)
        }
        .ignoresSafeArea()
    }

    private func blob(_ color: Color, size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(color.opacity(intensity))
            .frame(width: size, height: size)
            .blur(radius: 90)
            .offset(x: x, y: y)
    }
}
