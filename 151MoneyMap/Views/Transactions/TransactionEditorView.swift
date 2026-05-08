//
//  TransactionEditorView.swift
//  151MoneyMap
//

import SwiftUI

enum TransactionEditorMode {
    case add
    case edit(Transaction)
}

struct TransactionEditorView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    let mode: TransactionEditorMode
    @Environment(\.dismiss) private var dismiss

    @State private var type: TransactionType = .expense
    @State private var amount: Double = 0
    @State private var category: TransactionCategory = .food
    @State private var date = Date()
    @State private var location = ""
    @State private var note = ""
    @State private var isFavorite = false
    @State private var accountId: UUID = Account.defaultWalletId
    @State private var transferToAccountId: UUID = Account.defaultWalletId
    @State private var tagsLine = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                Form {
                    Section {
                        Picker("Type", selection: $type) {
                            ForEach(TransactionType.allCases, id: \.self) { t in
                                Text(t.rawValue).tag(t)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: type) { newType in
                            syncCategory(for: newType)
                            if newType == .transfer {
                                ensureTransferAccounts()
                            }
                        }

                        HStack {
                            Text("Amount")
                            Spacer()
                            Text("$")
                                .foregroundColor(.gray)
                            TextField("0", value: $amount, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 112)
                                .multilineTextAlignment(.trailing)
                        }

                        if type != .transfer {
                            Picker("Category", selection: $category) {
                                ForEach(TransactionCategory.categories(for: type), id: \.self) { cat in
                                    HStack {
                                        Image(systemName: cat.icon)
                                            .foregroundColor(cat.type.color)
                                        Text(cat.rawValue)
                                    }
                                    .tag(cat)
                                }
                            }
                        }

                        Picker("Account", selection: $accountId) {
                            ForEach(viewModel.accounts.sorted(by: { $0.sortOrder < $1.sortOrder })) { acc in
                                Label(acc.name, systemImage: acc.iconName).tag(acc.id)
                            }
                        }
                        .onChange(of: accountId) { _ in
                            if type == .transfer {
                                ensureTransferAccounts()
                            }
                        }

                        if type == .transfer {
                            Picker("To account", selection: $transferToAccountId) {
                                ForEach(viewModel.accounts.filter { $0.id != accountId }) { acc in
                                    Label(acc.name, systemImage: acc.iconName).tag(acc.id)
                                }
                            }
                        }

                        DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])

                        TextField("Location", text: $location)
                        TextField("Note", text: $note)
                        TextField("Tags (comma-separated)", text: $tagsLine)
                            .autocorrectionDisabled()
                    }

                    Section {
                        Toggle("Add to favorites", isOn: $isFavorite)
                            .tint(.moneyAccent)
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .tint(type == .transfer ? Color.moneyAccent : (type == .income ? Color.moneyIncome : Color.moneyExpense))
            }
            .navigationTitle(modeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moneyBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.moneyAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .buttonStyle(.borderedProminent)
                        .tint(.moneyAccent)
                        .disabled(!canSave)
                }
            }
            .onAppear(perform: hydrate)
        }
    }

    private var modeTitle: String {
        switch mode {
        case .add: return "New transaction"
        case .edit: return "Edit transaction"
        }
    }

    private var canSave: Bool {
        guard amount > 0 else { return false }
        if type == .transfer {
            let others = viewModel.accounts.filter { $0.id != accountId }
            guard !others.isEmpty else { return false }
            return transferToAccountId != accountId
        }
        return true
    }

    private func syncCategory(for newType: TransactionType) {
        let options = TransactionCategory.categories(for: newType)
        if let first = options.first {
            category = first
        }
    }

    private func ensureTransferAccounts() {
        let others = viewModel.accounts.filter { $0.id != accountId }
        if others.isEmpty { return }
        if !others.contains(where: { $0.id == transferToAccountId }) {
            transferToAccountId = others[0].id
        }
        if transferToAccountId == accountId {
            transferToAccountId = others[0].id
        }
    }

    private func hydrate() {
        switch mode {
        case .add:
            accountId = viewModel.primaryAccountId
            ensureTransferAccounts()
        case .edit(let tx):
            type = tx.type
            amount = tx.amount
            category = tx.category
            date = tx.date
            location = tx.location ?? ""
            note = tx.note ?? ""
            isFavorite = tx.isFavorite
            accountId = tx.accountId
            if let to = tx.toAccountId {
                transferToAccountId = to
            } else {
                ensureTransferAccounts()
            }
            tagsLine = tx.tags.joined(separator: ", ")
        }
    }

    private func parsedTags() -> [String] {
        tagsLine.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    private func save() {
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let cat: TransactionCategory = type == .transfer ? .other : category
        let toId: UUID? = type == .transfer ? transferToAccountId : nil

        let txId: UUID
        let createdAt: Date
        switch mode {
        case .add:
            txId = UUID()
            createdAt = Date()
        case .edit(let t):
            txId = t.id
            createdAt = t.createdAt
        }

        let tx = Transaction(
            id: txId,
            date: date,
            amount: max(0, amount),
            category: cat,
            type: type,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            location: trimmedLocation.isEmpty ? nil : trimmedLocation,
            isFavorite: isFavorite,
            createdAt: createdAt,
            accountId: accountId,
            toAccountId: toId,
            tags: parsedTags()
        )

        switch mode {
        case .add:
            viewModel.addTransaction(tx)
        case .edit:
            viewModel.updateTransaction(tx)
        }
        dismiss()
    }
}
