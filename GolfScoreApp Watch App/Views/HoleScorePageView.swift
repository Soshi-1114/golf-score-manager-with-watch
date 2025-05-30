//
//  HoleScorePageView.swift
//  GolfScoreApp Watch App
//
//  Created by 本村壮志 on 2025/05/31.
//

import SwiftUI

struct HoleScorePageView: View {
  @ObservedObject private var session = WatchWCSessionManager.shared
  var holeIndex: Int

  var body: some View {
    VStack(spacing: 6) {
      HStack {
        Text("Hole \(holeIndex + 1)")
          .font(.title3)
          .bold()
        
        Text(" /  Total \(session.strokes[holeIndex])")
          .font(.title3)
          .bold()
      }

      // 上段：マイナスボタン
      HStack(spacing: 10) {
        Button(action: {
          if session.strokes[holeIndex] > 0 {
            session.strokes[holeIndex] -= 1
          }
        }) {
          Text("-")
            .font(.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 100, height: 40)
        .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
        .buttonStyle(PlainButtonStyle())

        Button(action: {
            if session.putts[holeIndex] > 0 {
              session.putts[holeIndex] -= 1
            }
          }) {
            Text("-")
              .font(.title)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
          .frame(width: 60, height: 40)
          .background(RoundedRectangle(cornerRadius: 6).fill(Color.blue))
          .buttonStyle(PlainButtonStyle())

      }

      // 中央スコア表示
      HStack(spacing: 24) {
        Text("\(session.strokes[holeIndex])")
          .font(.system(size: 50, weight: .bold))
          .frame(width: 80, height: 40)

        Text("\(session.putts[holeIndex])")
          .font(.system(size: 30, weight: .medium))
          .frame(width: 40, height: 40)
          
      }

      // 下段：プラスボタン
      HStack(spacing: 10) {
        Button(action: {
          session.strokes[holeIndex] += 1
        }) {
          Text("+")
            .font(.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 100, height: 40)
        .background(RoundedRectangle(cornerRadius: 6).fill(Color.red))
        .buttonStyle(PlainButtonStyle())
        
        Button(action: {
          session.putts[holeIndex] += 1
        }) {
          Text("+")
            .font(.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 60, height: 40)
        .background(RoundedRectangle(cornerRadius: 6).fill(Color.red))
        .buttonStyle(PlainButtonStyle())
      }
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}


#Preview {
    let mockSession = WatchWCSessionManager.shared
    mockSession.strokes = Array(repeating: 5, count: 18)
    mockSession.putts = Array(repeating: 2, count: 18)

    return HoleScorePageView(holeIndex: 0)
}

