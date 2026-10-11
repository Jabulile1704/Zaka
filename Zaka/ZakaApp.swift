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

private struct LaunchGate: View {
    @AppStorage(SplashDefaults.seenKey) private var hasSeenSplash = false

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
