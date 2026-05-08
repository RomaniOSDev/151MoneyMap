//
//  AddGoalView.swift
//  151MoneyMap
//

import SwiftUI

struct AddGoalView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var targetAmount: Double = 100_000
    @State private var currentAmount: Double = 0
    @State private var hasDeadline = false
    @State private var deadline = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
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
            .navigationTitle("New goal")
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
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let goal = SavingsGoal(
            id: UUID(),
            name: trimmedName,
            targetAmount: max(0, targetAmount),
            currentAmount: max(0, currentAmount),
            deadline: hasDeadline ? deadline : nil,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
            isCompleted: max(0, currentAmount) >= max(0, targetAmount) && targetAmount > 0,
            createdAt: Date(),
            priority: priority,
            weeklyContributionTarget: hasWeekly && weekly > 0 ? weekly : nil
        )
        viewModel.addGoal(goal)
        dismiss()
    }
}
