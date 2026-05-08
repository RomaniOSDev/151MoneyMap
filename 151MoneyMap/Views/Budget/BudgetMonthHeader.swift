//
//  BudgetMonthHeader.swift
//  151MoneyMap
//

import SwiftUI

struct BudgetMonthHeader: View {
    @Binding var anchorMonth: Date

    private var monthLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "MMMM yyyy"
        return f.string(from: anchorMonth)
    }

    var body: some View {
        HStack(spacing: 20) {
            Button {
                shiftMonth(-1)
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.moneyAccent)
            }
            .accessibilityLabel("Previous month")

            Spacer()

            VStack(spacing: 4) {
                Text("Period")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.gray)
                    .tracking(0.6)
                Text(monthLabel)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
            }

            Spacer()

            Button {
                shiftMonth(1)
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.moneyAccent)
            }
            .accessibilityLabel("Next month")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.moneyAccent.opacity(0.08),
                            Color.black.opacity(0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.moneyAccent.opacity(0.28), lineWidth: 1)
        )
        .moneyMapSpecularRim(cornerRadius: 18)
        .moneyMapDepthShadow(accent: .moneyAccent)
    }

    private func shiftMonth(_ delta: Int) {
        guard let d = Calendar.current.date(byAdding: .month, value: delta, to: anchorMonth) else { return }
        anchorMonth = d
    }
}
