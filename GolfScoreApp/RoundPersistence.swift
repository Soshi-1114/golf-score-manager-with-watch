//
//  RoundPersistence.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/27.
//

import Foundation

struct RoundPersistence {
    private static let key = "currentRound"

    static func save(_ round: Round) {
        if let data = try? JSONEncoder().encode(round) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> Round? {
        if let data = UserDefaults.standard.data(forKey: key),
           let round = try? JSONDecoder().decode(Round.self, from: data) {
            return round
        }
        return nil
    }

    static func clear() {
      print("clear called")
        UserDefaults.standard.removeObject(forKey: key)
    }
}

