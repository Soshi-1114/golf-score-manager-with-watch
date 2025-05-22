//
//  SwiftUIView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import SwiftUI

struct RoundSetupView: View {
    @State private var roundName = ""
    @State private var playerNames = Array(repeating: "", count: 4)
    @State private var roundToStart: Round? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("ラウンド名")) {
                    TextField("例: コンペ @富士コース", text: $roundName)
                }

                Section(header: Text("プレイヤー名")) {
                    ForEach(0..<4, id: \.self) { index in
                        TextField("プレイヤー \(index + 1)", text: $playerNames[index])
                    }
                }

                Section {
                    Button("ラウンド開始") {
                        startRound()
                    }
                    .disabled(roundName.isEmpty || playerNames.allSatisfy { $0.isEmpty })
                }
            }
            .navigationTitle("ラウンドの設定")
            .navigationDestination(item: $roundToStart) { round in
                ScoreInputView(round: round)
            }
        }
    }

    private func startRound() {
        let players = playerNames
            .filter { !$0.isEmpty }
            .map { name in
                PlayerScore(
                    id: UUID(),
                    name: name,
                    holeScores: (1...18).map {
                        HoleScore(holeNumber: $0, strokes: 0, putts: 0)
                    }
                )
            }

        let newRound = Round(
            id: UUID(),
            date: Date(),
            name: roundName,
            players: players
        )

        roundToStart = newRound
    }
}



#Preview {
  RoundSetupView()
}
