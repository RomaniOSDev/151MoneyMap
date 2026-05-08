//
//  BudgetHeroSummary.swift
//  151MoneyMap
//

import SwiftUI

struct BudgetHeroSummary: View {
    let totalLimit: Double
    let totalSpent: Double
    let budgetCount: Int
    let overBudgetCount: Int

    private var utilization: Double {
        guard totalLimit > 0 else { return 0 }
        return min(totalSpent / totalLimit, 1.5)
    }

    private var displayPercent: Int {
        guard totalLimit > 0 else { return 0 }
        return Int(min(totalSpent / totalLimit, 2) * 100)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: CGFloat(min(utilization, 1)))
                    .stroke(
                        AngularGradient(
                            colors: utilization > 1
                                ? [.moneyExpense, .moneyExpense.opacity(0.7)]
                                : [.moneyAccent, .moneyIncome, .moneyAccent],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(displayPercent)%")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(.white)
                    Text("used")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.gray)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("All categories")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.moneyAccent)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(formatCurrency(totalSpent))
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundColor(.white)
                    Text("of")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatCurrency(totalLimit))
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                        .foregroundColor(.gray)
                }

                HStack(spacing: 12) {
                    Label("\(budgetCount) budgets", systemImage: "square.stack.3d.up")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.gray)
                    if overBudgetCount > 0 {
                        Label("\(overBudgetCount) over", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.moneyExpense)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.moneyAccent.opacity(0.3),
                            Color.white.opacity(0.06),
                            Color.black.opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.moneyAccent.opacity(0.5), Color.moneyIncome.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 22)
        .moneyMapDepthShadow(accent: .moneyAccent)
    }
}
