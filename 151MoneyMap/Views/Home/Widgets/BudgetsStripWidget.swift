//
//  BudgetsStripWidget.swift
//  151MoneyMap
//

import SwiftUI

struct BudgetsStripWidget: View {
    let budgets: [Budget]
    var onSeeAll: () -> Void

    var body: some View {
        HomeWidgetShell(
            title: "Budgets",
            subtitle: "Track limits at a glance",
            actionTitle: "See all",
            action: onSeeAll
        ) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(budgets) { budget in
                        budgetChip(budget)
                    }
                }
            }
        }
    }

    private func budgetChip(_ budget: Budget) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: budget.category.icon)
                    .foregroundColor(budget.category.type.color)
                Text(budget.category.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            ProgressView(value: budget.progress)
                .tint(budget.progress > 0.8 ? Color.moneyExpense : Color.moneyAccent)
            Text("\(formatCurrency(budget.spent)) / \(formatCurrency(budget.limit))")
                .font(.caption2.monospacedDigit())
                .foregroundColor(.gray)
        }
        .padding(14)
        .frame(width: 168, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.moneyAccent.opacity(0.1),
                            Color.black.opacity(0.45)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.moneyAccent.opacity(0.42), Color.moneyExpense.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 16)
        .moneyMapChipShadow(accent: .moneyAccent)
    }
}
