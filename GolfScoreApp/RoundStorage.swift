//
//  RoundStorage.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import Foundation

class RoundStorage {
    static let shared = RoundStorage()
    private let storageKey = "savedRounds"

    func load() -> [Round] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let rounds = try? JSONDecoder().decode([Round].self, from: data)
        else {
            return []
        }
        return rounds
    }

    func save(round: Round) {
        var rounds = load()

        if let index = rounds.firstIndex(where: { $0.id == round.id }) {
            // 既存のラウンドがある → 上書き
            rounds[index] = round
        } else {
            // 新規ラウンド → 追加
            rounds.append(round)
        }

        if let data = try? JSONEncoder().encode(rounds) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func delete(at offsets: IndexSet) {
        var rounds = load()
        rounds.remove(atOffsets: offsets)
        if let data = try? JSONEncoder().encode(rounds) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func loadAll() -> [Round] {
        return load()
    }

    func deleteAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
