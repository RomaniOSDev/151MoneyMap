//
//  TransactionFilter.swift
//  151MoneyMap
//

import Foundation

struct TransactionFilter: Equatable {
    var searchText: String = ""
    var categories: Set<TransactionCategory> = []
    var types: Set<TransactionType> = []
    var favoritesOnly: Bool = false
    var minAmount: Double?
    var maxAmount: Double?
    var fromDate: Date?
    var toDate: Date?
    var accountIds: Set<UUID> = []
    var tagContains: String = ""

    var isActive: Bool {
        !searchText.isEmpty
            || !categories.isEmpty
            || !types.isEmpty
            || favoritesOnly
            || minAmount != nil
            || maxAmount != nil
            || fromDate != nil
            || toDate != nil
            || !accountIds.isEmpty
            || !tagContains.isEmpty
    }

    mutating func reset() {
        self = TransactionFilter()
    }
}
