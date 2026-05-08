//
//  GoalsHeroSummary.swift
//  151MoneyMap
//

import SwiftUI

struct GoalsHeroSummary: View {
    let totalSaved: Double
    let totalTarget: Double
    let activeCount: Int
    let completedCount: Int
    /// Active list empty but there are completed goals.
    var celebrationOnly: Bool = false

    private var ringProgress: Double {
        guard totalTarget > 0 else { return 0 }
        return min(totalSaved / totalTarget, 1)
    }

    private var percentDisplay: Int {
        guard totalTarget > 0 else { return 0 }
        return Int(min(totalSaved / totalTarget, 2) * 100)
    }

    var body: some View {
        if celebrationOnly {
            celebrationBlock
        } else {
            ringBlock
        }
    }

    private var celebrationBlock: some View {
        HStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(colors: [.moneyIncome, .moneyIncome.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                )
            VStack(alignment: .leading, spacing: 8) {
                Text("All active goals completed")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                Text("\(completedCount) finished · tap + to plan what’s next.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.moneyIncome.opacity(0.28),
                            Color.white.opacity(0.06),
                            Color.black.opacity(0.26)
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
                        colors: [Color.moneyIncome.opacity(0.55), Color.moneyAccent.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 22)
        .moneyMapDepthShadow(accent: .moneyIncome)
    }

    private var ringBlock: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: CGFloat(ringProgress))
                    .stroke(
                        AngularGradient(
                            colors: [.moneyAccent, .moneyIncome, .moneyAccent.opacity(0.75)],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(percentDisplay)%")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(.white)
                    Text("toward targets")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.gray)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Your savings map")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.moneyAccent)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(formatCurrency(totalSaved))
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundColor(.white)
                    Text("of")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatCurrency(totalTarget))
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                        .foregroundColor(.gray)
                }

                HStack(spacing: 14) {
                    Label("\(activeCount) active", systemImage: "target")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.gray)
                    if completedCount > 0 {
                        Label("\(completedCount) done", systemImage: "checkmark.seal.fill")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.moneyIncome)
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
                            Color.moneyIncome.opacity(0.26),
                            Color.moneyAccent.opacity(0.08),
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
                        colors: [Color.moneyIncome.opacity(0.45), Color.moneyAccent.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 22)
        .moneyMapDepthShadow(accent: .moneyIncome)
    }
}
