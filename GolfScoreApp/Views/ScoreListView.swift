//
//  ScoreListView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import SwiftUI

struct ScoreListView: View {
  @Binding var round: Round

  @State private var didRegister = false
  @Environment(\.dismiss) private var dismiss
  var isEditable: Bool = true

    var body: some View {
      VStack(spacing: 0) {
          // スコアカードタイトル + 登録ボタン 横並び
          HStack(spacing: 0) {
              Text("スコアカード")
                  .font(.title2)
                  .bold()
              Spacer()
            if !isEditable {
                Text("（編集不可）")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
            }
          }
          .padding(.horizontal)
          .padding(.top)

          Divider()

          ScrollView {
              HStack(alignment: .top, spacing: 0) {
                  // 固定列（Hole + Par）
                  VStack(alignment: .center, spacing: 5) {
                      // ヘッダー
                      HStack {
                          Text("Hole\nNo.")
                              .font(.system(size: 10, weight: .bold))
                              .multilineTextAlignment(.center)
                              .frame(width: 25, alignment: .center)
                          Text("Par")
                              .font(.system(size: 15, weight: .bold))
                              .frame(width: 25, alignment: .trailing)
                      }

                      // 各ホールの行
                      ForEach(0..<18) { holeIndex in
                          if holeIndex == 9 {
                              Divider()
                              HStack(spacing: 0) {
                                Text("Half")
                                .font(.system(size: 15, weight: .regular))
                                .multilineTextAlignment(.leading)
                                .frame(width: 55, height: 44, alignment: .center)
                                
                              }
                              Divider()
                          }

                          HStack(spacing: 0) {
                              Text(" \(holeIndex + 1)")
                                  .font(.system(size: 20, weight: .bold))
                                  .frame(width: 30, height: 44, alignment: .leading)
                                  .foregroundColor(.green)
                              Text("\(round.parList[holeIndex])")
                                  .font(.system(size: 20))
                                  .frame(width: 25, height: 44, alignment: .trailing)
                                  .foregroundColor(.gray)
                          }
                      }

                      Divider()
                      HStack(spacing: 0) {
                          Text("Half")
                          .font(.system(size: 15, weight: .regular))
                          .multilineTextAlignment(.leading)
                          .frame(width: 55, height: 44, alignment: .center)
                      }
                      Divider()

                      HStack(spacing: 0) {
                          Text("Gross")
                              .font(.system(size: 15, weight: .regular))
                              .multilineTextAlignment(.leading)
                              .frame(width: 55, height: 44, alignment: .center)
                      }
                  }

                // プレイヤー列
                VStack(alignment: .center, spacing: 5) {
                    // ヘッダー（常に4列）
                    HStack(spacing: 0) {
                        ForEach(0..<4, id: \.self) { i in
                            if i < round.players.count {
                                Text(round.players[i].name)
                                    .font(.system(size: 20, weight: .bold))
                                    .frame(width: 80, alignment: .center)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            } else {
                                Spacer().frame(width: 60) // 空の列
                            }
                        }
                    }

                    // 各ホールの行（同じく4列）
                    ForEach(0..<18) { holeIndex in
                        if holeIndex == 9 {
                            Divider()
                            HStack(spacing: 0) {
                                ForEach(0..<4, id: \.self) { i in
                                    if i < round.players.count {
                                        let player = round.players[i]
                                        let frontStrokes = player.holeScores[0..<9].map { $0.strokes }.reduce(0, +)
                                        let frontPutts = player.holeScores[0..<9].map { $0.putts }.reduce(0, +)
                                        TotalScoreCell(score: frontStrokes, putt: frontPutts)
                                            .frame(width: 80, height: 44)
                                    } else {
                                        Spacer().frame(width: 60, height: 44)
                                    }
                                }
                            }
                            Divider()
                        }

                        HStack(spacing: 0) {
                            ForEach(0..<4, id: \.self) { i in
                                if i < round.players.count {
                                    let player = round.players[i]
                                    let score = player.holeScores[holeIndex]

                                    if isEditable {
                                        Button {
                                            NotificationCenter.default.post(name: .navigateToHole, object: nil, userInfo: ["hole": holeIndex])
                                        } label: {
                                            ScoreCell(score: score.strokes, putt: score.putts, par: round.parList[holeIndex])
                                                .frame(width: 80, height: 44)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        ScoreCell(score: score.strokes, putt: score.putts, par: round.parList[holeIndex])
                                            .frame(width: 80, height: 44)
                                    }
                                } else {
                                    Spacer().frame(width: 60, height: 44)
                                }
                            }
                        }
                    }

                    Divider()

                    // 合計行も同様に補完
                    HStack(spacing: 0) {
                        ForEach(0..<4, id: \.self) { i in
                            if i < round.players.count {
                                let player = round.players[i]
                                let backStrokes = player.holeScores[9..<18].map { $0.strokes }.reduce(0, +)
                                let backPutts = player.holeScores[9..<18].map { $0.putts }.reduce(0, +)
                                TotalScoreCell(score: backStrokes, putt: backPutts)
                                    .frame(width: 80, height: 44)
                            } else {
                                Spacer().frame(width: 60, height: 44)
                            }
                        }
                    }

                    Divider()

                    HStack(spacing: 0) {
                        ForEach(0..<4, id: \.self) { i in
                            if i < round.players.count {
                                let player = round.players[i]
                                let totalStrokes = player.holeScores.map { $0.strokes }.reduce(0, +)
                                let totalPutts = player.holeScores.map { $0.putts }.reduce(0, +)
                                TotalScoreCell(score: totalStrokes, putt: totalPutts)
                                    .frame(width: 80, height: 44)
                            } else {
                                Spacer().frame(width: 60, height: 44)
                            }
                        }
                    }
                }

              }
              .padding()
          }
      }
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
//            name: "佐藤",
//            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: Int.random(in: 3...6), putts: Int.random(in: 1...3)) }
//        ),
//        PlayerScore(
//            id: UUID(),
//            name: "佐藤",
//            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: Int.random(in: 3...6), putts: Int.random(in: 1...3)) }
//        )
    ]

    let mockRound = Round(
        id: UUID(),
        date: Date(),
        name: "プレビューラウンド",
        players: mockPlayers
    )

    return ScoreListView(round: .constant(mockRound), isEditable: true)
}

