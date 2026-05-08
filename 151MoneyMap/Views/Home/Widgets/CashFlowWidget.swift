//
//  CashFlowWidget.swift
//  151MoneyMap
//

import SwiftUI

struct CashFlowWidget: View {
    let income: Double
    let expense: Double

    private var scale: Double {
        max(income, expense, 1)
    }

    var body: some View {
        HomeWidgetShell(
            title: "Cash flow",
            subtitle: "Relative scale this period"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                flowRow(
                    label: "Income",
                    amount: income,
                    tint: .moneyIncome,
                    fraction: income / scale
                )
                flowRow(
                    label: "Expenses",
                    amount: expense,
                    tint: .moneyExpense,
                    fraction: expense / scale
                )
            }
        }
    }

    private func flowRow(label: String, amount: Double, tint: Color, fraction: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(tint)
                Spacer()
                Text(formatCurrency(amount))
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundColor(.white)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [tint, tint.opacity(0.65)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(6, geo.size.width * CGFloat(min(fraction, 1))))
                }
            }
            .frame(height: 9)
        }
    }
}
