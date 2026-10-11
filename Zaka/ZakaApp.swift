import SwiftUI
import SwiftData

@main
struct ZakaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: Expense.self)
    }
}
