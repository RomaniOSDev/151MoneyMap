//
//  Budget.swift
//  151MoneyMap
//

import Foundation

struct Budget: Identifiable, Codable {
    let id: UUID
    var category: TransactionCategory
    var limit: Double
    var spent: Double
    let month: Int
    let year: Int

    var remaining: Double {
        limit - spent
    }

    var progress: Double {
        guard limit > 0 else { return 0 }
        return min(spent / limit, 1.0)
    }
}
