//
//  HistoryView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import SwiftUI

struct HistoryView: View {
    @State private var rounds: [Round] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(rounds) { round in
                    NavigationLink(destination: ScoreListView(round: round)) {
                        VStack(alignment: .leading) {
                            Text(round.name)
                                .font(.headline)
                            Text(dateFormatter.string(from: round.date))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("履歴")
            .onAppear {
                rounds = RoundStorage.shared.load()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        // 削除処理
        RoundStorage.shared.delete(at: offsets)
        rounds.remove(atOffsets: offsets)
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }
}



//#Preview {
//    HistoryView()
//}
