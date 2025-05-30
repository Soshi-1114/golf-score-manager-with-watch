//
//  WatchWCSessionManager.swift
//  GolfScoreApp Watch App
//
//  Created by 本村壮志 on 2025/05/29.
//

import Foundation

import WatchConnectivity

class WatchWCSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchWCSessionManager()

    @Published var strokes: [Int] = Array(repeating: 0, count: 18)
    @Published var putts: [Int] = Array(repeating: 0, count: 18)
    @Published var roundName: String = ""
    @Published var holeCount: Int = 18
    @Published var isLinked: Bool = false

    override private init() {
        super.init()
        activateSession()
    }

    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("Watch側WCSessionをactivateしました")
        }
    }

    func sendScoreToPhone(strokes: [Int], putts: [Int]) {
        guard WCSession.default.isReachable else {
            print("iPhoneが通信可能な状態ではありません")
            return
        }

        let message: [String: Any] = [
            "strokes": strokes,
            "putts": putts,
        ]

        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("送信失敗: \(error.localizedDescription)")
        }
    }

    func session(_: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let roundData = message["roundData"] as? Data {
                do {
                    let round = try JSONDecoder().decode(Round.self, from: roundData)
                    self.roundName = round.name
                    self.holeCount = round.parList.count
                    self.isLinked = true
                    print("Watch Linked")
                    print("Watchでラウンド情報を受信: \(round.name)")
                } catch {
                    print("Watch側: ラウンドデータのデコード失敗: \(error)")
                }
            }

            // strokes/putts 同期もここで受け取る
            if let strokes = message["strokes"] as? [Int] {
                self.strokes = strokes
            }
            if let putts = message["putts"] as? [Int] {
                self.putts = putts
            }
        }
    }

    func session(_: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            // 連携状態の判定（トグル OFF の場合）
            guard let isLinked = applicationContext["isWatchSyncEnabled"] as? Bool, isLinked else {
                self.isLinked = false
                self.roundName = ""
                self.strokes = Array(repeating: 0, count: 18)
                self.putts = Array(repeating: 0, count: 18)
                return
            }

            // isLinked = true の場合でも、ラウンド未開始であれば未連携扱いにする
            if let roundName = applicationContext["roundName"] as? String, roundName.isEmpty {
                self.isLinked = false
                self.roundName = ""
                self.strokes = Array(repeating: 0, count: 18)
                self.putts = Array(repeating: 0, count: 18)
                return
            }

            // 正常な連携＆ラウンド中
            self.isLinked = true
            self.roundName = applicationContext["roundName"] as? String ?? "未設定"
            self.strokes = applicationContext["strokes"] as? [Int] ?? Array(repeating: 0, count: 18)
            self.putts = applicationContext["putts"] as? [Int] ?? Array(repeating: 0, count: 18)
        }
    }

    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {}
}
