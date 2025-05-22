//
//  File.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import Foundation

struct PlayerScore: Identifiable, Codable, Equatable, Hashable  {
    var id: UUID
    var name: String
    var holeScores: [HoleScore]
  
  static func == (lhs: PlayerScore, rhs: PlayerScore) -> Bool {
          lhs.id == rhs.id &&
          lhs.name == rhs.name &&
          lhs.holeScores == rhs.holeScores
      }
}

struct HoleScore: Codable, Equatable, Hashable  {
  var holeNumber: Int
  var strokes: Int
  var putts: Int
}

struct Round: Identifiable, Codable, Equatable, Hashable  {
  var id: UUID
  var date: Date
  var name: String
  var players: [PlayerScore]
}

