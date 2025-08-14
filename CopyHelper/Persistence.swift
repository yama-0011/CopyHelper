//
//  Persistence.swift
//  CopyHelper
//
//  Created by 山上尚真 on 2025/08/15.
//

import Foundation

enum Persistence {
    static func save<T: Encodable>(_ value: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Save error for \(key):", error)
        }
    }

    static func load<T: Decodable>(_ type: T.Type, forKey key: String, default defaultValue: T) -> T {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return defaultValue
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Load error for \(key):", error)
            return defaultValue
        }
    }
}
