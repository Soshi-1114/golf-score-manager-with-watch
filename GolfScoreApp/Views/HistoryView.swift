//
//  HistoryView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import SwiftUI

struct HistoryView: View {
    @Binding var savedRound: Round?
    @State private var rounds: [Round] = []
    @State private var selectedRound: Round? = nil
    @State private var showEditConfirmation = false

    var body: some View {
        NavigationView {
            List {
                ForEach(rounds) { round in
                    Button {
                        selectedRound = round
                        showEditConfirmation = true
                    } label: {
                      HStack {
                        VStack(alignment: .leading) {
                          if let player = round.players.first {
                              let totalStrokes = player.holeScores.map { $0.strokes }.reduce(0, +)
                              let totalPutts = player.holeScores.map { $0.putts }.reduce(0, +)
                              ZStack {
                                Text("\(totalStrokes)")
                                  .font(.system(size: 35, weight: .bold))
                                
                                  GeometryReader { geo in
                                    Text("\(totalPutts)")
                                      .font(.system(size: 20, weight: .bold))
                                      .position(x: geo.size.width - 12, y: geo.size.height - 17)
                                  }
                              }
                              .frame(width: 110, height: 40)
                              .foregroundColor(.black)
                            }
                            
                            Text(dateFormatter.string(from: round.date))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                          Text(round.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        }
                      }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("履歴")
            .onAppear {
                rounds = RoundStorage.shared.load()
            }
            .confirmationDialog("このスコアを編集しますか？", isPresented: $showEditConfirmation) {
                Button("編集") {
                    if let selected = selectedRound {
                        savedRound = selected
                        AppModel.shared.currentRound = selected
                        WCSessionManager.shared.sendRoundToWatch(round: selected)
                        NotificationCenter.default.post(name: .navigateToScoreTab, object: nil)
                    }
                }
                Button("閲覧のみ") {
                    if let selected = selectedRound {
                        NotificationCenter.default.post(name: .previewRound, object: nil, userInfo: ["round": selected])
                    }
                }
                Button("キャンセル", role: .cancel) {}
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        RoundStorage.shared.delete(at: offsets)
        rounds.remove(atOffsets: offsets)
    }

  private var dateFormatter: DateFormatter {
      let df = DateFormatter()
      df.locale = Locale(identifier: "ja_JP")
      df.dateFormat = "yyyy年MM月dd日"
      return df
  }

}



#Preview {
  HistoryView(savedRound: .constant(nil))
}
