//
//  CreditCardView.swift
//  CopyHelper
//
//  Created by 山上尚真 on 2025/08/15.
//

import SwiftUI

struct CreditCardView: View {
    private let orderKey = "card.keysOrder"
    private let itemsKey = "card.items"

    private let defaultOrder = ["カード番号", "有効期限", "セキュリティコード"]
    private let defaultItems: [String: String] = [
        "カード番号": "",
        "有効期限": "",
        "セキュリティコード": ""
    ]

    @State private var keysOrder: [String] = []
    @State private var items: [String: String] = [:]

    @State private var selectedKey: String? = nil
    @State private var textInput: String = ""
    @State private var showAddView = false

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Picker("項目を選択", selection: $selectedKey) {
                    ForEach(keysOrder, id: \.self) { key in
                        Text(key).tag(Optional(key))
                    }
                }
                .pickerStyle(.menu)

                TextField("内容を入力（例: 1234-5678-9012-3456）", text: $textInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numbersAndPunctuation)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            .padding(.horizontal)
            .onChange(of: selectedKey) { _ in
                textInput = ""
            }

            HStack(spacing: 8) {
                Button("保存") {
                    if let key = selectedKey {
                        items[key] = textInput
                        textInput = ""
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)

                Button("Add") { showAddView = true }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
            }
            .padding(.horizontal)

            Divider().padding(.vertical, 4)

            List {
                ForEach(keysOrder, id: \.self) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key).bold()
                        Text(items[key] ?? "")
                            .textSelection(.enabled)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                UIPasteboard.general.string = items[key] ?? ""
                            }
                    }
                    .padding(.vertical, 4)
                    .swipeActions {
                        Button(role: .destructive) {
                            if let idx = keysOrder.firstIndex(of: key) { keysOrder.remove(at: idx) }
                            items.removeValue(forKey: key)
                            if selectedKey == key {
                                selectedKey = keysOrder.first
                                textInput = ""
                            }
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("クレジットカード")
        .toolbar { EditButton() }
        .sheet(isPresented: $showAddView) {
            AddItemView(items: $items, keysOrder: $keysOrder)
        }
        .onAppear {
            if keysOrder.isEmpty && items.isEmpty {
                keysOrder = Persistence.load([String].self, forKey: orderKey, default: defaultOrder)
                items = Persistence.load([String:String].self, forKey: itemsKey, default: defaultItems)
            }
            if selectedKey == nil { selectedKey = keysOrder.first }
        }
        .onChange(of: keysOrder) { Persistence.save($0, forKey: orderKey) }
        .onChange(of: items) { Persistence.save($0, forKey: itemsKey) }
    }
}
