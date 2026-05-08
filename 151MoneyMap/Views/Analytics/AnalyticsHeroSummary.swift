//
//  AnalyticsHeroSummary.swift
//  151MoneyMap
//

import SwiftUI

struct AnalyticsHeroSummary: View {
    let totalIncome: Double
    let totalExpense: Double
    let transactionCount: Int

    private var net: Double {
        totalIncome - totalExpense
    }

    private var savingsRate: Double {
        guard totalIncome > 0 else { return 0 }
        return (net / totalIncome) * 100
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Overview")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.moneyAccent)
                Text("\(transactionCount) transactions in your history")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            HStack(spacing: 10) {
                analyticsChip(title: "Income", value: formatCurrency(totalIncome), colors: [.moneyIncome, .moneyIncome.opacity(0.5)])
                analyticsChip(title: "Expenses", value: formatCurrency(totalExpense), colors: [.moneyExpense, .moneyExpense.opacity(0.5)])
            }

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Net balance")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(formatSignedNet(net))
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundColor(net >= 0 ? Color.moneyIncome : Color.moneyExpense)
                }
                Spacer(minLength: 12)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Savings rate")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(totalIncome > 0 ? String(format: "%.0f%%", min(max(savingsRate, -999), 999)) : "—")
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundColor(savingsRate >= 0 ? Color.moneyIncome.opacity(0.95) : Color.moneyExpense.opacity(0.95))
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.moneyAccent.opacity(0.24),
                            Color.moneyExpense.opacity(0.06),
                            Color.white.opacity(0.05),
                            Color.black.opacity(0.3)
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
                        colors: [Color.moneyAccent.opacity(0.45), Color.moneyExpense.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 22)
        .moneyMapDepthShadow(accent: .moneyAccent)
    }

    private func analyticsChip(title: String, value: String, colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.4)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(colors: colors.map { $0.opacity(0.22) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    LinearGradient(colors: colors.map { $0.opacity(0.45) }, startPoint: .leading, endPoint: .trailing),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 14)
        .moneyMapChipShadow(accent: colors.first ?? .moneyAccent)
    }
}

private func formatSignedNet(_ amount: Double) -> String {
    let base = formatCurrency(abs(amount))
    if amount > 0 { return "+\(base)" }
    if amount < 0 { return "-\(base)" }
    return base
}
