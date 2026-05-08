//
//  BudgetView.swift
//  151MoneyMap
//

import SwiftUI

struct BudgetView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @State private var showAddBudgetSheet = false
    @State private var budgetToEdit: Budget?
    @State private var anchorMonth: Date = {
        let cal = Calendar.current
        let parts = cal.dateComponents([.year, .month], from: Date())
        return cal.date(from: parts) ?? Date()
    }()

    private var monthYear: (month: Int, year: Int) {
        let cal = Calendar.current
        return (
            cal.component(.month, from: anchorMonth),
            cal.component(.year, from: anchorMonth)
        )
    }

    private var budgetsThisPeriod: [Budget] {
        let (m, y) = monthYear
        return viewModel.budgets
            .filter { $0.month == m && $0.year == y }
            .sorted { lhs, rhs in
                let lhsOver = lhs.remaining < 0
                let rhsOver = rhs.remaining < 0
                if lhsOver != rhsOver {
                    return lhsOver
                }
                return lhs.progress > rhs.progress
            }
    }

    private var totalLimit: Double {
        budgetsThisPeriod.reduce(0) { $0 + $1.limit }
    }

    private var totalSpent: Double {
        budgetsThisPeriod.reduce(0) { $0 + $1.spent }
    }

    private var overBudgetCount: Int {
        budgetsThisPeriod.filter { $0.remaining < 0 }.count
    }

    private var softAlertsThisPeriod: [BudgetSoftAlert] {
        let ids = Set(budgetsThisPeriod.map(\.id))
        return viewModel.budgetSoftAlerts.filter { ids.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MoneyMapBackdrop(kind: .budget)
                    .ignoresSafeArea()

                List {
                    Section {
                        BudgetMonthHeader(anchorMonth: $anchorMonth)
                            .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)

                        if budgetsThisPeriod.isEmpty {
                            emptyPeriodCard
                                .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        } else {
                            BudgetHeroSummary(
                                totalLimit: totalLimit,
                                totalSpent: totalSpent,
                                budgetCount: budgetsThisPeriod.count,
                                overBudgetCount: overBudgetCount
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 12, trailing: 12))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }

                        if !softAlertsThisPeriod.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("BUDGET ALERTS")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.gray)
                                ForEach(softAlertsThisPeriod) { alert in
                                    HStack(alignment: .top, spacing: 10) {
                                        Image(systemName: alert.level >= 100 ? "exclamationmark.octagon.fill" : "exclamationmark.circle.fill")
                                            .foregroundColor(alert.level >= 100 ? Color.moneyExpense : Color.moneyAccent)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(alert.categoryName)
                                                .font(.caption.weight(.semibold))
                                                .foregroundColor(.white)
                                            Text(alert.message)
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.moneyExpense.opacity(alert.level >= 100 ? 0.18 : 0.1))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .strokeBorder(Color.moneyExpense.opacity(alert.level >= 100 ? 0.45 : 0.25), lineWidth: 1)
                                    )
                                    .moneyMapSpecularRim(cornerRadius: 12)
                                    .moneyMapChipShadow(accent: .moneyExpense)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 8, trailing: 12))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }

                    if !budgetsThisPeriod.isEmpty {
                        Section {
                            ForEach(budgetsThisPeriod) { budget in
                                BudgetCard(budget: budget)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            viewModel.deleteBudget(budget)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }

                                        Button {
                                            budgetToEdit = budget
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.moneyAccent)
                                    }
                            }
                        } header: {
                            sectionHeader(title: "Categories", subtitle: "Swipe for actions")
                        }
                    }

                    Section {
                        Button {
                            showAddBudgetSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("New budget")
                                    .font(.headline.weight(.semibold))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.moneyAccent.opacity(0.45), Color.moneyAccent.opacity(0.2)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                            )
                            .moneyMapSpecularRim(cornerRadius: 16)
                            .moneyMapDepthShadow(accent: .moneyAccent)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 10, leading: 12, bottom: 20, trailing: 12))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moneyBackground.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddBudgetSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.moneyAccent, Color.white.opacity(0.9))
                    }
                    .accessibilityLabel("Add budget")
                }
            }
            .sheet(isPresented: $showAddBudgetSheet) {
                AddBudgetView(viewModel: viewModel, presetMonth: monthYear.month, presetYear: monthYear.year)
            }
            .sheet(item: $budgetToEdit) { budget in
                EditBudgetView(viewModel: viewModel, budget: budget)
            }
        }
    }

    private var emptyPeriodCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(colors: [.moneyAccent, .moneyAccent.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                )
            Text("No budgets for this month")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
            Text("Create limits for categories to track spending against your plan.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Button {
                showAddBudgetSheet = true
            } label: {
                Text("Create budget")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.moneyAccent))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.moneyAccent.opacity(0.08),
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
                        colors: [Color.moneyAccent.opacity(0.35), Color.moneyAccent.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 22)
        .moneyMapDepthShadow(accent: .moneyAccent)
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundColor(.gray)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.75))
            }
            Spacer()
        }
        .textCase(nil)
        .padding(.top, 4)
    }
}
