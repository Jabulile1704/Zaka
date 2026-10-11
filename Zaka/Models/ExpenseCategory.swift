import SwiftUI

nonisolated enum ExpenseCategory: String, CaseIterable, Identifiable, Codable {
    case takeaways
    case groceries
    case transport
    case rent
    case utilities
    case health
    case wifi
    case subscriptions
    case shopping
    case accounts
    case cash
    case travelling
    case dates
    case airtime
    case haircut
    case others = "other"

    var id: String { rawValue }

    static func stored(_ raw: String) -> ExpenseCategory {
        ExpenseCategory(rawValue: raw) ?? retired[raw] ?? .others
    }

    private static let retired: [String: ExpenseCategory] = [
        "food": .takeaways,
        "bills": .accounts,
        "fun": .others
    ]

    var label: String {
        switch self {
        case .takeaways: "Takeaways"
        case .groceries: "Groceries"
        case .transport: "Transport"
        case .rent: "Rent"
        case .utilities: "Utilities"
        case .health: "Health"
        case .wifi: "WiFi"
        case .subscriptions: "Subscriptions"
        case .shopping: "Shopping"
        case .accounts: "Accounts"
        case .cash: "Cash"
        case .travelling: "Travelling"
        case .dates: "Dates"
        case .airtime: "Airtime"
        case .haircut: "Haircut"
        case .others: "Others"
        }
    }

    var symbol: String {
        switch self {
        case .takeaways: "takeoutbag.and.cup.and.straw.fill"
        case .groceries: "basket.fill"
        case .transport: "car.fill"
        case .rent: "house.fill"
        case .utilities: "bolt.fill"
        case .health: "cross.case.fill"
        case .wifi: "wifi"
        case .subscriptions: "repeat"
        case .shopping: "bag.fill"
        case .accounts: "creditcard.fill"
        case .cash: "banknote.fill"
        case .travelling: "airplane"
        case .dates: "heart.fill"
        case .airtime: "antenna.radiowaves.left.and.right"
        case .haircut: "scissors"
        case .others: "square.grid.2x2.fill"
        }
    }

    var tint: Color {
        switch self {
        case .takeaways: .orange
        case .groceries: .green
        case .transport: .blue
        case .rent: .brown
        case .utilities: Color(hex: "F2A93B")
        case .health: .red
        case .wifi: .cyan
        case .subscriptions: .purple
        case .shopping: .pink
        case .accounts: .indigo
        case .cash: .mint
        case .travelling: .teal
        case .dates: Color(hex: "B3246B")
        case .airtime: Color(hex: "0E8A6B")
        case .haircut: .yellow
        case .others: .gray
        }
    }
}
