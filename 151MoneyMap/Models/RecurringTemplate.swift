//
//  RecurringTemplate.swift
//  151MoneyMap
//

import Foundation

/// Monthly reminder template (income or expense). User confirms entry manually.
struct RecurringTemplate: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var amount: Double
    var type: TransactionType
    var category: TransactionCategory
    var accountId: UUID
    var tags: [String]
    var note: String?
    /// Day of month to fire reminder (1–28).
    var dayOfMonth: Int
    var hour: Int
    var minute: Int
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        type: TransactionType,
        category: TransactionCategory,
        accountId: UUID,
        tags: [String] = [],
        note: String? = nil,
        dayOfMonth: Int = 1,
        hour: Int = 9,
        minute: Int = 0,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.type = type
        self.category = category
        self.accountId = accountId
        self.tags = tags
        self.note = note
        self.dayOfMonth = min(28, max(1, dayOfMonth))
        self.hour = min(23, max(0, hour))
        self.minute = min(59, max(0, minute))
        self.isEnabled = isEnabled
    }
}
