//
//  SettingsView.swift
//  151MoneyMap
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                MoneyMapBackdrop(kind: .home)
                    .ignoresSafeArea()

                List {
                    Section {
                        settingsRow(
                            title: "Rate us",
                            icon: "star.fill",
                            tint: .moneyAccent
                        ) {
                            rateApp()
                        }

                        settingsRow(
                            title: "Privacy Policy",
                            icon: "hand.raised.fill",
                            tint: .moneyIncome
                        ) {
                            openPolicy(.privacyPolicy)
                        }

                        settingsRow(
                            title: "Terms of Use",
                            icon: "doc.text.fill",
                            tint: .moneyAccent
                        ) {
                            openPolicy(.termsOfUse)
                        }
                    } header: {
                        Text("Support & legal")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.gray)
                            .textCase(nil)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moneyBackground.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundColor(.moneyAccent)
                }
            }
        }
    }

    private func settingsRow(title: String, icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [tint, tint.opacity(0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 28, alignment: .center)

                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.gray.opacity(0.7))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.03),
                                Color.black.opacity(0.22)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
            .moneyMapSpecularRim(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    private func openPolicy(_ link: AppExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
