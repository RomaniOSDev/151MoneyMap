//
//  EditBudgetView.swift
//  151MoneyMap
//

import SwiftUI

struct EditBudgetView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @Environment(\.dismiss) private var dismiss

    let budget: Budget
    @State private var limit: Double

    init(viewModel: MoneyMapViewModel, budget: Budget) {
        self.viewModel = viewModel
        self.budget = budget
        _limit = State(initialValue: budget.limit)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                Form {
                    Section {
                        LabeledContent("Category", value: budget.category.rawValue)

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

                        LabeledContent("Spent", value: formatCurrency(budget.spent))
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .tint(.moneyAccent)
            }
            .navigationTitle("Edit budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moneyBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.moneyAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updated = budget
                        updated.limit = max(0, limit)
                        viewModel.updateBudget(updated)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.moneyAccent)
                }
            }
        }
    }
}
