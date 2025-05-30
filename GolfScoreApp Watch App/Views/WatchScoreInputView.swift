//
//  WatchScoreInputView.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/20.
//

import SwiftUI

struct WatchScoreInputView: View {
  @ObservedObject private var session = WatchWCSessionManager.shared
  @State private var currentHole = 1
  @State private var debounceTask: DispatchWorkItem?

  var body: some View {
    if !session.isLinked {
          VStack(spacing: 8) {
            Spacer()
            Text("ラウンドが開始されていないか\nApple Watch連携がOFFです")
              .multilineTextAlignment(.center)
              .font(.system(size: 16))
              .foregroundColor(.gray)
            Spacer()
          }
          .padding()
        } else {
          TabView {
            ForEach(0..<session.holeCount, id: \.self) { index in
              HoleScorePageView(holeIndex: index)
                .padding(.top, 8)
            }
          }
          .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
          .onChange(of: session.strokes) { _, _ in sendDebounced() }
          .onChange(of: session.putts) { _, _ in sendDebounced() }
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
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }
  }
}



#Preview {
    WatchScoreInputView()
}
