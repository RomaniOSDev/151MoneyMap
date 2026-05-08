//
//  Account.swift
//  151MoneyMap
//

import Foundation

struct Account: Identifiable, Codable, Equatable {
    /// Stable id for the default wallet created on first launch / migration.
    static let defaultWalletId = UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-000000000001")!

    let id: UUID
    var name: String
    var iconName: String
    var sortOrder: Int

    static func defaultWallet() -> Account {
        Account(id: defaultWalletId, name: "Cash", iconName: "banknote", sortOrder: 0)
    }
}
