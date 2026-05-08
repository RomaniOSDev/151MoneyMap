//
//  AddBudgetView.swift
//  151MoneyMap
//

import SwiftUI

struct AddBudgetView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var category: TransactionCategory = .food
    @State private var limit: Double = 10_000
    @State private var month: Int
    @State private var year: Int

    init(viewModel: MoneyMapViewModel, presetMonth: Int? = nil, presetYear: Int? = nil) {
        self.viewModel = viewModel
        let cal = Calendar.current
        let now = Date()
        _month = State(initialValue: presetMonth ?? cal.component(.month, from: now))
        _year = State(initialValue: presetYear ?? cal.component(.year, from: now))
    }

    private var expenseCategories: [TransactionCategory] {
        TransactionCategory.categories(for: .expense)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                Form {
                    Section {
                        Picker("Category", selection: $category) {
                            ForEach(expenseCategories, id: \.self) { cat in
                                HStack {
                                    Image(systemName: cat.icon)
                                        .foregroundColor(cat.type.color)
                                    Text(cat.rawValue)
                                }
                                .tag(cat)
                            }
                        }

                        HStack {
                            Text("Limit")
                            Spacer()
                            Text("$")
                                .foregroundColor(.gray)
                            TextField("0", value: $limit, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 112)
                        }

                        Stepper(value: $month, in: 1...12) {
                            Text("Month: \(month)")
                        }

                        Stepper(value: $year, in: 2020...2035) {
                            Text("Year: \(year)")
                        }
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .tint(.moneyAccent)
            }
            .navigationTitle("New budget")
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
                }
            }
            .onAppear {
                if let first = expenseCategories.first {
                    category = first
                }
            }
        }
    }

    private func save() {
        let existing = viewModel.budgets.contains { $0.category == category && $0.month == month && $0.year == year }
        if existing {
            dismiss()
            return
        }
        let budget = Budget(
            id: UUID(),
            category: category,
            limit: max(0, limit),
            spent: 0,
            month: month,
            year: year
        )
        viewModel.addBudget(budget)
        dismiss()
    }
}
