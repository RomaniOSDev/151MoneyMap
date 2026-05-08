//
//  OnboardingView.swift
//  151MoneyMap
//

import SwiftUI

enum MoneyMapOnboardingStorage {
    static let completedKey = "moneyMap.onboarding.completed"
}

private struct OnboardingSlideModel: Identifiable {
    let id: Int
    let title: String
    let message: String
    let symbol: String
    let orbColors: [Color]
}

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var step = 0

    private let slides: [OnboardingSlideModel] = [
        OnboardingSlideModel(
            id: 0,
            title: "See your money clearly",
            message: "Log income, expenses, and transfers in one Activity timeline—with notes, tags, and fast search.",
            symbol: "list.bullet.rectangle.fill",
            orbColors: [.moneyAccent, .moneyIncome]
        ),
        OnboardingSlideModel(
            id: 1,
            title: "Budget with confidence",
            message: "Set monthly limits by category, watch progress rings, and catch overspending before it surprises you.",
            symbol: "chart.pie.fill",
            orbColors: [.moneyAccent, .moneyExpense.opacity(0.9)]
        ),
        OnboardingSlideModel(
            id: 2,
            title: "Save toward what matters",
            message: "Define savings goals, prioritize them, and follow trends on Analytics when you are ready.",
            symbol: "target",
            orbColors: [.moneyIncome, .moneyAccent]
        )
    ]

    private var isLast: Bool {
        step == slides.count - 1
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width

            ZStack {
                MoneyMapBackdrop(kind: .home)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerBar
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    GeometryReader { slideGeo in
                        HStack(spacing: 0) {
                            ForEach(slides) { slide in
                                OnboardingSlidePage(model: slide)
                                    .frame(width: width, height: slideGeo.size.height)
                            }
                        }
                        .offset(x: -CGFloat(step) * width)
                        .animation(.spring(response: 0.48, dampingFraction: 0.86), value: step)
                        .gesture(
                            DragGesture(minimumDistance: 28)
                                .onEnded { value in
                                    let dx = value.translation.width
                                    if dx < -48, step < slides.count - 1 {
                                        step += 1
                                    } else if dx > 48, step > 0 {
                                        step -= 1
                                    }
                                }
                        )
                    }

                    footerBar
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var headerBar: some View {
        HStack {
            Spacer(minLength: 0)
            Button("Skip") {
                onFinish()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.moneyAccent)
        }
        .accessibilityElement(children: .contain)
    }

    private var footerBar: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(0..<slides.count, id: \.self) { i in
                    Capsule()
                        .fill(i == step ? Color.moneyAccent : Color.white.opacity(0.22))
                        .frame(width: i == step ? 22 : 7, height: 7)
                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: step)
                }
            }
            .accessibilityLabel("Page \(step + 1) of \(slides.count)")

            HStack(spacing: 14) {
                if step > 0 {
                    Button {
                        step -= 1
                    } label: {
                        Text("Back")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Go to previous screen")
                }

                Button {
                    if isLast {
                        onFinish()
                    } else {
                        step += 1
                    }
                } label: {
                    Text(isLast ? "Get started" : "Continue")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.moneyAccent, Color.moneyIncome.opacity(0.88)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                        )
                        .moneyMapSpecularRim(cornerRadius: 16)
                        .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 10)
                        .shadow(color: Color.moneyAccent.opacity(0.28), radius: 22, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .accessibilityHint(isLast ? "Finish onboarding" : "Go to next screen")
            }
        }
    }
}

private struct OnboardingSlidePage: View {
    let model: OnboardingSlideModel

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                model.orbColors[0].opacity(0.45),
                                model.orbColors[1].opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 200, height: 200)

                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                model.orbColors[0].opacity(0.5),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 168, height: 168)

                Image(systemName: model.symbol)
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: model.orbColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: model.orbColors[0].opacity(0.45), radius: 18, x: 0, y: 8)
            }

            VStack(spacing: 14) {
                Text(model.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Text(model.message)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 12)
            }

            Spacer(minLength: 24)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    OnboardingView(onFinish: {})
        .preferredColorScheme(.dark)
}
