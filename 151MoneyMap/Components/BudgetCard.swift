//
//  BudgetCard.swift
//  151MoneyMap
//

import SwiftUI

struct BudgetCard: View {
    let budget: Budget

    private var statusColor: Color {
        if budget.remaining < 0 { return .moneyExpense }
        if budget.progress > 0.85 { return .moneyExpense.opacity(0.9) }
        return .moneyAccent
    }

    private var ringGradient: AngularGradient {
        AngularGradient(
            colors: budget.remaining < 0
                ? [.moneyExpense, .moneyExpense.opacity(0.55)]
                : [.moneyAccent, .moneyIncome.opacity(0.85), .moneyAccent],
            center: .center
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 8)
                    .frame(width: 72, height: 72)

                Circle()
                    .trim(from: 0, to: CGFloat(min(budget.progress, 1)))
                    .stroke(ringGradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(-90))

                if budget.remaining < 0 {
                    Image(systemName: "exclamationmark")
                        .font(.caption.weight(.black))
                        .foregroundColor(.moneyExpense)
                } else {
                    Text("\(Int(min(budget.progress, 1) * 100))%")
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: budget.category.icon)
                        .font(.title3)
                        .foregroundColor(budget.category.type.color)
                        .frame(width: 28, alignment: .center)

                    Text(budget.category.rawValue)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)

                    Spacer(minLength: 8)

                    Capsule()
                        .fill(statusColor.opacity(0.22))
                        .overlay(
                            Text(budget.remaining < 0 ? "Over" : "On track")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(statusColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                        )
                        .fixedSize()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [statusColor.opacity(0.9), statusColor.opacity(0.45)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, geo.size.width * CGFloat(min(budget.progress, 1))))
                    }
                }
                .frame(height: 7)

                HStack {
                    Text("\(formatCurrency(budget.spent)) spent")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Limit \(formatCurrency(budget.limit))")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.gray)
                }

                if budget.remaining < 0 {
                    Text("Over by \(formatCurrency(abs(budget.remaining)))")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.moneyExpense)
                } else {
                    Text("\(formatCurrency(budget.remaining)) left")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.moneyIncome)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.05),
                            Color.moneyAccent.opacity(0.04),
                            Color.black.opacity(0.26)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            statusColor.opacity(budget.remaining < 0 ? 0.55 : 0.28),
                            Color.moneyAccent.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 20)
        .moneyMapDepthShadow(accent: statusColor)
    }
}
