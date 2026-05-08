//
//  ExportBackupView.swift
//  151MoneyMap
//

import SwiftUI

private struct SharePayload: Identifiable {
    let id = UUID()
    let url: URL
}

struct ExportBackupView: View {
    @ObservedObject var viewModel: MoneyMapViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var useJSON = true
    @State private var sharePayload: SharePayload?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.moneyBackground
                    .ignoresSafeArea()

                Form {
                    Section {
                        Picker("Format", selection: $useJSON) {
                            Text("JSON").tag(true)
                            Text("CSV").tag(false)
                        }
                        .pickerStyle(.segmented)

                        Button("Create file & share") {
                            prepareExport()
                        }
                        .foregroundColor(.moneyAccent)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.moneyExpense)
                        }
                    }
                    .listRowBackground(Color.moneyBackground.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .tint(.moneyAccent)
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.moneyAccent)
                }
            }
            .sheet(item: $sharePayload) { payload in
                ActivityShareSheet(activityItems: [payload.url])
            }
        }
    }

    private func prepareExport() {
        errorMessage = nil
        let dir = FileManager.default.temporaryDirectory
        do {
            if useJSON {
                let data = try viewModel.exportJSONData()
                let url = dir.appendingPathComponent("MoneyMap-backup-\(Int(Date().timeIntervalSince1970)).json")
                try data.write(to: url)
                sharePayload = SharePayload(url: url)
            } else {
                let csv = viewModel.exportCSVString()
                let url = dir.appendingPathComponent("MoneyMap-transactions-\(Int(Date().timeIntervalSince1970)).csv")
                try csv.data(using: .utf8)?.write(to: url)
                sharePayload = SharePayload(url: url)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
