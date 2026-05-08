//
//  HomeView.swift
//  151MoneyMap
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @Binding var selectedTab: Int

    @State private var showAddTransaction = false
    @State private var showSettings = false
    @State private var selectedTransaction: Transaction?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                background

                ScrollView {
                    LazyVStack(spacing: 16) {
                        header

                        BalanceHeroWidget(
                            balance: viewModel.balance,
                            income: viewModel.totalIncome,
                            expense: viewModel.totalExpense,
                            savingsRate: viewModel.savingsRate,
                            monthCaption: currentMonthYearTitle(),
                            transactionCount: viewModel.transactions.count
                        )

                        QuickNavStrip(selectedTab: $selectedTab)

                        CashFlowWidget(
                            income: viewModel.totalIncome,
                            expense: viewModel.totalExpense
                        )

                        SpendingPieWidget(
                            expenseByCategory: viewModel.expenseByCategory,
                            onSeeAnalytics: { selectedTab = 4 }
                        )

                        if !viewModel.budgets.isEmpty {
                            BudgetsStripWidget(
                                budgets: Array(viewModel.budgets.prefix(6)),
                                onSeeAll: { selectedTab = 2 }
                            )
                        }

                        if !viewModel.savingsGoals.isEmpty {
                            GoalsStripWidget(
                                goals: Array(
                                    viewModel.savingsGoals
                                        .sorted { $0.priority > $1.priority }
                                        .prefix(4)
                                ),
                                onSeeAll: { selectedTab = 3 }
                            )
                        }

                        RecentActivityWidget(viewModel: viewModel) { tx in
                            selectedTransaction = tx
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }

                addButton
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView(viewModel: viewModel)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailView(viewModel: viewModel, transactionId: transaction.id)
            }
        }
    }

    private var background: some View {
        MoneyMapBackdrop(kind: .home)
            .ignoresSafeArea()
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Home")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.moneyAccent)
                Text(currentMonthYearTitle())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.moneyAccent)
                    .shadow(color: Color.moneyAccent.opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
        .padding(.top, 4)
    }

    private var addButton: some View {
        Button {
            showAddTransaction = true
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 56))
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.moneyAccent, .white)
                .shadow(color: Color.black.opacity(0.55), radius: 16, x: 0, y: 10)
                .shadow(color: Color.moneyAccent.opacity(0.45), radius: 22, x: 0, y: 8)
        }
        .padding(.trailing, 22)
        .padding(.bottom, 22)
        .accessibilityLabel("Add transaction")
    }
}
