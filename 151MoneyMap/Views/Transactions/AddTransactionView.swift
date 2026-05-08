//
//  AddTransactionView.swift
//  151MoneyMap
//

import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var viewModel: MoneyMapViewModel

    var body: some View {
        TransactionEditorView(viewModel: viewModel, mode: .add)
    }
}
