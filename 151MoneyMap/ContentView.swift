//
//  ContentView.swift
//  151MoneyMap
//
//  Created by Roman on 5/5/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(MoneyMapOnboardingStorage.completedKey) private var onboardingCompleted = false
    @StateObject private var viewModel = MoneyMapViewModel()
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if onboardingCompleted {
                TabView(selection: $selectedTab) {
                    HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)

                    TransactionsListView(viewModel: viewModel)
                        .tabItem {
                            Label("Activity", systemImage: "list.bullet.rectangle")
                        }
                        .tag(1)

                    BudgetView(viewModel: viewModel)
                        .tabItem {
                            Label("Budget", systemImage: "chart.pie.fill")
                        }
                        .tag(2)

                    GoalsView(viewModel: viewModel)
                        .tabItem {
                            Label("Goals", systemImage: "target")
                        }
                        .tag(3)

                    AnalyticsView(viewModel: viewModel)
                        .tabItem {
                            Label("Analytics", systemImage: "chart.bar.fill")
                        }
                        .tag(4)
                }
                .onAppear {
                    viewModel.loadFromUserDefaults()
                }
                .tint(.moneyAccent)
            } else {
                OnboardingView {
                    viewModel.loadFromUserDefaults()
                    onboardingCompleted = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
