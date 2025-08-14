//
//  PersonalContentView.swift
//  CopyHelper
//
//  Created by 山上尚真 on 2025/08/15.
//

import SwiftUI

struct PersonalContentView: View {
    private let protectedKeys: Set<String> = ["住所", "名前", "電話番号"]

    // UserDefaults のキー
    private let orderKey = "personal.keysOrder"
    private let itemsKey = "personal.items"

    // 初期値（初回のみ使用）
    private let defaultOrder = ["住所", "名前", "電話番号"]
    private let defaultItems: [String: String] = [
        "名前": "",
        "住所": "",
        "電話番号": ""
    ]

    @State private var keysOrder: [String] = []
    @State private var items: [String: String] = [:]

    @State private var selectedKey: String? = nil
    @State private var textInput: String = ""
    @State private var showAddView = false

    var body: some View {
        VStack(spacing: 8) {
            // 選択 + 入力
            HStack(spacing: 8) {
                Picker("項目を選択", selection: $selectedKey) {
                    ForEach(keysOrder, id: \.self) { key in
                        Text(key).tag(Optional(key))
                    }
                }
                .pickerStyle(.menu)

                TextField("入力してください", text: $textInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            .onChange(of: selectedKey) { _ in
                textInput = ""
            }

            // 保存 & 追加
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

            // リスト表示
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if !protectedKeys.contains(key) {
                            Button(role: .destructive) {
                                delete(key: key)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("個人情報")
        .toolbar { EditButton() }
        .sheet(isPresented: $showAddView) {
            AddItemView(items: $items, keysOrder: $keysOrder)
        }
        .onAppear {
            // 1回だけロード
            if keysOrder.isEmpty && items.isEmpty {
                keysOrder = Persistence.load([String].self, forKey: orderKey, default: defaultOrder)
                items = Persistence.load([String:String].self, forKey: itemsKey, default: defaultItems)
            }
            // 最低限 保護キーは存在するように整える
            for k in protectedKeys where !keysOrder.contains(k) { keysOrder.insert(k, at: 0) }
            for k in protectedKeys where items[k] == nil { items[k] = "" }

            if selectedKey == nil { selectedKey = keysOrder.first }
        }
        // 変更があれば即保存
        .onChange(of: keysOrder) { newValue in
            Persistence.save(newValue, forKey: orderKey)
        }
        .onChange(of: items) { newValue in
            Persistence.save(newValue, forKey: itemsKey)
        }
    }

    private func delete(key: String) {
        guard !protectedKeys.contains(key) else { return }
        if let idx = keysOrder.firstIndex(of: key) { keysOrder.remove(at: idx) }
        items.removeValue(forKey: key)
        if selectedKey == key {
            selectedKey = keysOrder.first
            textInput = ""
        }
    }
}
