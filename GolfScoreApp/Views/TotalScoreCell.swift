//
//  TotalScoreCell.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/27.
//

import SwiftUI

struct TotalScoreCell: View {
  let score: Int
  let putt: Int

  var body: some View {
      ZStack {
          Text("\(score)")
            .font(.system(size: 25, weight: .bold))
              .foregroundColor(.black)

          GeometryReader { geo in
              Text("\(putt)")
              .font(.system(size: 13, weight: .regular))
                  .foregroundColor(.black)
                  .position(x: geo.size.width - 10, y: geo.size.height - 17) // 右下に配置
          }
      }
      .frame(width: 80, height: 44)
  }
}

#Preview {
  VStack(spacing: 10) {
    TotalScoreCell(score: 46, putt: 20)
  }
  .padding()
  .previewLayout(.sizeThatFits)
}
