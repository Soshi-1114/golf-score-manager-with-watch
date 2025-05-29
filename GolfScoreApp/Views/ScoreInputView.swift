//
//  ScoreInputView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import SwiftUI

struct ScoreInputView: View {
  @Binding var round: Round
  @State private var currentHole: Int
  
  @ObservedObject private var phoneSession = PhoneSessionManager.shared

  init(round: Binding<Round>, startHole: Int = 1) {
      _round = round
      _currentHole = State(initialValue: startHole)
  }


  var body: some View {
    VStack {
      HStack {
        Button("◀︎ 前のホール") {
          if currentHole > 1 { currentHole -= 1 }
        }
        .disabled(currentHole == 1)

        Spacer()

        Text("Hole \(currentHole)/18")
          .font(.title2)
          .bold()

        Spacer()

        Button("次のホール ▶︎") {
          if currentHole < 18 { currentHole += 1 }
        }
        .disabled(currentHole == 18)
      }
      .padding(.horizontal)
      .padding(.top)
      
      Stepper(
        "Par: \(round.parList[currentHole - 1])",
        value: $round.parList[currentHole - 1],
        in: 3...5
      )
      .padding(.horizontal)
      .padding(.bottom, 4)


      List {
        ForEach($round.players) { $player in
          VStack(alignment: .leading, spacing: 4) {
            Text(player.name)
              .font(.headline)

            let scoreIndex = currentHole - 1
            let strokes = player.holeScores[scoreIndex].strokes
            let putts = player.holeScores[scoreIndex].putts

            HStack(alignment: .top) {
              // 左側：打数 / パット数 表示
              VStack(alignment: .leading, spacing: 2) {
                Text("\(strokes)")
                  .font(.system(size: 40, weight: .bold, design: .default))
                + Text(" / \(putts)")
                  .font(.system(size: 20, weight: .bold, design: .default))
                  .foregroundColor(.gray)
              }

              Spacer()

              // 右側：Stepers 縦に配置
              VStack(alignment: .trailing, spacing: 8) {
                HStack {
                  Text("打数:")
                    .fixedSize()
                  Stepper("", value: $player.holeScores[scoreIndex].strokes, in: 0...20)
                    .labelsHidden()
                }
                HStack {
                  Text("パット:")
                    .fixedSize()
                  Stepper("", value: $player.holeScores[scoreIndex].putts, in: 0...10)
                    .labelsHidden()
                }
              }
              .font(.subheadline)
            }
            .padding(8)
            .cornerRadius(10)
          }
          .padding(.vertical, 6)
        }
      }
    }
    .onReceive(phoneSession.$receivedStrokes) { newStrokes in
        // Watchから来た配列の長さが18以上なら反映
        guard newStrokes.count >= round.players.count * 18 else { return }
        // プレイヤー1人目のスコアに反映する
        for holeIdx in 0..<min(18, newStrokes.count) {
            round.players[0].holeScores[holeIdx].strokes = newStrokes[holeIdx]
        }
      }
    .onDisappear {
        RoundPersistence.save(round)
    }
    .navigationTitle(round.name)
    .navigationBarTitleDisplayMode(.inline)
  }
}



#Preview {
    let mockPlayers = [
        PlayerScore(
            id: UUID(),
            name: "山田",
            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: 3, putts: 2) }
        ),
        PlayerScore(
            id: UUID(),
            name: "佐藤",
            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: 4, putts: 1) }
        )
    ]

    let mockRound = Round(
        id: UUID(),
        date: Date(),
        name: "プレビューテストラウンド",
        players: mockPlayers
    )

    return ScoreInputView(round: .constant(mockRound), startHole: 1)
}


