//
//  ScoreInputView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import SwiftUI

struct ScoreInputView: View {
    @State private var currentHole = 1
    @State private var round: Round
  @State private var isShowingScoreList = false

    // 明示的な初期化子を定義
    init(round: Round) {
        _round = State(initialValue: round)
    }

    var body: some View {
        VStack {
            Text("Hole \(currentHole)/18")
                .font(.title2)
                .padding(.top)

            List {
                ForEach($round.players) { $player in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(player.name)
                            .font(.headline)

                        let scoreIndex = currentHole - 1

                        HStack {
                            Stepper("打数: \(player.holeScores[scoreIndex].strokes)", value: $player.holeScores[scoreIndex].strokes, in: 0...20)
                            Spacer()
                            Stepper("パット: \(player.holeScores[scoreIndex].putts)", value: $player.holeScores[scoreIndex].putts, in: 0...10)
                        }
                    }
                }
            }

            HStack {
                Button("◀︎ 前") {
                    if currentHole > 1 {
                        currentHole -= 1
                    }
                }
                .disabled(currentHole == 1)

                Spacer()

                Button("次 ▶︎") {
                    if currentHole < 18 {
                        currentHole += 1
                    }
                }
                .disabled(currentHole == 18)
            }
            .padding(.horizontal)
            .padding(.bottom)

            Button("一覧表示へ") {
              isShowingScoreList = true
            }
            .padding(.bottom)
        }
        .navigationTitle(round.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingScoreList) {
            ScoreListView(round: round)
        }
    }
}



#Preview {
    let mockPlayers = [
        PlayerScore(
            id: UUID(),
            name: "山田",
            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: 0, putts: 0) }
        ),
        PlayerScore(
            id: UUID(),
            name: "佐藤",
            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: 0, putts: 0) }
        )
    ]

    let mockRound = Round(
        id: UUID(),
        date: Date(),
        name: "プレビューテストラウンド",
        players: mockPlayers
    )

    return ScoreInputView(round: mockRound)
}

