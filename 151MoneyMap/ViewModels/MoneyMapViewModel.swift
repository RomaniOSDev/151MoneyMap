//
//  MoneyMapViewModel.swift
//  151MoneyMap
//

import Foundation
import Combine

private struct LegacyTransaction: Decodable {
    let id: UUID
    let date: Date
    var amount: Double
    var category: TransactionCategory
    var type: TransactionType
    var note: String?
    var location: String?
    var isFavorite: Bool
    let createdAt: Date
}

struct BudgetSoftAlert: Identifiable, Equatable {
    let id: UUID
    let categoryName: String
    let message: String
    let level: Int
}

struct CompareBar: Identifiable {
    let id: String
    let label: String
    let value: Double
    let isIncome: Bool
}

@MainActor
final class MoneyMapViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var budgets: [Budget] = []
    @Published var savingsGoals: [SavingsGoal] = []
    @Published var accounts: [Account] = []
    @Published var recurringTemplates: [RecurringTemplate] = []
    @Published var noteRules: [NoteRule] = []
    @Published var budgetSoftAlerts: [BudgetSoftAlert] = []

    var primaryAccountId: UUID {
        accounts.sorted { $0.sortOrder < $1.sortOrder }.first?.id ?? Account.defaultWalletId
    }

    var totalIncome: Double {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var totalExpense: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        totalIncome - totalExpense
    }

    var savingsRate: Double {
        guard totalIncome > 0 else { return 0 }
        return (balance / totalIncome) * 100
    }

    var recentTransactions: [Transaction] {
        Array(transactions.sorted { $0.date > $1.date }.prefix(10))
    }

    var expenseByCategory: [(category: TransactionCategory, amount: Double)] {
        let expenses = transactions.filter { $0.type == .expense }
        let grouped = Dictionary(grouping: expenses, by: \.category)
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.1 > $1.1 }
    }

    var topExpenseCategories: [(name: String, icon: String, amount: Double)] {
        expenseByCategory.map { ($0.category.rawValue, $0.category.icon, $0.amount) }
    }

    struct MonthlyData: Identifiable {
        let id: String
        let sortDate: Date
        let month: String
        let income: Double
        let expense: Double
    }

    var monthlyData: [MonthlyData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            let components = calendar.dateComponents([.year, .month], from: transaction.date)
            return calendar.date(from: components) ?? transaction.date
        }

        return grouped.map { date, txs in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMM"
            let y = calendar.component(.year, from: date)
            let m = calendar.component(.month, from: date)
            let id = "\(y)-\(String(format: "%02d", m))"
            let income = txs.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let expense = txs.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            return MonthlyData(id: id, sortDate: date, month: formatter.string(from: date), income: income, expense: expense)
        }
        .sorted { $0.sortDate < $1.sortDate }
    }

    var monthCompareBars: [CompareBar] {
        let cal = Calendar.current
        let now = Date()
        guard let thisStart = cal.date(from: cal.dateComponents([.year, .month], from: now)),
              let thisEnd = cal.date(byAdding: .month, value: 1, to: thisStart),
              let prevStart = cal.date(byAdding: .month, value: -1, to: thisStart) else { return [] }

        func totals(from start: Date, to end: Date) -> (Double, Double) {
            let filtered = transactions.filter { $0.date >= start && $0.date < end }
            let inc = filtered.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let exp = filtered.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            return (inc, exp)
        }

        let t0 = totals(from: thisStart, to: thisEnd)
        let t1 = totals(from: prevStart, to: thisStart)

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US")
        df.dateFormat = "MMM"

        let thisShort = df.string(from: thisStart)
        let prevShort = df.string(from: prevStart)

        return [
            CompareBar(id: "ti", label: "\(thisShort) · Income", value: t0.0, isIncome: true),
            CompareBar(id: "te", label: "\(thisShort) · Expense", value: t0.1, isIncome: false),
            CompareBar(id: "pi", label: "\(prevShort) · Income", value: t1.0, isIncome: true),
            CompareBar(id: "pe", label: "\(prevShort) · Expense", value: t1.1, isIncome: false)
        ]
    }

    func transactions(matching filter: TransactionFilter) -> [Transaction] {
        let q = filter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let tagQ = filter.tagContains.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return transactions.filter { tx in
            if filter.favoritesOnly, !tx.isFavorite { return false }
            if !filter.types.isEmpty, !filter.types.contains(tx.type) { return false }
            if !filter.categories.isEmpty, !filter.categories.contains(tx.category) { return false }
            if !filter.accountIds.isEmpty {
                let touches = filter.accountIds.contains(tx.accountId) || (tx.toAccountId.map { filter.accountIds.contains($0) } ?? false)
                if !touches { return false }
            }
            if let minA = filter.minAmount, tx.amount < minA { return false }
            if let maxA = filter.maxAmount, tx.amount > maxA { return false }
            if let from = filter.fromDate, tx.date < from { return false }
            if let to = filter.toDate {
                let end = Calendar.current.startOfDay(for: to).addingTimeInterval(86400 - 1)
                if tx.date > end { return false }
            }
            if !tagQ.isEmpty {
                let joined = tx.tags.joined(separator: " ").lowercased()
                if !joined.contains(tagQ) { return false }
            }
            if !q.isEmpty {
                let hay = [
                    tx.category.rawValue,
                    tx.note ?? "",
                    tx.location ?? "",
                    tx.type.rawValue
                ].joined(separator: " ").lowercased()
                if !hay.contains(q) { return false }
            }
            return true
        }
        .sorted { $0.date > $1.date }
    }

    func balance(for accountId: UUID) -> Double {
        var b = 0.0
        for t in transactions {
            switch t.type {
            case .income:
                if t.accountId == accountId { b += t.amount }
            case .expense:
                if t.accountId == accountId { b -= t.amount }
            case .transfer:
                if t.accountId == accountId { b -= t.amount }
                if t.toAccountId == accountId { b += t.amount }
            }
        }
        return b
    }

    func addTransaction(_ transaction: Transaction) {
        var t = transaction
        t.tags = normalizedTags(mergedTags(for: t))
        transactions.append(t)
        updateBudgets(for: t)
        refreshBudgetSoftAlerts()
        saveToUserDefaults()
    }

    func updateTransaction(_ updated: Transaction) {
        guard let index = transactions.firstIndex(where: { $0.id == updated.id }) else { return }
        let old = transactions[index]
        adjustBudgetsAfterDeleting(old)
        var t = updated
        t.tags = normalizedTags(mergedTags(for: t))
        var copy = transactions
        copy[index] = t
        transactions = copy
        updateBudgets(for: t)
        refreshBudgetSoftAlerts()
        saveToUserDefaults()
    }

    func deleteTransaction(_ transaction: Transaction) {
        adjustBudgetsAfterDeleting(transaction)
        transactions.removeAll { $0.id == transaction.id }
        refreshBudgetSoftAlerts()
        saveToUserDefaults()
    }

    func toggleFavorite(_ transaction: Transaction) {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        var copy = transactions
        copy[index].isFavorite.toggle()
        transactions = copy
        saveToUserDefaults()
    }

    private func updateBudgets(for transaction: Transaction) {
        guard transaction.type == .expense else { return }
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: transaction.date)
        let currentYear = calendar.component(.year, from: transaction.date)

        guard let index = budgets.firstIndex(where: {
            $0.category == transaction.category && $0.month == currentMonth && $0.year == currentYear
        }) else { return }

        var copy = budgets
        copy[index].spent += transaction.amount
        budgets = copy
    }

    private func adjustBudgetsAfterDeleting(_ transaction: Transaction) {
        guard transaction.type == .expense else { return }
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: transaction.date)
        let currentYear = calendar.component(.year, from: transaction.date)

        guard let index = budgets.firstIndex(where: {
            $0.category == transaction.category && $0.month == currentMonth && $0.year == currentYear
        }) else { return }

        var copy = budgets
        copy[index].spent = max(0, copy[index].spent - transaction.amount)
        budgets = copy
    }

    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        refreshBudgetSoftAlerts()
        saveToUserDefaults()
    }

    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        refreshBudgetSoftAlerts()
        saveToUserDefaults()
    }

    func updateBudget(_ budget: Budget) {
        guard let index = budgets.firstIndex(where: { $0.id == budget.id }) else { return }
        var copy = budgets
        copy[index] = budget
        budgets = copy
        refreshBudgetSoftAlerts()
        saveToUserDefaults()
    }

    func addGoal(_ goal: SavingsGoal) {
        savingsGoals.append(goal)
        saveToUserDefaults()
    }

    func deleteGoal(_ goal: SavingsGoal) {
        savingsGoals.removeAll { $0.id == goal.id }
        saveToUserDefaults()
    }

    func updateGoal(_ goal: SavingsGoal) {
        guard let index = savingsGoals.firstIndex(where: { $0.id == goal.id }) else { return }
        var copy = savingsGoals
        copy[index] = goal
        savingsGoals = copy
        saveToUserDefaults()
    }

    func addToGoal(_ goal: SavingsGoal, amount: Double) {
        guard let index = savingsGoals.firstIndex(where: { $0.id == goal.id }) else { return }
        var copy = savingsGoals
        copy[index].currentAmount += amount
        if copy[index].currentAmount >= copy[index].targetAmount {
            copy[index].isCompleted = true
        }
        savingsGoals = copy
        saveToUserDefaults()
    }

    func addAccount(_ account: Account) {
        var copy = accounts
        copy.append(account)
        accounts = copy.sorted { $0.sortOrder < $1.sortOrder }
        saveToUserDefaults()
    }

    func updateAccount(_ account: Account) {
        guard let i = accounts.firstIndex(where: { $0.id == account.id }) else { return }
        var copy = accounts
        copy[i] = account
        accounts = copy.sorted { $0.sortOrder < $1.sortOrder }
        saveToUserDefaults()
    }

    func deleteAccount(_ account: Account) {
        guard accounts.count > 1 else { return }
        let fallback = accounts.first { $0.id != account.id }?.id ?? primaryAccountId
        var txs = transactions
        for i in txs.indices {
            if txs[i].accountId == account.id { txs[i].accountId = fallback }
            if txs[i].toAccountId == account.id { txs[i].toAccountId = nil }
        }
        transactions = txs

        var rec = recurringTemplates
        for i in rec.indices where rec[i].accountId == account.id {
            rec[i].accountId = fallback
        }
        recurringTemplates = rec

        accounts.removeAll { $0.id == account.id }
        saveToUserDefaults()
    }

    func addNoteRule(_ rule: NoteRule) {
        noteRules.append(rule)
        saveToUserDefaults()
    }

    func updateNoteRule(_ rule: NoteRule) {
        guard let index = noteRules.firstIndex(where: { $0.id == rule.id }) else { return }
        var copy = noteRules
        copy[index] = rule
        noteRules = copy
        saveToUserDefaults()
    }

    func deleteNoteRule(_ rule: NoteRule) {
        noteRules.removeAll { $0.id == rule.id }
        saveToUserDefaults()
    }

    func addRecurringTemplate(_ tpl: RecurringTemplate) {
        recurringTemplates.append(tpl)
        saveToUserDefaults()
        NotificationManager.rescheduleRecurringReminders(templates: recurringTemplates)
    }

    func updateRecurringTemplate(_ tpl: RecurringTemplate) {
        guard let i = recurringTemplates.firstIndex(where: { $0.id == tpl.id }) else { return }
        var copy = recurringTemplates
        copy[i] = tpl
        recurringTemplates = copy
        saveToUserDefaults()
        NotificationManager.rescheduleRecurringReminders(templates: recurringTemplates)
    }

    func deleteRecurringTemplate(_ tpl: RecurringTemplate) {
        recurringTemplates.removeAll { $0.id == tpl.id }
        saveToUserDefaults()
        NotificationManager.rescheduleRecurringReminders(templates: recurringTemplates)
    }

    func exportBundle() -> MoneyMapExportBundle {
        MoneyMapExportBundle(
            exportedAt: Date(),
            transactions: transactions,
            budgets: budgets,
            savingsGoals: savingsGoals,
            accounts: accounts,
            recurringTemplates: recurringTemplates,
            noteRules: noteRules
        )
    }

    func exportJSONData() throws -> Data {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        return try enc.encode(exportBundle())
    }

    func exportCSVString() -> String {
        var lines: [String] = ["type,date,amount,category,accountId,toAccountId,tags,note,location,favorite,id"]
        let iso = ISO8601DateFormatter()
        for t in transactions.sorted(by: { $0.date > $1.date }) {
            let tags = t.tags.joined(separator: ";")
            let note = (t.note ?? "").replacingOccurrences(of: ",", with: " ")
            let loc = (t.location ?? "").replacingOccurrences(of: ",", with: " ")
            lines.append(
                "\(t.type.rawValue),\(iso.string(from: t.date)),\(t.amount),\(t.category.rawValue),\(t.accountId.uuidString),\(t.toAccountId?.uuidString ?? ""),\(tags),\(note),\(loc),\(t.isFavorite),\(t.id.uuidString)"
            )
        }
        return lines.joined(separator: "\n")
    }

    func refreshBudgetSoftAlerts() {
        var alerts: [BudgetSoftAlert] = []
        for b in budgets where b.limit > 0 {
            let ratio = b.spent / b.limit
            if ratio >= 1.0 {
                alerts.append(BudgetSoftAlert(
                    id: b.id,
                    categoryName: b.category.rawValue,
                    message: "Limit reached — \(formatCurrency(b.spent)) of \(formatCurrency(b.limit)).",
                    level: 100
                ))
            } else if ratio >= 0.8 {
                alerts.append(BudgetSoftAlert(
                    id: b.id,
                    categoryName: b.category.rawValue,
                    message: "80% of budget used (\(Int(ratio * 100))%).",
                    level: 80
                ))
            }
        }
        budgetSoftAlerts = alerts.sorted { $0.level > $1.level }
    }

    private func mergedTags(for t: Transaction) -> [String] {
        guard t.type != .transfer else { return t.tags }
        let note = t.note?.lowercased() ?? ""
        var set = Set(t.tags.map { $0.lowercased() })
        for rule in noteRules where rule.category == t.category {
            if note.contains(rule.keyword.lowercased()) {
                set.insert(rule.tagToApply.lowercased())
            }
        }
        return Array(set).sorted()
    }

    private func normalizedTags(_ tags: [String]) -> [String] {
        Array(Set(tags.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "#", with: "")
                .lowercased()
        }.filter { !$0.isEmpty })).sorted()
    }

    private let transactionsKey = "moneymap_transactions"
    private let budgetsKey = "moneymap_budgets"
    private let goalsKey = "moneymap_goals"
    private let accountsKey = "moneymap_accounts"
    private let recurringKey = "moneymap_recurring"
    private let noteRulesKey = "moneymap_note_rules"

    func saveToUserDefaults() {
        let enc = JSONEncoder()
        if let data = try? enc.encode(transactions) { UserDefaults.standard.set(data, forKey: transactionsKey) }
        if let data = try? enc.encode(budgets) { UserDefaults.standard.set(data, forKey: budgetsKey) }
        if let data = try? enc.encode(savingsGoals) { UserDefaults.standard.set(data, forKey: goalsKey) }
        if let data = try? enc.encode(accounts) { UserDefaults.standard.set(data, forKey: accountsKey) }
        if let data = try? enc.encode(recurringTemplates) { UserDefaults.standard.set(data, forKey: recurringKey) }
        if let data = try? enc.encode(noteRules) { UserDefaults.standard.set(data, forKey: noteRulesKey) }
    }

    func loadFromUserDefaults() {
        let dec = JSONDecoder()

        if let data = UserDefaults.standard.data(forKey: accountsKey),
           let decoded = try? dec.decode([Account].self, from: data) {
            accounts = decoded.sorted { $0.sortOrder < $1.sortOrder }
        }

        if accounts.isEmpty {
            accounts = [Account.defaultWallet()]
            if let data = try? JSONEncoder().encode(accounts) {
                UserDefaults.standard.set(data, forKey: accountsKey)
            }
        }

        if let data = UserDefaults.standard.data(forKey: transactionsKey) {
            if let decoded = try? dec.decode([Transaction].self, from: data) {
                transactions = decoded
            } else if let legacy = try? dec.decode([LegacyTransaction].self, from: data) {
                let aid = primaryAccountId
                transactions = legacy.map {
                    Transaction(
                        id: $0.id,
                        date: $0.date,
                        amount: $0.amount,
                        category: $0.category,
                        type: $0.type,
                        note: $0.note,
                        location: $0.location,
                        isFavorite: $0.isFavorite,
                        createdAt: $0.createdAt,
                        accountId: aid,
                        toAccountId: nil,
                        tags: []
                    )
                }
                saveToUserDefaults()
            }
        }

        if let data = UserDefaults.standard.data(forKey: budgetsKey),
           let decoded = try? dec.decode([Budget].self, from: data) {
            budgets = decoded
        }
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? dec.decode([SavingsGoal].self, from: data) {
            savingsGoals = decoded
        }
        if let data = UserDefaults.standard.data(forKey: recurringKey),
           let decoded = try? dec.decode([RecurringTemplate].self, from: data) {
            recurringTemplates = decoded
        }
        if let data = UserDefaults.standard.data(forKey: noteRulesKey),
           let decoded = try? dec.decode([NoteRule].self, from: data) {
            noteRules = decoded
        }

        if transactions.isEmpty {
            loadDemoData()
            saveToUserDefaults()
        }

        refreshBudgetSoftAlerts()
        NotificationManager.rescheduleRecurringReminders(templates: recurringTemplates)
    }

    private func loadDemoData() {
        let aid = primaryAccountId
        let transaction1 = Transaction(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 2),
            amount: 50_000,
            category: .salary,
            type: .income,
            note: "Monthly salary",
            location: nil,
            isFavorite: true,
            createdAt: Date(),
            accountId: aid,
            toAccountId: nil,
            tags: ["payroll"]
        )

        let transaction2 = Transaction(
            id: UUID(),
            date: Date().addingTimeInterval(-86400),
            amount: 3_500,
            category: .food,
            type: .expense,
            note: "Groceries",
            location: "Supermarket",
            isFavorite: false,
            createdAt: Date(),
            accountId: aid,
            toAccountId: nil,
            tags: []
        )

        transactions = [transaction1, transaction2]

        budgets = [
            Budget(
                id: UUID(),
                category: .food,
                limit: 15_000,
                spent: 3_500,
                month: Calendar.current.component(.month, from: Date()),
                year: Calendar.current.component(.year, from: Date())
            )
        ]

        savingsGoals = [
            SavingsGoal(
                id: UUID(),
                name: "New MacBook",
                targetAmount: 150_000,
                currentAmount: 50_000,
                deadline: Date().addingTimeInterval(86400 * 180),
                notes: nil,
                isCompleted: false,
                createdAt: Date(),
                priority: 2,
                weeklyContributionTarget: 1_200
            )
        ]
    }
}
