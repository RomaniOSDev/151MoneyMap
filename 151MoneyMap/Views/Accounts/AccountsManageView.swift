//
//  AccountsManageView.swift
//  151MoneyMap
//

import SwiftUI

struct AccountsManageView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                List {
                    Section {
                        Text("Transfers move money between accounts. Balance is computed from all transactions.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.clear)

                    ForEach(viewModel.accounts.sorted(by: { $0.sortOrder < $1.sortOrder })) { acc in
                        HStack {
                            Image(systemName: acc.iconName)
                                .foregroundColor(.moneyAccent)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(acc.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(formatCurrency(viewModel.balance(for: acc.id)))
                                    .font(.caption.monospacedDigit())
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .listRowBackground(Color.moneyBackground.opacity(0.5))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if viewModel.accounts.count > 1 {
                                Button(role: .destructive) {
                                    viewModel.deleteAccount(acc)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moneyBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.moneyAccent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.moneyAccent, Color.white.opacity(0.9))
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AccountEditorView(viewModel: viewModel, account: nil)
            }
        }
    }
}

struct AccountEditorView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    let account: Account?
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var icon = "creditcard"

    private let icons = ["banknote", "creditcard", "building.columns", "dollarsign.circle", "bitcoinsign.circle"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Name", text: $name)
                        Picker("Icon", selection: $icon) {
                            ForEach(icons, id: \.self) { i in
                                Label(i, systemImage: i).tag(i)
                            }
                        }
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .tint(.moneyAccent)
            }
            .navigationTitle(account == nil ? "New account" : "Rename")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.moneyAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .buttonStyle(.borderedProminent)
                        .tint(.moneyAccent)
                }
            }
            .onAppear {
                if let a = account {
                    name = a.name
                    icon = a.iconName
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let a = account {
            var u = a
            u.name = trimmed
            u.iconName = icon
            viewModel.updateAccount(u)
        } else {
            let maxOrder = viewModel.accounts.map(\.sortOrder).max() ?? 0
            let acc = Account(id: UUID(), name: trimmed, iconName: icon, sortOrder: maxOrder + 1)
            viewModel.addAccount(acc)
        }
        dismiss()
    }
}
