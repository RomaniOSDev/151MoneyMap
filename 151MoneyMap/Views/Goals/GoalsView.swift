//
//  GoalsView.swift
//  151MoneyMap
//

import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @State private var showAddGoalSheet = false
    @State private var goalToFund: SavingsGoal?
    @State private var goalToEdit: SavingsGoal?

    private var sortedGoals: [SavingsGoal] {
        viewModel.savingsGoals.sorted { lhs, rhs in
            if lhs.priority != rhs.priority { return lhs.priority > rhs.priority }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    private var activeGoals: [SavingsGoal] {
        sortedGoals.filter { !$0.isCompleted }
    }

    private var completedGoals: [SavingsGoal] {
        sortedGoals.filter(\.isCompleted)
    }

    private var totalSavedActive: Double {
        activeGoals.reduce(0) { $0 + $1.currentAmount }
    }

    private var totalTargetActive: Double {
        activeGoals.reduce(0) { $0 + $1.targetAmount }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MoneyMapBackdrop(kind: .goals)
                    .ignoresSafeArea()

                List {
                    Section {
                        if sortedGoals.isEmpty {
                            goalsEmptyCard
                                .listRowInsets(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        } else {
                            GoalsHeroSummary(
                                totalSaved: totalSavedActive,
                                totalTarget: totalTargetActive,
                                activeCount: activeGoals.count,
                                completedCount: completedGoals.count,
                                celebrationOnly: activeGoals.isEmpty && !completedGoals.isEmpty
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 14, bottom: 12, trailing: 14))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }

                    if !sortedGoals.isEmpty {
                        Section {
                            ForEach(sortedGoals) { goal in
                                GoalCard(goal: goal)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .contentShape(Rectangle())
                                    .onTapGesture { goalToEdit = goal }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            viewModel.deleteGoal(goal)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }

                                        Button {
                                            goalToFund = goal
                                        } label: {
                                            Label("Add funds", systemImage: "plus")
                                        }
                                        .tint(.moneyIncome)

                                        Button {
                                            goalToEdit = goal
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.moneyAccent)
                                    }
                            }
                        } header: {
                            goalsSectionHeader
                        }
                    }

                    Section {
                        Button {
                            showAddGoalSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("New goal")
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
                                            colors: [Color.moneyIncome.opacity(0.42), Color.moneyAccent.opacity(0.28)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                            )
                            .moneyMapSpecularRim(cornerRadius: 16)
                            .moneyMapDepthShadow(accent: .moneyIncome)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 10, leading: 14, bottom: 22, trailing: 14))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moneyBackground.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddGoalSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.moneyIncome, Color.white.opacity(0.92))
                    }
                    .accessibilityLabel("Add goal")
                }
            }
            .sheet(isPresented: $showAddGoalSheet) {
                AddGoalView(viewModel: viewModel)
            }
            .sheet(item: $goalToFund) { goal in
                ContributeToGoalView(viewModel: viewModel, goal: goal)
            }
            .sheet(item: $goalToEdit) { goal in
                EditGoalView(viewModel: viewModel, goal: goal)
            }
        }
    }

    private var goalsSectionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("ALL GOALS")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundColor(.gray)
                Text("Tap to edit · swipe for actions")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.75))
            }
            Spacer()
        }
        .textCase(nil)
        .padding(.top, 4)
    }

    private var goalsEmptyCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "scope")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(colors: [.moneyAccent, .moneyIncome], startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Text("Start your first goal")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)

            Text("Track savings with priorities, weekly plans, and projected completion dates.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Button {
                showAddGoalSheet = true
            } label: {
                Text("Create goal")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(colors: [.moneyAccent, .moneyIncome.opacity(0.85)], startPoint: .leading, endPoint: .trailing)
                            )
                    )
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
                            Color.white.opacity(0.11),
                            Color.moneyIncome.opacity(0.08),
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
                        colors: [Color.moneyAccent.opacity(0.4), Color.moneyIncome.opacity(0.22)],
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
