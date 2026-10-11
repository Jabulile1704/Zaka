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

/// Holds the splash over the app until its animation finishes.
private struct LaunchGate: View {
    @State private var showingSplash = true

    var body: some View {
        ZStack {
            RootView()

            if showingSplash {
                SplashView {
                    withAnimation(.easeOut(duration: 0.45)) { showingSplash = false }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}
