//
//  TransactionDetailView.swift
//  151MoneyMap
//

import SwiftUI

struct TransactionDetailView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    let transactionId: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var showEdit = false

    private var transaction: Transaction? {
        viewModel.transactions.first { $0.id == transactionId }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                if let transaction {
                    List {
                        Section {
                            LabeledContent("Type", value: transaction.type.rawValue)
                            LabeledContent("Title", value: transaction.displayTitle(accounts: viewModel.accounts))
                            LabeledContent("Amount", value: transaction.formattedAmount)
                            LabeledContent("Date", value: formattedDate(transaction.date))
                            if transaction.type != .transfer {
                                LabeledContent("Category", value: transaction.category.rawValue)
                            }
                            if let acc = viewModel.accounts.first(where: { $0.id == transaction.accountId }) {
                                LabeledContent("Account", value: acc.name)
                            }
                            if let to = transaction.toAccountId,
                               let acc = viewModel.accounts.first(where: { $0.id == to }) {
                                LabeledContent("To account", value: acc.name)
                            }
                            if let location = transaction.location, !location.isEmpty {
                                LabeledContent("Location", value: location)
                            }
                            if let note = transaction.note, !note.isEmpty {
                                LabeledContent("Note", value: note)
                            }
                            if !transaction.tags.isEmpty {
                                LabeledContent("Tags", value: transaction.tags.map { "#\($0)" }.joined(separator: " "))
                            }
                            LabeledContent("Favorite") {
                                Text(transaction.isFavorite ? "Yes" : "No")
                                    .foregroundColor(transaction.isFavorite ? .moneyAccent : .gray)
                            }
                        }
                        .listRowBackground(Color.moneyBackground.opacity(0.5))

                        Section {
                            Button {
                                showEdit = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                                    .foregroundColor(.moneyAccent)
                            }

                            Button {
                                viewModel.toggleFavorite(transaction)
                            } label: {
                                Label("Toggle favorite", systemImage: "star")
                                    .foregroundColor(.moneyAccent)
                            }

                            Button(role: .destructive) {
                                viewModel.deleteTransaction(transaction)
                                dismiss()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowBackground(Color.moneyBackground.opacity(0.5))
                    }
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.white)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "trash")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("This transaction no longer exists.")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moneyBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.moneyAccent)
                }
            }
            .sheet(isPresented: $showEdit) {
                Group {
                    if let tx = transaction {
                        TransactionEditorView(viewModel: viewModel, mode: .edit(tx))
                    }
                }
            }
        }
    }
}
