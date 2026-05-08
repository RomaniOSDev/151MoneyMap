//
//  GoalsStripWidget.swift
//  151MoneyMap
//

import SwiftUI

struct GoalsStripWidget: View {
    let goals: [SavingsGoal]
    var onSeeAll: () -> Void

    var body: some View {
        HomeWidgetShell(
            title: "Savings goals",
            subtitle: "Closest targets",
            actionTitle: "See all",
            action: onSeeAll
        ) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(goals) { goal in
                        goalChip(goal)
                    }
                }
            }
        }
    }

    private func goalChip(_ goal: SavingsGoal) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(goal.name)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                Spacer(minLength: 0)
                if goal.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.moneyIncome)
                }
            }
            ProgressView(value: goal.progress)
                .tint(goal.progress >= 1 ? Color.moneyIncome : Color.moneyAccent)
            HStack {
                Text(goal.formattedProgress)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.moneyAccent)
                Spacer()
                Text(formatCurrency(goal.currentAmount))
                    .font(.caption2.monospacedDigit())
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .frame(width: 200, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.moneyAccent.opacity(0.08),
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
                        colors: [Color.moneyAccent.opacity(0.4), Color.moneyIncome.opacity(0.15)],
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
