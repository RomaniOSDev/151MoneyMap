//
//  ActivityHeroSummary.swift
//  151MoneyMap
//

import SwiftUI

struct ActivityHeroSummary: View {
    let transactions: [Transaction]
    var filterActive: Bool = false

    private var incomeTotal: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    private var expenseTotal: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var transferCount: Int {
        transactions.filter { $0.type == .transfer }.count
    }

    private var net: Double {
        incomeTotal - expenseTotal
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(filterActive ? "Filtered snapshot" : "On this list")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.moneyAccent)
                    Text("\(transactions.count) transactions")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
                if transferCount > 0 {
                    Label("\(transferCount) transfers", systemImage: TransactionType.transfer.icon)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.moneyAccent.opacity(0.95))
                }
            }

            HStack(spacing: 10) {
                activityStatChip(
                    title: "In",
                    value: formatCurrency(incomeTotal),
                    gradient: [.moneyIncome, .moneyIncome.opacity(0.55)],
                    icon: TransactionType.income.icon
                )
                activityStatChip(
                    title: "Out",
                    value: formatCurrency(expenseTotal),
                    gradient: [.moneyExpense, .moneyExpense.opacity(0.55)],
                    icon: TransactionType.expense.icon
                )
            }

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Net (income − expense)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(formatSignedCurrency(net))
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundColor(net >= 0 ? Color.moneyIncome : Color.moneyExpense)
                }
                Spacer(minLength: 12)
                miniFlowBars(income: incomeTotal, expense: expenseTotal)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.moneyAccent.opacity(0.22),
                            Color.moneyIncome.opacity(0.08),
                            Color.white.opacity(0.05),
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
                        colors: [Color.moneyAccent.opacity(0.45), Color.moneyIncome.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 22)
        .moneyMapDepthShadow(accent: .moneyAccent)
    }

    private func activityStatChip(title: String, value: String, gradient: [Color], icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption2.weight(.semibold))
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
                    LinearGradient(colors: gradient.map { $0.opacity(0.22) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: gradient.map { $0.opacity(0.45) },
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 14)
        .moneyMapChipShadow(accent: gradient.first ?? .moneyAccent)
    }

    private func miniFlowBars(income: Double, expense: Double) -> some View {
        let total = income + expense
        return VStack(alignment: .trailing, spacing: 6) {
            Text("Mix")
                .font(.caption2)
                .foregroundColor(.gray)
            GeometryReader { geo in
                let w = geo.size.width
                Group {
                    if total <= 0 {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color.white.opacity(0.14))
                            .frame(width: w)
                    } else {
                        HStack(spacing: 2) {
                            if income > 0 {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(Color.moneyIncome.opacity(0.9))
                                    .frame(width: max(3, w * CGFloat(income / total)))
                            }
                            if expense > 0 {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(Color.moneyExpense.opacity(0.9))
                                    .frame(width: max(3, w * CGFloat(expense / total)))
                            }
                        }
                    }
                }
            }
            .frame(width: 72, height: 8)
        }
    }
}

private func formatSignedCurrency(_ amount: Double) -> String {
    let base = formatCurrency(abs(amount))
    if amount > 0 { return "+\(base)" }
    if amount < 0 { return "-\(base)" }
    return base
}
