import SwiftUI
import SwiftData

@main
struct ZakaApp: App {
    private let container = ZakaApp.makeContainer()

    var body: some Scene {
        WindowGroup {
            LaunchGate()
        }
        .modelContainer(container)
    }

    private static func makeContainer() -> ModelContainer {
        let schema = Schema([Expense.self, LoyaltyCard.self])

        #if ZAKA_CLOUDKIT
        let synced = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private("iCloud.com.jabulile.zaka")
        )
        if let container = try? ModelContainer(for: schema, configurations: synced) {
            return container
        }
        #endif

        let local = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        if let container = try? ModelContainer(for: schema, configurations: local) {
            return container
        }

        fatalError("Could not open the expense store")
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
