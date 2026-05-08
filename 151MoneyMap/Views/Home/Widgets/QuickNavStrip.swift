//
//  QuickNavStrip.swift
//  151MoneyMap
//

import SwiftUI

struct QuickNavStrip: View {
    @Binding var selectedTab: Int

    private let items: [(tab: Int, title: String, icon: String)] = [
        (2, "Budget", "chart.pie.fill"),
        (3, "Goals", "target"),
        (4, "Analytics", "chart.bar.fill")
    ]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(items, id: \.tab) { item in
                Button {
                    selectedTab = item.tab
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: item.icon)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.moneyAccent)
                        Text(item.title)
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.white.opacity(0.88))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.moneyAccent.opacity(0.1),
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
                                    colors: [Color.moneyAccent.opacity(0.42), Color.moneyAccent.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .moneyMapSpecularRim(cornerRadius: 16)
                    .moneyMapChipShadow(accent: .moneyAccent)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
