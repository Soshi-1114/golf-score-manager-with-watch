//
//  ScoreListView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import SwiftUI

struct ScoreListView: View {
    let round: Round
  
  @State private var showAlert = false

    var body: some View {
      VStack(spacing: 16) {
        ScrollView(.horizontal) {
            VStack(alignment: .leading) {
                // ヘッダー行
                HStack {
                    Text("Hole")
                        .frame(width: 60, alignment: .leading)
                        .bold()
                    
                    ForEach(round.players) { player in
                        Text(player.name)
                            .frame(width: 80, alignment: .center)
                            .bold()
                    }
                }
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))

                // 各ホールのスコア行
                ForEach(0..<18, id: \.self) { holeIndex in
                    HStack {
                        Text("Hole \(holeIndex + 1)")
                            .frame(width: 60, alignment: .leading)
                        
                        ForEach(round.players) { player in
                            let score = player.holeScores[holeIndex]
                            Text("\(score.strokes)/\(score.putts)")
                                .frame(width: 80, alignment: .center)
                        }
                    }
                    .padding(.vertical, 2)
                }

                Divider()

                // 合計行
                HStack {
                    Text("合計")
                        .frame(width: 60, alignment: .leading)
                        .bold()
                    
                    ForEach(round.players) { player in
                        let totalStrokes = player.holeScores.map { $0.strokes }.reduce(0, +)
                        let totalPutts = player.holeScores.map { $0.putts }.reduce(0, +)
                        Text("\(totalStrokes)/\(totalPutts)")
                            .frame(width: 80, alignment: .center)
                            .bold()
                    }
                }
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.2))
            }
            .padding()
        }
        HStack {
          Spacer()

          Button(action: {
            RoundStorage.shared.save(round: round)
            showAlert = true
          }) {
              Text("このラウンドを保存")
                  .font(.headline)
                  .foregroundColor(.white)
                  .padding()
                  .background(Color.blue)
                  .cornerRadius(12)
          }

          Spacer()
      }
      .padding(.bottom, 20)
      .alert("保存完了", isPresented: $showAlert) {
          Button("OK", role: .cancel) {}
        } message: {
            Text("このラウンドは履歴に保存されました。")
        }
      }
      .navigationTitle("スコア一覧")
      .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    let mockPlayers = [
        PlayerScore(
            id: UUID(),
            name: "山田",
            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: Int.random(in: 3...6), putts: Int.random(in: 1...3)) }
        ),
        PlayerScore(
            id: UUID(),
            name: "佐藤",
            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: Int.random(in: 3...6), putts: Int.random(in: 1...3)) }
        ),
//        PlayerScore(
//            id: UUID(),
//            name: "本村",
//            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: Int.random(in: 3...6), putts: Int.random(in: 1...3)) }
//        ),
//        PlayerScore(
//            id: UUID(),
//            name: "森田",
//            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: Int.random(in: 3...6), putts: Int.random(in: 1...3)) }
//        )
    ]

    let mockRound = Round(
        id: UUID(),
        date: Date(),
        name: "プレビューラウンド",
        players: mockPlayers
    )

    return NavigationStack {
        ScoreListView(round: mockRound)
    }
}

