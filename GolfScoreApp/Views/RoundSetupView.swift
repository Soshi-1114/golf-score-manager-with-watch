//
//  SwiftUIView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import SwiftUI

struct RoundSetupView: View {
    @Binding var savedRound: Round?
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss

    @State private var roundName = ""
    @State private var playerNames: [String] = []
    @State private var savedCompanions: [String] = []
    @State private var showAddActionSheet = false
    @State private var showNewCompanionAlert = false
    @State private var showCompanionPicker = false
    @State private var newCompanionName = ""
    @State private var selectedCompanions: Set<String> = []

    let userName = "Me"

    var body: some View {
        Form {
            Section(header: Text("ラウンド名/ゴルフ場名")) {
                TextField("例: コンペ @富士コース", text: $roundName)
            }

            Section(header: Text("同伴者")) {
                Text(userName)
                    .foregroundColor(.gray)

              ForEach(playerNames, id: \.self) { name in
                  HStack {
                      Text(name)
                      Spacer()
                      Button(action: {
                          if let index = playerNames.firstIndex(of: name) {
                              playerNames.remove(at: index)
                          }
                      }) {
                          Image(systemName: "minus.circle")
                              .foregroundColor(.red)
                      }
                      .buttonStyle(BorderlessButtonStyle()) // リストでの動作安定化
                  }
                  .padding(.vertical, 4)
              }


                if playerNames.count < 3 {
                    Button("同伴者を追加する") {
                        showAddActionSheet = true
                    }
                }
            }

            Section {
                Button("ラウンド開始") {
                    startRound()
                    dismiss()
                    selectedTab = 1
                }
                .disabled(roundName.isEmpty || playerNames.isEmpty)
            }
        }
        .navigationTitle("ラウンドの設定")
        .onAppear {
            savedCompanions = CompanionStorage.shared.load()
        }
        .actionSheet(isPresented: $showAddActionSheet) {
            ActionSheet(title: Text("同伴者を追加"), buttons: [
                .default(Text("新しく入力する")) {
                    showNewCompanionAlert = true
                },
                .default(Text("同伴者一覧から選択")) {
                    showCompanionPicker = true
                },
                .cancel()
            ])
        }
        .alert("同伴者を追加", isPresented: $showNewCompanionAlert, actions: {
            TextField("名前", text: $newCompanionName)
            Button("保存") {
                if !newCompanionName.isEmpty {
                    addCompanion(newCompanionName)
                    newCompanionName = ""
                }
            }
            Button("キャンセル", role: .cancel) {}
        })
        .sheet(isPresented: $showCompanionPicker) {
            NavigationView {
                List {
                    if savedCompanions.isEmpty {
                        Text("登録されている同伴者がいません")
                    } else {
                        ForEach(savedCompanions, id: \.self) { name in
                            MultipleSelectionRow(title: name, isSelected: selectedCompanions.contains(name)) {
                                if selectedCompanions.contains(name) {
                                    selectedCompanions.remove(name)
                                } else if selectedCompanions.count < 3 - playerNames.count {
                                    selectedCompanions.insert(name)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("同伴者を選択")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("OK") {
                            playerNames.append(contentsOf: selectedCompanions)
                            selectedCompanions.removeAll()
                            showCompanionPicker = false
                        }
                    }
                }
            }
        }
    }

    private func addCompanion(_ name: String) {
        guard playerNames.count < 3 else { return }
        playerNames.append(name)
        if !savedCompanions.contains(name) {
            savedCompanions.append(name)
            CompanionStorage.shared.save(names: savedCompanions)
        }
    }

    private func startRound() {
        let players = [
            PlayerScore(
                id: UUID(),
                name: userName,
                holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: 0, putts: 0) }
            )
        ] + playerNames.map { name in
            PlayerScore(
                id: UUID(),
                name: name,
                holeScores: (1...18).map { HoleScore(holeNumber: $0, strokes: 0, putts: 0) }
            )
        }

        savedRound = Round(
            id: UUID(),
            date: Date(),
            name: roundName,
            players: players
        )

        CompanionStorage.shared.save(names: savedCompanions)

        PhoneSessionManager.shared.sendRoundToWatch(
            roundName: roundName,
            holeCount: players.first?.holeScores.count ?? 18
        )
    }
}

struct MultipleSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var dummyRound: Round? = nil
        @State private var dummyTab: Int = 0

        var body: some View {
            NavigationView {
                RoundSetupView(savedRound: $dummyRound, selectedTab: $dummyTab)
            }
        }
    }

    return PreviewWrapper()
}
