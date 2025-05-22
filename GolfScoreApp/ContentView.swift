//
//  ContentView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/18.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      NavigationStack {
        VStack(spacing: 24) {
            NavigationLink("新しいラウンドを開始") {
                RoundSetupView()
            }
            .font(.title2)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)

            NavigationLink("履歴を見る") {
                HistoryView()
            }
            .font(.title3)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .navigationTitle("ゴルフスコア")
    }
  }
}

#Preview {
    ContentView()
}
