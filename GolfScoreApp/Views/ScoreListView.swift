//
//  ScoreListView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import SwiftUI

struct ScoreListView: View {
  @ObservedObject var appModel = AppModel.shared
      var isEditable: Bool = true

      var body: some View {
          if let round = appModel.currentRound {
              ScoreListContentView(round: round, isEditable: isEditable)
          } else {
              Text("スコアデータが存在しません")
          }
      }
}

// #Preview {
//    let mockPlayers = [
//        PlayerScore(
//            id: UUID(),
//            name: "山田",
//            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: Int.random(in: 3...6), putts: Int.random(in: 1...3)) }
//        ),
//        PlayerScore(
//            id: UUID(),
//            name: "佐藤",
//            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: Int.random(in: 3...6), putts: Int.random(in: 1...3)) }
//        )
//    ]
//
//    let mockRound = Round(
//        id: UUID(),
//        date: Date(),
//        name: "プレビューラウンド",
//        players: mockPlayers
//    )
//
//    return ScoreListView(round: .constant(mockRound), isEditable: true)
// }
