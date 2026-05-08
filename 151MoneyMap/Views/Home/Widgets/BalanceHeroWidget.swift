//
//  BalanceHeroWidget.swift
//  151MoneyMap
//

import SwiftUI

struct BalanceHeroWidget: View {
    let balance: Double
    let income: Double
    let expense: Double
    let savingsRate: Double
    let monthCaption: String
    let transactionCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("BALANCE")
                        .font(.caption2.weight(.semibold))
                        .tracking(0.9)
                        .foregroundColor(.white.opacity(0.65))
                    Text(monthCaption)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.45))
                }
                Spacer()
                Image(systemName: "chart.xyaxis.line")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.moneyAccent, .moneyIncome],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text(formatCurrency(balance))
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundColor(balance >= 0 ? .moneyIncome : .moneyExpense)
                .minimumScaleFactor(0.55)
                .lineLimit(1)

            HStack(spacing: 10) {
                metricPill(
                    title: "Income",
                    value: formatCurrency(income),
                    color: .moneyIncome,
                    icon: "arrow.down.circle.fill"
                )
                metricPill(
                    title: "Spent",
                    value: formatCurrency(expense),
                    color: .moneyExpense,
                    icon: "arrow.up.circle.fill"
                )
            }

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "percent")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.moneyAccent)
                    Text(String(format: "Savings rate %.0f%%", savingsRate))
                        .font(.caption.weight(.medium))
                        .foregroundColor(.gray)
                }
                Spacer()
                Label("\(transactionCount) entries", systemImage: "list.bullet.rectangle")
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.gray.opacity(0.85))
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.moneyAccent.opacity(0.42),
                            Color.moneyIncome.opacity(0.12),
                            Color.moneyBackground.opacity(0.94),
                            Color.black.opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.moneyAccent.opacity(0.55), Color.moneyIncome.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 24)
        .moneyMapDepthShadow(accent: .moneyAccent)
    }

    private func metricPill(title: String, value: String, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption2.weight(.semibold))
                .foregroundColor(color.opacity(0.9))
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(color.opacity(0.28), lineWidth: 0.5)
        )
        .moneyMapSpecularRim(cornerRadius: 14)
        .moneyMapChipShadow(accent: color)
    }
}
