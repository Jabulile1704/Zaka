import SwiftUI

nonisolated enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case takeaways
    case transport
    case rent
    case health
    case wifi
    case subscriptions
    case shopping
    case accounts
    case travelling
    case airtime
    case haircut
    case others = "other"

    var id: String { rawValue }

    static func stored(_ raw: String) -> ExpenseCategory {
        ExpenseCategory(rawValue: raw) ?? retired[raw] ?? .others
    }

    private static let retired: [String: ExpenseCategory] = [
        "food": .takeaways,
        "groceries": .takeaways,
        "bills": .accounts,
        "fun": .others
    ]

    var label: String {
        switch self {
        case .takeaways: "Takeaways"
        case .transport: "Transport"
        case .rent: "Rent"
        case .health: "Health"
        case .wifi: "WiFi"
        case .subscriptions: "Subscriptions"
        case .shopping: "Shopping"
        case .accounts: "Accounts"
        case .travelling: "Travelling"
        case .airtime: "Airtime"
        case .haircut: "Haircut"
        case .others: "Others"
        }
    }

    var symbol: String {
        switch self {
        case .takeaways: "takeoutbag.and.cup.and.straw.fill"
        case .transport: "car.fill"
        case .rent: "house.fill"
        case .health: "cross.case.fill"
        case .wifi: "wifi"
        case .subscriptions: "repeat"
        case .shopping: "bag.fill"
        case .accounts: "creditcard.fill"
        case .travelling: "airplane"
        case .airtime: "antenna.radiowaves.left.and.right"
        case .haircut: "scissors"
        case .others: "square.grid.2x2.fill"
        }
    }

    var tint: Color {
        switch self {
        case .takeaways: .orange
        case .transport: .blue
        case .rent: .brown
        case .health: .red
        case .wifi: .cyan
        case .subscriptions: .purple
        case .shopping: .pink
        case .accounts: .indigo
        case .travelling: .teal
        case .airtime: .green
        case .haircut: .yellow
        case .others: .gray
        }
    }
}
