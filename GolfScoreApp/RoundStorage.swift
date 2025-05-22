//
//  RoundStorage.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import Foundation

class RoundStorage {
    static let shared = RoundStorage()
    private let key = "savedRounds"

    func save(round: Round) {
        var rounds = load()
        rounds.append(round)
        saveAll(rounds)
    }

    func load() -> [Round] {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Round].self, from: data) {
            return decoded
        }
        return []
    }

    func delete(at offsets: IndexSet) {
        var rounds = load()
        rounds.remove(atOffsets: offsets)
        saveAll(rounds)
    }

    private func saveAll(_ rounds: [Round]) {
        if let data = try? JSONEncoder().encode(rounds) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}


