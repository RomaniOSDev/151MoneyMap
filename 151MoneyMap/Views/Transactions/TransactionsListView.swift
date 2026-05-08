//
//  TransactionsListView.swift
//  151MoneyMap
//

import SwiftUI

struct TransactionsListView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @State private var searchText = ""
    @State private var filter = TransactionFilter()
    @State private var showFilters = false
    @State private var showAdd = false
    @State private var selectedTransaction: Transaction?
    @State private var editingTransaction: Transaction?
    @State private var showExport = false
    @State private var showRecurring = false
    @State private var showRules = false
    @State private var showAccounts = false

    private var effectiveFilter: TransactionFilter {
        var f = filter
        f.searchText = searchText
        return f
    }

    private var rows: [Transaction] {
        viewModel.transactions(matching: effectiveFilter)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MoneyMapBackdrop(kind: .activity)
                    .ignoresSafeArea()

                List {
                    Section {
                        if rows.isEmpty {
                            activityEmptyCard
                                .listRowInsets(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        } else {
                            ActivityHeroSummary(transactions: rows, filterActive: effectiveFilter.isActive)
                                .listRowInsets(EdgeInsets(top: 8, leading: 14, bottom: 12, trailing: 14))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }

                    if !rows.isEmpty {
                        Section {
                            ForEach(rows) { tx in
                                TransactionRow(transaction: tx, accounts: viewModel.accounts)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .contentShape(Rectangle())
                                    .onTapGesture { selectedTransaction = tx }
                                    .contextMenu {
                                        Button {
                                            editingTransaction = tx
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        Button {
                                            viewModel.toggleFavorite(tx)
                                        } label: {
                                            Label("Toggle favorite", systemImage: "star")
                                        }
                                        Button(role: .destructive) {
                                            viewModel.deleteTransaction(tx)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            activitySectionHeader
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moneyBackground.opacity(0.94), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search notes, categories…")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: filter.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.moneyAccent)
                    }
                    .accessibilityLabel("Filters")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 18) {
                        Menu {
                            Button {
                                showExport = true
                            } label: {
                                Label("Export backup…", systemImage: "square.and.arrow.up")
                            }
                            Button {
                                showRecurring = true
                            } label: {
                                Label("Recurring reminders", systemImage: "repeat.circle")
                            }
                            Button {
                                showRules = true
                            } label: {
                                Label("Note tag rules", systemImage: "text.badge.checkmark")
                            }
                            Button {
                                showAccounts = true
                            } label: {
                                Label("Accounts", systemImage: "creditcard")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(Color.moneyAccent)
                        }
                        .accessibilityLabel("More")

                        Button {
                            showAdd = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.moneyAccent, Color.white.opacity(0.92))
                        }
                        .accessibilityLabel("New transaction")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                TransactionFiltersSheet(viewModel: viewModel, filter: $filter)
            }
            .sheet(isPresented: $showAdd) {
                AddTransactionView(viewModel: viewModel)
            }
            .sheet(item: $selectedTransaction) { tx in
                TransactionDetailView(viewModel: viewModel, transactionId: tx.id)
            }
            .sheet(item: $editingTransaction) { tx in
                TransactionEditorView(viewModel: viewModel, mode: .edit(tx))
            }
            .sheet(isPresented: $showExport) {
                ExportBackupView(viewModel: viewModel)
            }
            .sheet(isPresented: $showRecurring) {
                RecurringTemplatesView(viewModel: viewModel)
            }
            .sheet(isPresented: $showRules) {
                NoteRulesView(viewModel: viewModel)
            }
            .sheet(isPresented: $showAccounts) {
                AccountsManageView(viewModel: viewModel)
            }
        }
    }

    private var activitySectionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("ALL ENTRIES")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundColor(.gray)
                Text("Tap for details · long-press or swipe for actions")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.75))
            }
            Spacer()
        }
        .textCase(nil)
        .padding(.top, 4)
    }

    private var activityEmptyCard: some View {
        VStack(spacing: 16) {
            Image(systemName: effectiveFilter.isActive ? "line.3.horizontal.decrease.circle" : "list.bullet.rectangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.moneyAccent, .moneyIncome.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(effectiveFilter.isActive ? "No matching activity" : "Nothing here yet")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)

            Text(
                effectiveFilter.isActive
                    ? "Try widening your filters or clearing search to see transactions."
                    : "Add income, expenses, and transfers with +. Export, recurring reminders, and accounts live in the menu."
            )
            .font(.caption)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)

            if effectiveFilter.isActive {
                Button {
                    searchText = ""
                    filter = TransactionFilter()
                } label: {
                    Text("Reset filters & search")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.moneyAccent, .moneyIncome.opacity(0.85)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    showAdd = true
                } label: {
                    Text("Add transaction")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.moneyAccent, .moneyIncome.opacity(0.85)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.11),
                            Color.moneyAccent.opacity(0.1),
                            Color.black.opacity(0.3)
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
                        colors: [Color.moneyAccent.opacity(0.4), Color.moneyIncome.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .moneyMapSpecularRim(cornerRadius: 22)
        .moneyMapDepthShadow(accent: .moneyAccent)
    }
}
