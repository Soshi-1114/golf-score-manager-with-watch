//
//  CompanionStorage.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/29.
//

import Foundation

class CompanionStorage {
    static let shared = CompanionStorage()
    private let key = "savedCompanions"

    func save(names: [String]) {
        let nonEmptyNames = names.filter { !$0.isEmpty }
        UserDefaults.standard.set(nonEmptyNames, forKey: key)
    }

    func load() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }
}

