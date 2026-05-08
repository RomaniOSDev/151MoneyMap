//
//  EditGoalView.swift
//  151MoneyMap
//

import SwiftUI

struct EditGoalView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    let goal: SavingsGoal
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var targetAmount: Double = 0
    @State private var currentAmount: Double = 0
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var notes = ""
    @State private var priority = 0
    @State private var hasWeekly = false
    @State private var weekly: Double = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Name", text: $name)

                        HStack {
                            Text("Target")
                            Spacer()
                            Text("$")
                                .foregroundColor(.gray)
                            TextField("0", value: $targetAmount, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 112)
                        }

                        HStack {
                            Text("Saved")
                            Spacer()
                            Text("$")
                                .foregroundColor(.gray)
                            TextField("0", value: $currentAmount, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 112)
                        }

                        Stepper("Priority \(priority)", value: $priority, in: 0 ... 10)

                        Toggle("Weekly plan", isOn: $hasWeekly)
                            .tint(.moneyAccent)
                        if hasWeekly {
                            HStack {
                                Text("Per week")
                                Spacer()
                                Text("$")
                                    .foregroundColor(.gray)
                                TextField("0", value: $weekly, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 112)
                            }
                        }

                        Toggle("Deadline", isOn: $hasDeadline)
                            .tint(.moneyAccent)

                        if hasDeadline {
                            DatePicker("Date", selection: $deadline, displayedComponents: .date)
                        }

                        TextField("Notes", text: $notes, axis: .vertical)
                            .lineLimit(3 ... 6)
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .tint(.moneyAccent)
            }
            .navigationTitle("Edit goal")
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
                name = goal.name
                targetAmount = goal.targetAmount
                currentAmount = goal.currentAmount
                priority = goal.priority
                if let w = goal.weeklyContributionTarget, w > 0 {
                    hasWeekly = true
                    weekly = w
                }
                if let d = goal.deadline {
                    hasDeadline = true
                    deadline = d
                }
                notes = goal.notes ?? ""
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        var updated = goal
        updated.name = trimmedName
        updated.targetAmount = max(0, targetAmount)
        updated.currentAmount = max(0, currentAmount)
        updated.deadline = hasDeadline ? deadline : nil
        updated.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
        updated.priority = priority
        updated.weeklyContributionTarget = hasWeekly && weekly > 0 ? weekly : nil
        updated.isCompleted = updated.currentAmount >= updated.targetAmount && updated.targetAmount > 0
        viewModel.updateGoal(updated)
        dismiss()
    }
}
