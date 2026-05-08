//
//  TransactionCategory.swift
//  151MoneyMap
//

import SwiftUI

enum TransactionCategory: String, CaseIterable, Codable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case health = "Health"
    case housing = "Housing"
    case utilities = "Utilities"
    case education = "Education"
    case other = "Other"

    case salary = "Salary"
    case freelance = "Freelance"
    case gift = "Gift"
    case investment = "Investment"
    case refund = "Refund"

    var type: TransactionType {
        switch self {
        case .food, .transport, .shopping, .entertainment, .health, .housing, .utilities, .education, .other:
            return .expense
        case .salary, .freelance, .gift, .investment, .refund:
            return .income
        }
    }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "tv.fill"
        case .health: return "heart.fill"
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .education: return "book.fill"
        case .salary: return "banknote.fill"
        case .freelance: return "laptopcomputer"
        case .gift: return "gift.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .refund: return "arrow.uturn.backward"
        case .other: return "folder.fill"
        }
    }

    static func categories(for type: TransactionType) -> [TransactionCategory] {
        switch type {
        case .income, .expense:
            return allCases.filter { $0.type == type }
        case .transfer:
            return [.other]
        }
    }
}
