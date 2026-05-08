//
//  TransactionRow.swift
//  151MoneyMap
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    var accounts: [Account] = []

    private var iconGradient: [Color] {
        switch transaction.type {
        case .income:
            return [.moneyIncome, .moneyIncome.opacity(0.5)]
        case .expense:
            return [.moneyExpense, .moneyExpense.opacity(0.5)]
        case .transfer:
            return [.moneyAccent, .moneyAccent.opacity(0.45)]
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: iconGradient.map { $0.opacity(0.28) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 46, height: 46)
                Image(systemName: transaction.displayIconName())
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: iconGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.displayTitle(accounts: accounts))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(formattedDate(transaction.date))
                    .font(.caption2)
                    .foregroundColor(.gray)

                if let note = transaction.note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.92))
                        .lineLimit(2)
                }

                if !transaction.tags.isEmpty {
                    Text(transaction.tags.map { "#\($0)" }.joined(separator: " "))
                        .font(.caption2)
                        .foregroundColor(.moneyAccent.opacity(0.92))
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                Text(transaction.formattedAmount)
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(
                        LinearGradient(colors: [transaction.type.color, transaction.type.color.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
                    )

                if transaction.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.moneyAccent)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            iconGradient[0].opacity(0.08),
                            Color.white.opacity(0.03),
                            Color.black.opacity(0.32)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.14), iconGradient[0].opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 18)
        .moneyMapDepthShadow(accent: transaction.type == .expense ? Color.moneyExpense : (transaction.type == .income ? Color.moneyIncome : Color.moneyAccent))
    }
}
