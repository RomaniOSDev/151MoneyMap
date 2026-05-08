//
//  TransactionFiltersSheet.swift
//  151MoneyMap
//

import SwiftUI

struct TransactionFiltersSheet: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @Binding var filter: TransactionFilter
    @Environment(\.dismiss) private var dismiss

    @State private var minAmountText = ""
    @State private var maxAmountText = ""
    @State private var tagText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                Form {
                    Section("Type") {
                        ForEach(TransactionType.allCases, id: \.self) { t in
                            Toggle(t.rawValue, isOn: Binding(
                                get: { filter.types.contains(t) },
                                set: { on in
                                    if on { filter.types.insert(t) } else { filter.types.remove(t) }
                                }
                            ))
                            .tint(.moneyAccent)
                        }
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))

                    Section("Category") {
                        ForEach(TransactionCategory.allCases, id: \.self) { c in
                            Toggle(c.rawValue, isOn: Binding(
                                get: { filter.categories.contains(c) },
                                set: { on in
                                    if on { filter.categories.insert(c) } else { filter.categories.remove(c) }
                                }
                            ))
                            .tint(.moneyAccent)
                        }
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))

                    Section("Accounts") {
                        ForEach(viewModel.accounts.sorted(by: { $0.sortOrder < $1.sortOrder })) { acc in
                            Toggle(acc.name, isOn: Binding(
                                get: { filter.accountIds.contains(acc.id) },
                                set: { on in
                                    if on { filter.accountIds.insert(acc.id) } else { filter.accountIds.remove(acc.id) }
                                }
                            ))
                            .tint(.moneyAccent)
                        }
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))

                    Section("More") {
                        Toggle("Favorites only", isOn: $filter.favoritesOnly)
                            .tint(.moneyAccent)

                        TextField("Min amount", text: $minAmountText)
                            .keyboardType(.decimalPad)
                        TextField("Max amount", text: $maxAmountText)
                            .keyboardType(.decimalPad)

                        TextField("Tag contains", text: $tagText)
                            .autocorrectionDisabled()
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .tint(.moneyAccent)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.moneyBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        filter.reset()
                        minAmountText = ""
                        maxAmountText = ""
                        tagText = ""
                    }
                    .foregroundColor(.moneyAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        let minR = minAmountText.replacingOccurrences(of: ",", with: ".")
                        let maxR = maxAmountText.replacingOccurrences(of: ",", with: ".")
                        filter.minAmount = Double(minR)
                        filter.maxAmount = Double(maxR)
                        filter.tagContains = tagText
                        dismiss()
                    }
                    .foregroundColor(.moneyAccent)
                    .bold()
                }
            }
            .onAppear {
                if let m = filter.minAmount { minAmountText = String(format: "%.0f", m) }
                if let m = filter.maxAmount { maxAmountText = String(format: "%.0f", m) }
                tagText = filter.tagContains
            }
        }
    }
}
