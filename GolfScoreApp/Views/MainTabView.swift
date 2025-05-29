//
//  MainTabView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/28.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var savedRound: Round? = RoundPersistence.load()
    @State private var selectedHoleIndex: Int? = nil
    @State private var isPresentingInput = false
    @State private var isPresentingSetupSheet = false
  @State private var previewRound: Round? = nil
  @State private var isPresentingPreview = false


    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(round: $savedRound, showSetupSheet: $isPresentingSetupSheet)
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
                .tag(0)

            if let savedRound = savedRound {
              ScoreListView(round: Binding(
                      get: { savedRound },
                      set: { self.savedRound = $0 }
                  ))
                  .tabItem {
                      Label("スコア表", systemImage: "list.bullet.rectangle")
                  }
                  .tag(1)
            } else {
              VStack(spacing: 12) {
                  Text("入力中のスコアデータがありません")
                      .font(.headline)
                      .foregroundColor(.gray)
                  Text("ホーム画面でラウンドを開始するか、\n履歴画面から編集するラウンドを選択してください。")
                      .font(.subheadline)
                      .foregroundColor(.secondary)
                      .multilineTextAlignment(.center)
                      .padding(.horizontal)
              }
              .tabItem {
                  Label("スコア表", systemImage: "list.bullet.rectangle")
              }
              .tag(1)

            }

            HistoryView(savedRound: $savedRound)
                .tabItem {
                    Label("履歴", systemImage: "clock.arrow.circlepath")
                }
                .tag(2)
        }
        .sheet(isPresented: $isPresentingInput) {
            if let _ = savedRound,
               let index = selectedHoleIndex {
                ScoreInputView(
                    round: Binding(
                        get: { savedRound! },
                        set: { savedRound = $0 }
                    ),
                    startHole: index + 1
                )
            } else {
                Text("ラウンドが読み込まれていません")
            }
        }
        .sheet(isPresented: $isPresentingSetupSheet) {
            RoundSetupView(savedRound: $savedRound, selectedTab: $selectedTab)
        }
        .sheet(item: $previewRound) { round in
            ScoreListView(round: .constant(round), isEditable: false)
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToHole)) { notification in
            if let hole = notification.userInfo?["hole"] as? Int {
                selectedHoleIndex = hole
                selectedTab = 1

                // バインディングが反映されるのを1フレーム待ってからシートを開く
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPresentingInput = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToScoreTab)) { _ in
            selectedTab = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .previewRound)) { notification in
            if let round = notification.userInfo?["round"] as? Round {
                previewRound = round
                isPresentingPreview = true
            }
        }
        .onAppear {
            savedRound = RoundPersistence.load()
        }
    }
}


#Preview {
    MainTabView()
}
