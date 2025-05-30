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
      guard let data = UserDefaults.standard.data(forKey: key),
            let round = try? JSONDecoder().decode(Round.self, from: data) else {
          return nil
      }
      return round
    }

    static func clear() {
      print("clear called")
        UserDefaults.standard.removeObject(forKey: key)
    }
}

