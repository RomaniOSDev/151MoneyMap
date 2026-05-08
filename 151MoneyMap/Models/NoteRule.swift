//
//  NoteRule.swift
//  151MoneyMap
//

import Foundation

/// If note contains `keyword` (case-insensitive) for given category, append `tag`.
struct NoteRule: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var category: TransactionCategory
    var keyword: String
    var tagToApply: String

    init(id: UUID = UUID(), category: TransactionCategory, keyword: String, tagToApply: String) {
        self.id = id
        self.category = category
        self.keyword = keyword
        self.tagToApply = tagToApply.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
