//
//  SavingsGoal.swift
//  151MoneyMap
//

import Foundation

struct SavingsGoal: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date?
    var notes: String?
    var isCompleted: Bool
    let createdAt: Date
    var priority: Int
    var weeklyContributionTarget: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, targetAmount, currentAmount, deadline, notes, isCompleted, createdAt
        case priority, weeklyContributionTarget
    }

    init(
        id: UUID,
        name: String,
        targetAmount: Double,
        currentAmount: Double,
        deadline: Date?,
        notes: String?,
        isCompleted: Bool,
        createdAt: Date,
        priority: Int = 0,
        weeklyContributionTarget: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.deadline = deadline
        self.notes = notes
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.priority = priority
        self.weeklyContributionTarget = weeklyContributionTarget
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        targetAmount = try c.decode(Double.self, forKey: .targetAmount)
        currentAmount = try c.decode(Double.self, forKey: .currentAmount)
        deadline = try c.decodeIfPresent(Date.self, forKey: .deadline)
        notes = try c.decodeIfPresent(String.self, forKey: .notes)
        isCompleted = try c.decode(Bool.self, forKey: .isCompleted)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        priority = try c.decodeIfPresent(Int.self, forKey: .priority) ?? 0
        weeklyContributionTarget = try c.decodeIfPresent(Double.self, forKey: .weeklyContributionTarget)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(targetAmount, forKey: .targetAmount)
        try c.encode(currentAmount, forKey: .currentAmount)
        try c.encodeIfPresent(deadline, forKey: .deadline)
        try c.encodeIfPresent(notes, forKey: .notes)
        try c.encode(isCompleted, forKey: .isCompleted)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(priority, forKey: .priority)
        try c.encodeIfPresent(weeklyContributionTarget, forKey: .weeklyContributionTarget)
    }

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }

    var formattedProgress: String {
        String(format: "%.1f%%", progress * 100)
    }

    var projectedCompletionDate: Date? {
        guard let weekly = weeklyContributionTarget, weekly > 0, currentAmount < targetAmount else { return nil }
        let remaining = targetAmount - currentAmount
        let weeks = Int(ceil(remaining / weekly))
        return Calendar.current.date(byAdding: .weekOfYear, value: max(1, weeks), to: Date())
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SavingsGoal, rhs: SavingsGoal) -> Bool {
        lhs.id == rhs.id
    }
}
