//
//  Models.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/19.
//

import Foundation

struct PlayerScore: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var holeScores: [HoleScore]

    static func == (lhs: PlayerScore, rhs: PlayerScore) -> Bool {
        lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.holeScores == rhs.holeScores
    }
}

struct HoleScore: Codable, Equatable, Hashable {
    var holeNumber: Int
    var strokes: Int
    var putts: Int
}

struct Round: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var date: Date
    var name: String
    var players: [PlayerScore]
    var parList: [Int] = Array(repeating: 4, count: 18)
}

extension Round {
    static var mock: Round {
        let mockPlayers = [
            PlayerScore(
                id: UUID(),
                name: "山田",
                holeScores: (1 ... 18).map { HoleScore(holeNumber: $0, strokes: 0, putts: 0) }
            ),
            PlayerScore(
                id: UUID(),
                name: "佐藤",
                holeScores: (1 ... 18).map { HoleScore(holeNumber: $0, strokes: 0, putts: 0) }
            ),
        ]
        return Round(
            id: UUID(),
            date: Date(),
            name: "テストラウンド",
            players: mockPlayers
        )
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}

extension Notification.Name {
    static let navigateToHole = Notification.Name("navigateToHole")
    static let navigateToScoreTab = Notification.Name("navigateToScoreTab")
    static let requestEditRound = Notification.Name("requestEditRound")
    static let previewRound = Notification.Name("previewRound")
}
