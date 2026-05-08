//
//  NoteRulesView.swift
//  151MoneyMap
//

import SwiftUI

struct NoteRulesView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showAdd = false
    @State private var editingRule: NoteRule?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                List {
                    Section {
                        Text("When the note contains the keyword (case-insensitive) for the selected category, the tag is added on save.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.clear)

                    ForEach(viewModel.noteRules) { rule in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(rule.category.rawValue)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("“\(rule.keyword)” → #\(rule.tagToApply)")
                                .font(.caption)
                                .foregroundColor(.moneyAccent)
                        }
                        .listRowBackground(Color.moneyBackground.opacity(0.5))
                        .contentShape(Rectangle())
                        .onTapGesture { editingRule = rule }
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.deleteNoteRule(rule)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Note rules")
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
                NoteRuleEditorView(viewModel: viewModel, rule: nil)
            }
            .sheet(item: $editingRule) { rule in
                NoteRuleEditorView(viewModel: viewModel, rule: rule)
            }
        }
    }
}

struct NoteRuleEditorView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    let rule: NoteRule?
    @Environment(\.dismiss) private var dismiss

    @State private var category: TransactionCategory = .food
    @State private var keyword = ""
    @State private var tag = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                Form {
                    Section {
                        Picker("Category", selection: $category) {
                            ForEach(TransactionCategory.allCases, id: \.self) { c in
                                Text(c.rawValue).tag(c)
                            }
                        }
                        TextField("Keyword in note", text: $keyword)
                            .autocorrectionDisabled()
                        TextField("Tag to add", text: $tag)
                            .autocorrectionDisabled()
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .tint(.moneyAccent)
            }
            .navigationTitle(rule == nil ? "New rule" : "Edit rule")
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
                if let r = rule {
                    category = r.category
                    keyword = r.keyword
                    tag = r.tagToApply
                }
            }
        }
    }

    private func save() {
        let k = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        let t = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !k.isEmpty, !t.isEmpty else { return }
        let r = NoteRule(id: rule?.id ?? UUID(), category: category, keyword: k, tagToApply: t)
        if rule == nil {
            viewModel.addNoteRule(r)
        } else {
            viewModel.updateNoteRule(r)
        }
        dismiss()
    }
}
