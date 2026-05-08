//
//  TransactionType.swift
//  151MoneyMap
//

import SwiftUI

enum TransactionType: String, CaseIterable, Codable {
    case income = "Income"
    case expense = "Expense"
    case transfer = "Transfer"

    var color: Color {
        switch self {
        case .income: return .moneyIncome
        case .expense: return .moneyExpense
        case .transfer: return .moneyAccent
        }
    }

    var icon: String {
        switch self {
        case .income: return "arrow.down.circle.fill"
        case .expense: return "arrow.up.circle.fill"
        case .transfer: return "arrow.left.arrow.right.circle.fill"
        }
    }

    /// Types that affect category / budget flows (not transfer).
    static var ledgerTypes: [TransactionType] {
        [.income, .expense]
    }
}
