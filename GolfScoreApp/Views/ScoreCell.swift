//
//  ScoreCell.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/27.
//

import SwiftUI

struct ScoreCell: View {
    let score: Int
    let putt: Int
    let par: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColor)

          if score > 0 {
            Text("\(score)")
              .font(.system(size: 25, weight: .bold))
                .foregroundColor(.white)
          } else {
            Text(" ")
              .font(.system(size: 25, weight: .bold))
                .foregroundColor(.white)
          }
            

            GeometryReader { geo in
              if putt > 0 {
                Text("\(putt)")
                  .font(.system(size: 13, weight: .regular))
                  .foregroundColor(.white)
                  .position(x: geo.size.width - 10, y: geo.size.height - 17)
              }
            }
        }
        .frame(width: 44, height: 43)
    }

    var backgroundColor: Color {
      if score == 0 && putt == 0 {
        return .clear
      }
      
        if score < par {
            return .green
        } else if score == par {
            return .blue
        } else {
            return .black
        }
    }
}



//#Preview {
//    VStack(spacing: 10) {
//        ScoreCell(score: 0, putt: 0, par: 4)
//        ScoreCell(score: 3, putt: 2, par: 4) // under par → 緑
//        ScoreCell(score: 4, putt: 2, par: 4) // par → 青
//        ScoreCell(score: 6, putt: 3, par: 4) // over par → 黒
//    }
//    .padding()
//    .previewLayout(.sizeThatFits)
//}
