//
//  ContributeToGoalView.swift
//  151MoneyMap
//

import SwiftUI

struct ContributeToGoalView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @Environment(\.dismiss) private var dismiss

    let goal: SavingsGoal
    @State private var amount: Double = 1000

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                Form {
                    Section {
                        Text(goal.name)
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack {
                            Text("Amount")
                            Spacer()
                            Text("$")
                                .foregroundColor(.gray)
                            TextField("0", value: $amount, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 112)
                        }
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .tint(.moneyAccent)
            }
            .navigationTitle("Add funds")
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
                        viewModel.addToGoal(goal, amount: max(0, amount))
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.moneyAccent)
                }
            }
        }
    }
}
