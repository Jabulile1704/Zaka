import SwiftUI
import SwiftData

@main
struct ZakaApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchGate()
        }
        .modelContainer(for: Expense.self)
    }
}

private enum SplashDefaults {
    static let seenKey = "hasSeenSplash"

    static var hasSeen: Bool {
        UserDefaults.standard.bool(forKey: seenKey)
    }
}

/// Plays the splash over the app, once per install.
///
/// After the first run the animation is pure delay between the user and their
/// expenses, so it is shown once and then stepped over. Deleting and
/// reinstalling brings it back.
private struct LaunchGate: View {
    @AppStorage(SplashDefaults.seenKey) private var hasSeenSplash = false

    /// Seeded from the stored flag rather than set in `onAppear`, so a repeat
    /// launch never flashes a frame of the splash before hiding it.
    @State private var showingSplash = !SplashDefaults.hasSeen

    var body: some View {
        ZStack {
            RootView()

            if showingSplash {
                SplashView(onFinish: dismissSplash)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }

    private func dismissSplash() {
        hasSeenSplash = true
        withAnimation(.easeOut(duration: 0.45)) { showingSplash = false }
    }
}
