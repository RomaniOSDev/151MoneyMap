//
//  MoneyMapVisualChrome.swift
//  151MoneyMap
//

import SwiftUI

// MARK: - Screen backdrops

enum MoneyMapBackdropKind {
    case home
    case activity
    case budget
    case goals
    case analytics

    fileprivate var primaryOrb: Color {
        switch self {
        case .home: return Color.moneyAccent
        case .activity: return Color.moneyAccent
        case .budget: return Color.moneyAccent
        case .goals: return Color.moneyIncome
        case .analytics: return Color.moneyAccent
        }
    }

    fileprivate var secondaryOrb: Color {
        switch self {
        case .home: return Color.moneyIncome
        case .activity: return Color.moneyIncome
        case .budget: return Color.moneyExpense.opacity(0.85)
        case .goals: return Color.moneyAccent
        case .analytics: return Color.moneyExpense
        }
    }

    fileprivate var linearWash: [Color] {
        switch self {
        case .home:
            return [
                Color.moneyBackground,
                Color.moneyAccent.opacity(0.1),
                Color.moneyBackground,
                Color.moneyIncome.opacity(0.06)
            ]
        case .activity:
            return [
                Color.moneyBackground,
                Color.moneyAccent.opacity(0.09),
                Color.moneyBackground,
                Color.moneyIncome.opacity(0.05)
            ]
        case .budget:
            return [
                Color.moneyBackground,
                Color.moneyAccent.opacity(0.08),
                Color.moneyBackground,
                Color.moneyExpense.opacity(0.05)
            ]
        case .goals:
            return [
                Color.moneyBackground,
                Color.moneyIncome.opacity(0.08),
                Color.moneyBackground,
                Color.moneyAccent.opacity(0.06)
            ]
        case .analytics:
            return [
                Color.moneyBackground,
                Color.moneyAccent.opacity(0.09),
                Color.moneyBackground,
                Color.moneyExpense.opacity(0.06)
            ]
        }
    }
}

struct MoneyMapBackdrop: View {
    var kind: MoneyMapBackdropKind

    var body: some View {
        ZStack {
            Color.moneyBackground

            RadialGradient(
                colors: [kind.primaryOrb.opacity(0.22), Color.clear],
                center: UnitPoint(x: 0.12, y: 0.1),
                startRadius: 8,
                endRadius: 420
            )

            RadialGradient(
                colors: [kind.secondaryOrb.opacity(0.16), Color.clear],
                center: UnitPoint(x: 0.9, y: 0.92),
                startRadius: 16,
                endRadius: 380
            )

            LinearGradient(
                colors: kind.linearWash,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Depth: subtle floor shadow
            LinearGradient(
                colors: [Color.clear, Color.clear, Color.black.opacity(0.38)],
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.multiply)
            .opacity(0.85)

            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.45)],
                center: .center,
                startRadius: 100,
                endRadius: 520
            )
            .blendMode(.multiply)
            .opacity(0.55)
        }
    }
}

// MARK: - Card / panel chrome

extension View {
    /// Soft top-edge highlight for glass panels.
    func moneyMapSpecularRim(cornerRadius: CGFloat) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.34), location: 0),
                            .init(color: Color.white.opacity(0.08), location: 0.38),
                            .init(color: Color.clear, location: 0.58)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
                .allowsHitTesting(false)
        )
    }

    /// Layered drop + accent glow for floating cards.
    func moneyMapDepthShadow(accent: Color = .moneyAccent) -> some View {
        compositingGroup()
            .shadow(color: Color.black.opacity(0.58), radius: 22, x: 0, y: 14)
            .shadow(color: accent.opacity(0.26), radius: 42, x: 0, y: 16)
            .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
    }

    /// Lighter shadow for nested chips / small controls.
    func moneyMapChipShadow(accent: Color = .moneyAccent) -> some View {
        compositingGroup()
            .shadow(color: Color.black.opacity(0.45), radius: 10, x: 0, y: 6)
            .shadow(color: accent.opacity(0.18), radius: 14, x: 0, y: 5)
    }
}
