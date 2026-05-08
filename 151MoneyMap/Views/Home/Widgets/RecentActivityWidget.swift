//
//  RecentActivityWidget.swift
//  151MoneyMap
//

import SwiftUI

struct RecentActivityWidget: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    var onSelect: (Transaction) -> Void

    private var items: [Transaction] {
        Array(viewModel.recentTransactions.prefix(8))
    }

    var body: some View {
        HomeWidgetShell(
            title: "Recent activity",
            subtitle: items.isEmpty ? "No transactions yet" : "Latest entries"
        ) {
            if items.isEmpty {
                Text("Tap + to add your first transaction.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 10) {
                    ForEach(items) { transaction in
                        TransactionRow(transaction: transaction, accounts: viewModel.accounts)
                            .contentShape(Rectangle())
                            .onTapGesture { onSelect(transaction) }
                            .contextMenu {
                                Button {
                                    viewModel.toggleFavorite(transaction)
                                } label: {
                                    Label("Toggle favorite", systemImage: "star")
                                }
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(transaction)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }
}
