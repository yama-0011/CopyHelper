//
//  AddItemView.swift
//  CopyHelper
//
//  Created by 山上尚真 on 2025/08/15.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var items: [String: String]
    @Binding var keysOrder: [String]

    @State private var newKey: String = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 12) {
            TextField("新しい項目名を入力", text: $newKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Add") {
                let key = newKey.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !key.isEmpty else {
                    errorMessage = "項目名を入力してください。"
                    showErrorAlert = true
                    return
                }

                if keysOrder.contains(key) {
                    errorMessage = "同じ項目名が既に存在します。"
                    showErrorAlert = true
                    return
                }

                items[key] = ""
                keysOrder.append(key)
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .buttonStyle(.borderedProminent)
        }
        .padding(.top, 20)
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("エラー"),
                  message: Text(errorMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
}
