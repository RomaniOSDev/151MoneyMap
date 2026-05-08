//
//  GoalCard.swift
//  151MoneyMap
//

import SwiftUI

struct GoalCard: View {
    let goal: SavingsGoal

    private var ringTint: AngularGradient {
        if goal.isCompleted {
            return AngularGradient(colors: [.moneyIncome, .moneyIncome.opacity(0.65)], center: .center)
        }
        return AngularGradient(
            colors: [.moneyAccent, .moneyIncome.opacity(0.85), .moneyAccent],
            center: .center
        )
    }

    private var frameTint: LinearGradient {
        if goal.isCompleted {
            return LinearGradient(colors: [Color.moneyIncome.opacity(0.45), Color.moneyAccent.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: [Color.moneyAccent.opacity(0.35), Color.moneyAccent.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 8)
                    .frame(width: 76, height: 76)

                Circle()
                    .trim(from: 0, to: CGFloat(min(goal.progress, 1)))
                    .stroke(ringTint, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 76, height: 76)
                    .rotationEffect(.degrees(-90))

                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.moneyIncome)
                } else {
                    Text("\(Int(min(goal.progress, 1) * 100))%")
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "scope")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(
                            LinearGradient(colors: [.moneyAccent, .moneyIncome], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )

                    Text(goal.name)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Spacer(minLength: 6)

                    VStack(alignment: .trailing, spacing: 6) {
                        if goal.priority > 0 {
                            Text("P\(goal.priority)")
                                .font(.caption2.weight(.heavy))
                                .foregroundColor(.moneyAccent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(Color.moneyAccent.opacity(0.18))
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.moneyAccent.opacity(0.35), lineWidth: 0.5)
                                )
                        }
                        if goal.isCompleted {
                            Text("Done")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.moneyIncome)
                        }
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: goal.isCompleted
                                        ? [.moneyIncome, .moneyIncome.opacity(0.55)]
                                        : [.moneyAccent, .moneyIncome.opacity(0.75)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(8, geo.size.width * CGFloat(min(goal.progress, 1))))
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("\(formatCurrency(goal.currentAmount))")
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                        .foregroundColor(.white)
                    Text("/")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatCurrency(goal.targetAmount))
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.gray)
                    Spacer()
                    Text(goal.formattedProgress)
                        .font(.caption.weight(.bold))
                        .foregroundColor(.moneyAccent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let weekly = goal.weeklyContributionTarget, weekly > 0 {
                        Label("\(formatCurrency(weekly)) / week", systemImage: "calendar")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.gray)
                    }
                    if let projected = goal.projectedCompletionDate {
                        Label("Est. \(formattedShortDate(projected))", systemImage: "sparkles")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.moneyIncome.opacity(0.95))
                    }
                    if let deadline = goal.deadline {
                        Label("Deadline \(formattedShortDate(deadline))", systemImage: "flag")
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.9))
                    }
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
                            Color.moneyAccent.opacity(0.05),
                            Color.white.opacity(0.03),
                            Color.black.opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(frameTint, lineWidth: 1)
        )
        .moneyMapSpecularRim(cornerRadius: 20)
        .moneyMapDepthShadow(accent: goal.isCompleted ? Color.moneyIncome : Color.moneyAccent)
    }
}
