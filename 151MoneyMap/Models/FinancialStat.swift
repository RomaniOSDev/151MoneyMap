//
//  FinancialStat.swift
//  151MoneyMap
//

import Foundation

struct FinancialStat {
    var totalIncome: Double
    var totalExpense: Double
    var balance: Double
    var savingsRate: Double
    var topExpenseCategory: TransactionCategory?
    var topIncomeCategory: TransactionCategory?
    var monthlyAverageExpense: Double
}
