//
//  AppModel.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/29.
//

import Foundation

class AppModel: ObservableObject {
    static let shared = AppModel()

  @Published var currentRound: Round? {
          didSet {
              if let round = currentRound {
                  RoundPersistence.save(round)
              }
          }
      }

    private init() {
      self.currentRound = RoundPersistence.load()
    }

    // MARK: - ラウンドの初期化
    func startNewRound(name: String, players: [String]) {
        let playerScores = players.map { name in
            PlayerScore(id: UUID(), name: name, holeScores: (1...18).map {
                HoleScore(holeNumber: $0, strokes: 0, putts: 0)
            })
        }

        currentRound = Round(
            id: UUID(),
            date: Date(),
            name: name,
            players: playerScores
        )
    }

    // MARK: - Watchからのスコア受信
  func updateScoresFromWatch(strokes: [Int], putts: [Int]) {
      guard var round = currentRound else { return }

      if let index = round.players.firstIndex(where: { $0.name == "Me" }) {
          for i in 0..<min(18, strokes.count, putts.count) {
              round.players[index].holeScores[i].strokes = strokes[i]
              round.players[index].holeScores[i].putts = putts[i]
          }
          currentRound = round
      }
  }
}
