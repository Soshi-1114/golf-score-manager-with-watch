//
//  AppModel.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/29.
//

import Foundation

class AppModel: ObservableObject {
    static let shared = AppModel()
    private var isUpdatingFromWatch = false
    private var lastSyncedStrokes: [Int] = []
    private var lastSyncedPutts: [Int] = []

    @Published var isWatchSyncEnabled: Bool {
        didSet {
            // トグル変更時に即保存
            UserDefaults.standard.set(isWatchSyncEnabled, forKey: "watchSyncEnabled")
        }
    }

    @Published var currentRound: Round? {
        didSet {
            if let round = currentRound {
                RoundPersistence.save(round)
            }
        }
    }

    init() {
        self.currentRound = RoundPersistence.load()
        self.isWatchSyncEnabled = UserDefaults.standard.object(forKey: "watchSyncEnabled") as? Bool ?? true

        WCSessionManager.shared.onScoreReceived = { [weak self] strokes, putts in
            self?.updateScoresFromWatch(strokes: strokes, putts: putts)
        }
    }

    // MARK: - ラウンドの初期化

    func startNewRound(name: String, players: [String]) {
        let playerScores = players.map { name in
            PlayerScore(id: UUID(), name: name, holeScores: (1 ... 18).map {
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
        guard let index = round.players.firstIndex(where: { $0.name == "Me" }) else { return }

        isUpdatingFromWatch = true

        for i in 0..<min(18, strokes.count, putts.count) {
            round.players[index].holeScores[i].strokes = strokes[i]
            round.players[index].holeScores[i].putts = putts[i]
        }

        self.lastSyncedStrokes = strokes
        self.lastSyncedPutts = putts
        self.currentRound = round
        isUpdatingFromWatch = false
    }
  
  func isFromWatchUpdate() -> Bool {
      return isUpdatingFromWatch
  }
  
  func lastSyncedValues() -> ([Int], [Int]) {
      return (lastSyncedStrokes, lastSyncedPutts)
  }
}
