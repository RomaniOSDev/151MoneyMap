//
//  RecurringTemplatesView.swift
//  151MoneyMap
//

import SwiftUI

struct RecurringTemplatesView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showAdd = false
    @State private var editing: RecurringTemplate?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                List {
                    Section {
                        Text("Local reminders on the chosen day each month. They do not post transactions automatically.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.clear)

                    ForEach(viewModel.recurringTemplates) { tpl in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(tpl.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: {
                                        viewModel.recurringTemplates.first(where: { $0.id == tpl.id })?.isEnabled ?? false
                                    },
                                    set: { on in
                                        guard var t = viewModel.recurringTemplates.first(where: { $0.id == tpl.id }) else { return }
                                        t.isEnabled = on
                                        viewModel.updateRecurringTemplate(t)
                                    }
                                ))
                                .labelsHidden()
                                .tint(.moneyAccent)
                            }
                            Text("\(tpl.type.rawValue) · \(formatCurrency(tpl.amount)) · \(tpl.category.rawValue)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Day \(tpl.dayOfMonth) at \(String(format: "%02d:%02d", tpl.hour, tpl.minute))")
                                .font(.caption2)
                                .foregroundColor(.moneyAccent)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.moneyBackground.opacity(0.5))
                        .onTapGesture { editing = tpl }
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.deleteRecurringTemplate(tpl)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Recurring")
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
            .task {
                _ = await NotificationManager.requestAuthorizationIfNeeded()
            }
            .sheet(isPresented: $showAdd) {
                RecurringEditorView(viewModel: viewModel, template: nil)
            }
            .sheet(item: $editing) { tpl in
                RecurringEditorView(viewModel: viewModel, template: tpl)
            }
        }
    }
}

struct RecurringEditorView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    let template: RecurringTemplate?
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var amount: Double = 0
    @State private var type: TransactionType = .expense
    @State private var category: TransactionCategory = .food
    @State private var accountId: UUID = Account.defaultWalletId
    @State private var dayOfMonth = 1
    @State private var hour = 9
    @State private var minute = 0
    @State private var isEnabled = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Name", text: $name)
                        HStack {
                            Text("Amount")
                            Spacer()
                            Text("$").foregroundColor(.gray)
                            TextField("0", value: $amount, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                        Picker("Type", selection: $type) {
                            Text(TransactionType.income.rawValue).tag(TransactionType.income)
                            Text(TransactionType.expense.rawValue).tag(TransactionType.expense)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: type) { _ in
                            let opts = TransactionCategory.categories(for: type)
                            if let f = opts.first { category = f }
                        }
                        Picker("Category", selection: $category) {
                            ForEach(TransactionCategory.categories(for: type), id: \.self) { c in
                                Text(c.rawValue).tag(c)
                            }
                        }
                        Picker("Account", selection: $accountId) {
                            ForEach(viewModel.accounts.sorted(by: { $0.sortOrder < $1.sortOrder })) { a in
                                Text(a.name).tag(a.id)
                            }
                        }
                        Stepper("Day of month: \(dayOfMonth)", value: $dayOfMonth, in: 1 ... 28)
                        Stepper("Hour: \(hour)", value: $hour, in: 0 ... 23)
                        Stepper("Minute: \(minute)", value: $minute, in: 0 ... 59, step: 5)
                        Toggle("Enabled", isOn: $isEnabled)
                            .tint(.moneyAccent)
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .tint(.moneyAccent)
            }
            .navigationTitle(template == nil ? "New reminder" : "Edit reminder")
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
                if let t = template {
                    name = t.name
                    amount = t.amount
                    type = t.type
                    category = t.category
                    accountId = t.accountId
                    dayOfMonth = t.dayOfMonth
                    hour = t.hour
                    minute = t.minute
                    isEnabled = t.isEnabled
                } else {
                    accountId = viewModel.primaryAccountId
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, amount > 0 else { return }
        let tpl = RecurringTemplate(
            id: template?.id ?? UUID(),
            name: trimmed,
            amount: amount,
            type: type,
            category: category,
            accountId: accountId,
            tags: [],
            note: nil,
            dayOfMonth: dayOfMonth,
            hour: hour,
            minute: minute,
            isEnabled: isEnabled
        )
        if template == nil {
            viewModel.addRecurringTemplate(tpl)
        } else {
            viewModel.updateRecurringTemplate(tpl)
        }
        dismiss()
    }
}
