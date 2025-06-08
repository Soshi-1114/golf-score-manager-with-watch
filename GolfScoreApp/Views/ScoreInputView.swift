//
//  ScoreInputView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import SwiftUI
import WatchConnectivity

struct ScoreInputView: View {
    @Binding var round: Round
    @State private var currentHole: Int
    @State private var debounceTask: DispatchWorkItem?

    @AppStorage("isWatchSyncEnabled") private var isWatchSyncEnabled = false

    init(round: Binding<Round>, startHole: Int = 1) {
        _round = round
        _currentHole = State(initialValue: startHole)
    }

    func sendScoreToWatch() {
        guard isWatchSyncEnabled else { return }
        guard !AppModel.shared.isFromWatchUpdate() else { return }

        let strokes = round.players.first?.holeScores.map { $0.strokes } ?? Array(repeating: 0, count: 18)
            let putts = round.players.first?.holeScores.map { $0.putts } ?? Array(repeating: 0, count: 18)

            // 差分がない場合は送信しない
            let (lastStrokes, lastPutts) = AppModel.shared.lastSyncedValues()
            guard strokes != lastStrokes || putts != lastPutts else {
                print("⏭ 変化なしのため送信スキップ")
                return
            }
          debounceTask?.cancel()
          let task = DispatchWorkItem {
              WCSessionManager.shared.sendScoreToWatch(strokes: strokes, putts: putts)
          }
          debounceTask = task
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: task)
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
                in: 3 ... 5
            )
            .padding(.horizontal)
            .padding(.bottom, 4)

            List {
                ForEach($round.players) { $player in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(player.name)
                            .font(.headline)

                        let scoreIndex = currentHole - 1
                        let strokesBinding = $player.holeScores[scoreIndex].strokes
                        let puttsBinding = $player.holeScores[scoreIndex].putts

                        HStack(alignment: .top) {
                            // 左側：打数 / パット数 表示
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(player.holeScores[scoreIndex].strokes)")
                                    .font(.system(size: 40, weight: .bold))
                                    + Text(" / \(player.holeScores[scoreIndex].putts)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // 右側：Stepers 縦に配置
                            VStack(alignment: .trailing, spacing: 8) {
                                HStack {
                                    Text("打数:")
                                    Stepper("", value: strokesBinding, in: 0 ... 20)
                                        .labelsHidden()
                                        .onChange(of: strokesBinding.wrappedValue) {
                                            sendScoreToWatch()
                                        }
                                }
                                HStack {
                                    Text("パット:")
                                    Stepper("", value: puttsBinding, in: 0 ... 10)
                                        .labelsHidden()
                                        .onChange(of: puttsBinding.wrappedValue) {
                                            sendScoreToWatch()
                                        }
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
        .onDisappear {
            RoundPersistence.save(round)
        }
        .navigationTitle(round.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// #Preview {
//    let mockPlayers = [
//        PlayerScore(
//            id: UUID(),
//            name: "山田",
//            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: 3, putts: 2) }
//        ),
//        PlayerScore(
//            id: UUID(),
//            name: "佐藤",
//            holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: 4, putts: 1) }
//        )
//    ]
//
//    let mockRound = Round(
//        id: UUID(),
//        date: Date(),
//        name: "プレビューテストラウンド",
//        players: mockPlayers
//    )
//
//    return ScoreInputView(round: .constant(mockRound), startHole: 1)
// }
