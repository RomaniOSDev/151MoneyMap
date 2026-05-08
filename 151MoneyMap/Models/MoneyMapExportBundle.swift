//
//  MoneyMapExportBundle.swift
//  151MoneyMap
//

import Foundation

struct MoneyMapExportBundle: Codable {
    var exportedAt: Date
    var transactions: [Transaction]
    var budgets: [Budget]
    var savingsGoals: [SavingsGoal]
    var accounts: [Account]
    var recurringTemplates: [RecurringTemplate]
    var noteRules: [NoteRule]
}
