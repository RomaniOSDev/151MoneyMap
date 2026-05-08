//
//  Transaction.swift
//  151MoneyMap
//

import Foundation

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    var amount: Double
    var category: TransactionCategory
    var type: TransactionType
    var note: String?
    var location: String?
    var isFavorite: Bool
    let createdAt: Date
    var accountId: UUID
    var toAccountId: UUID?
    var tags: [String]

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        switch type {
        case .income:
            return formatter.string(from: NSNumber(value: amount)) ?? "$0"
        case .expense:
            return formatter.string(from: NSNumber(value: -amount)) ?? "$0"
        case .transfer:
            return formatter.string(from: NSNumber(value: amount)) ?? "$0"
        }
    }

    func displayTitle(accounts: [Account]) -> String {
        if type == .transfer {
            let from = accounts.first { $0.id == accountId }?.name ?? "From"
            let toName = toAccountId.flatMap { tid in accounts.first { $0.id == tid }?.name } ?? "To"
            return "\(from) → \(toName)"
        }
        return category.rawValue
    }

    func displayIconName() -> String {
        type == .transfer ? TransactionType.transfer.icon : category.icon
    }

    init(
        id: UUID,
        date: Date,
        amount: Double,
        category: TransactionCategory,
        type: TransactionType,
        note: String?,
        location: String?,
        isFavorite: Bool,
        createdAt: Date,
        accountId: UUID,
        toAccountId: UUID? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.category = category
        self.type = type
        self.note = note
        self.location = location
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.accountId = accountId
        self.toAccountId = toAccountId
        self.tags = tags
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id
    }
}
