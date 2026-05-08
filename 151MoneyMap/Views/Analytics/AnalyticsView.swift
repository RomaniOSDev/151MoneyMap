//
//  AnalyticsView.swift
//  151MoneyMap
//

import Charts
import SwiftUI

private struct MonthlyBarPoint: Identifiable {
    let id: String
    let month: String
    let series: String
    let amount: Double
}

struct AnalyticsView: View {
    @ObservedObject var viewModel: MoneyMapViewModel

    private var monthlyBarPoints: [MonthlyBarPoint] {
        viewModel.monthlyData.flatMap { d in
            [
                MonthlyBarPoint(id: "\(d.id)-i", month: d.month, series: "Income", amount: d.income),
                MonthlyBarPoint(id: "\(d.id)-e", month: d.month, series: "Expense", amount: d.expense)
            ]
        }
    }

    private var topExpenseMax: Double {
        viewModel.topExpenseCategories.map(\.amount).max() ?? 1
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MoneyMapBackdrop(kind: .analytics)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if viewModel.transactions.isEmpty {
                            analyticsEmptyCard
                        } else {
                            AnalyticsHeroSummary(
                                totalIncome: viewModel.totalIncome,
                                totalExpense: viewModel.totalExpense,
                                transactionCount: viewModel.transactions.count
                            )
                        }

                        monthCompareSection
                        dynamicsSection
                        topExpensesSection
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moneyBackground.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var monthCompareSection: some View {
        analyticsSectionChrome {
            VStack(alignment: .leading, spacing: 4) {
                Text("THIS MONTH VS LAST")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundColor(.gray)
                Text("Income and expenses for the current and previous calendar months.")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.78))
            }

            if viewModel.monthCompareBars.allSatisfy({ $0.value == 0 }) {
                Text("Log transactions with dates in these months to see bars here.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Chart(viewModel.monthCompareBars) { row in
                    BarMark(
                        x: .value("Period", row.label),
                        y: .value("Amount", row.value)
                    )
                    .foregroundStyle(row.isIncome ? Color.moneyIncome : Color.moneyExpense)
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { val in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.07))
                        AxisValueLabel {
                            if let v = val.as(Double.self) {
                                Text(compactCurrency(v))
                                    .font(.caption2)
                            }
                        }
                        .foregroundStyle(Color.gray.opacity(0.9))
                    }
                }
                .chartXAxis {
                    AxisMarks { val in
                        AxisValueLabel {
                            if let s = val.as(String.self) {
                                Text(s)
                                    .font(.caption2)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .foregroundStyle(Color.gray.opacity(0.95))
                    }
                }
                .frame(height: 220)
            }
        }
    }

    private var dynamicsSection: some View {
        analyticsSectionChrome {
            VStack(alignment: .leading, spacing: 4) {
                Text("MONTHLY DYNAMICS")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundColor(.gray)
                Text("Income and expenses side by side by month.")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.78))
            }

            if viewModel.monthlyData.isEmpty {
                Text("Not enough dated activity yet.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Chart(monthlyBarPoints) { pt in
                    BarMark(
                        x: .value("Month", pt.month),
                        y: .value("Amount", pt.amount)
                    )
                    .foregroundStyle(pt.series == "Income" ? Color.moneyIncome : Color.moneyExpense)
                    .position(by: .value("Series", pt.series))
                }
                .chartLegend(position: .bottom, alignment: .center)
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { val in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.white.opacity(0.07))
                        AxisValueLabel {
                            if let v = val.as(Double.self) {
                                Text(compactCurrency(v))
                                    .font(.caption2)
                            }
                        }
                        .foregroundStyle(Color.gray.opacity(0.9))
                    }
                }
                .chartXAxis {
                    AxisMarks { val in
                        AxisValueLabel {
                            if let s = val.as(String.self) {
                                Text(s)
                                    .font(.caption2)
                            }
                        }
                        .foregroundStyle(Color.gray.opacity(0.95))
                    }
                }
                .frame(height: 240)
            }
        }
    }

    private var topExpensesSection: some View {
        analyticsSectionChrome {
            VStack(alignment: .leading, spacing: 4) {
                Text("TOP EXPENSE CATEGORIES")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundColor(.gray)
                Text("Ranked by total spent across all time.")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.78))
            }

            if viewModel.topExpenseCategories.isEmpty {
                Text("No expenses recorded yet.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.topExpenseCategories, id: \.name) { category in
                        topExpenseRow(category: category, maxAmount: topExpenseMax)
                    }
                }
            }
        }
    }

    private func topExpenseRow(category: (name: String, icon: String, amount: Double), maxAmount: Double) -> some View {
        let fraction = maxAmount > 0 ? category.amount / maxAmount : 0
        return HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.moneyExpense.opacity(0.35), Color.moneyExpense.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: category.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.moneyExpense, Color.moneyExpense.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(category.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Spacer(minLength: 8)
                    Text(formatCurrency(category.amount))
                        .font(.subheadline.weight(.bold).monospacedDigit())
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.moneyExpense, Color.moneyExpense.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.moneyExpense, Color.moneyExpense.opacity(0.55)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(6, geo.size.width * CGFloat(fraction)))
                    }
                }
                .frame(height: 7)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.moneyExpense.opacity(0.06),
                            Color.black.opacity(0.28)
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
                        colors: [Color.white.opacity(0.1), Color.moneyExpense.opacity(0.22)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 16)
        .moneyMapChipShadow(accent: .moneyExpense)
    }

    private func analyticsSectionChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.moneyAccent.opacity(0.06),
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
                        colors: [Color.moneyAccent.opacity(0.35), Color.white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 22)
        .moneyMapDepthShadow(accent: .moneyAccent)
    }

    private var analyticsEmptyCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.moneyAccent, .moneyIncome.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Analytics needs data")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)

            Text("Add income and expenses on the Activity tab to unlock comparisons, trends, and category insights.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.moneyAccent.opacity(0.1),
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
                        colors: [Color.moneyAccent.opacity(0.4), Color.moneyIncome.opacity(0.15)],
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

private func compactCurrency(_ value: Double) -> String {
    let absV = abs(value)
    if absV >= 1_000_000 {
        return String(format: "$%.1fM", value / 1_000_000)
    }
    if absV >= 10_000 {
        return String(format: "$%.0fk", value / 1_000)
    }
    return formatCurrency(value)
}
