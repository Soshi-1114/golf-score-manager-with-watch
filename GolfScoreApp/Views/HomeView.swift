//
//  HomeView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/28.
//

import SwiftUI

struct HomeView: View {
    @Binding var round: Round?
    @Binding var showSetupSheet: Bool // ← 追加

    @State private var averageScore: Int? = nil
    @State private var showConfirmation = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            if let round = round {
                VStack(spacing: 16) {
                    Text("スコア入力中です")
                        .font(.title3)

                    Button("スコア入力を完了しますか？") {
                        showConfirmation = true
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .confirmationDialog("スコア入力を完了し、保存しますか？", isPresented: $showConfirmation, titleVisibility: .visible) {
                        Button("保存して完了", role: .destructive) {
                            RoundStorage.shared.save(round: round)
                            RoundPersistence.clear()
                            self.round = nil
                        }
                        Button("キャンセル", role: .cancel) {}
                    }
                }
            } else {
                Button("新しいラウンドを開始") {
                    showSetupSheet = true // ← シート表示トリガー
                }
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }

            if let avg = averageScore {
                Text("平均スコア: \(avg)")
                    .font(.title3)
                    .padding()
            } else {
                Text("平均スコアを読み込み中...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(.top)
        .onAppear {
            averageScore = calculateAverageScore()
        }
    }

  func calculateAverageScore() -> Int? {
      let rounds = RoundStorage.shared.loadAll()

      // プレイヤー1（各ラウンドの1番目のプレイヤー）の合計スコアのみを対象にする
      let player1Scores = rounds.compactMap { round -> Int? in
          guard let player1 = round.players.first else { return nil }
          return player1.holeScores.map { $0.strokes }.reduce(0, +)
      }

      guard !player1Scores.isEmpty else { return nil }

      let total = player1Scores.reduce(0, +)
      return total / player1Scores.count
  }

}


//#Preview {
//    HomeView()
//}
