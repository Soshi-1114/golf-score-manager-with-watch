//
//  WatchScoreInputView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/20.
//

import SwiftUI

import SwiftUI

struct WatchScoreInputView: View {
  @ObservedObject private var session = WatchSessionManager.shared
  @State private var currentHole = 1
  @State private var strokes = Array(repeating: 0, count: 18)
  @State private var putts = Array(repeating: 0, count: 18)
  @State private var debounceTask: DispatchWorkItem?

    var body: some View {
        VStack(spacing: 8) {
          Text(session.roundName)
              .font(.headline)
              .multilineTextAlignment(.center)

          Text("Hole \(currentHole) / \(session.holeCount)")
              .font(.subheadline)

            HStack {
                Button("-") {
                    if strokes[currentHole - 1] > 0 {
                        strokes[currentHole - 1] -= 1
                    }
                }
                Text("打数: \(strokes[currentHole - 1])")
                    .frame(minWidth: 60)
                Button("+") {
                    strokes[currentHole - 1] += 1
                }
            }

            HStack {
                Button("-") {
                    if putts[currentHole - 1] > 0 {
                        putts[currentHole - 1] -= 1
                    }
                }
                Text("パット: \(putts[currentHole - 1])")
                    .frame(minWidth: 60)
                Button("+") {
                    putts[currentHole - 1] += 1
                }
            }

            HStack {
                Button("◀") {
                    if currentHole > 1 { currentHole -= 1 }
                }
                .frame(maxWidth: .infinity)

                Button("▶") {
                    if currentHole < 18 { currentHole += 1 }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 4)

            Spacer()
        }
        .padding()
        .onChange(of: strokes) {
          debounceTask?.cancel()
            debounceTask = DispatchWorkItem {
                WatchSessionManager.shared.sendScoreToPhone(scoreArray: strokes)
            }

            if let task = debounceTask {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: task)
            }
        }
    }
}


#Preview {
    WatchScoreInputView()
}
