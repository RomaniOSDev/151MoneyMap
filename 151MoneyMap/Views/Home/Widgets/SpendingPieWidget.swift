//
//  SpendingPieWidget.swift
//  151MoneyMap
//

import SwiftUI

struct SpendingPieWidget: View {
    let expenseByCategory: [(category: TransactionCategory, amount: Double)]
    var onSeeAnalytics: () -> Void

    var body: some View {
        HomeWidgetShell(
            title: "Spending mix",
            subtitle: "Expenses by category",
            actionTitle: expenseByCategory.isEmpty ? nil : "Analytics",
            action: expenseByCategory.isEmpty ? nil : onSeeAnalytics
        ) {
            if expenseByCategory.isEmpty {
                Text("Add expenses to see your category split.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                PieChartView(data: expenseByCategory)
                    .frame(height: 200)
            }
        }
    }
}
