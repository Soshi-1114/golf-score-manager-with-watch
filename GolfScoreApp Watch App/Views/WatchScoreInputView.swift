//
//  WatchScoreInputView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/20.
//

import SwiftUI

import SwiftUI

struct WatchScoreInputView: View {
  @ObservedObject private var session = WatchWCSessionManager.shared
  @State private var currentHole = 1
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
          if session.strokes[currentHole - 1] > 0 {
            session.strokes[currentHole - 1] -= 1
          }
        }
        Text("打数: \(session.strokes[currentHole - 1])")
          .frame(minWidth: 60)
        Button("+") {
          session.strokes[currentHole - 1] += 1
        }
      }

      HStack {
        Button("-") {
          if session.putts[currentHole - 1] > 0 {
            session.putts[currentHole - 1] -= 1
          }
        }
        Text("パット: \(session.putts[currentHole - 1])")
          .frame(minWidth: 60)
        Button("+") {
          session.putts[currentHole - 1] += 1
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
    .onChange(of: session.strokes) { _, _ in
      sendDebounced()
    }
    .onChange(of: session.putts) { _, _ in
      sendDebounced()
    }
  }

  func sendDebounced() {
    debounceTask?.cancel()
    debounceTask = DispatchWorkItem {
      WatchWCSessionManager.shared.sendScoreToPhone(
        strokes: session.strokes,
        putts: session.putts
      )
    }

    if let task = debounceTask {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: task)
    }
  }
}



#Preview {
    WatchScoreInputView()
}
