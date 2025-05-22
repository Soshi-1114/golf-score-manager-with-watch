//
//  WatchSessionManager.swift
//  GolfScoreApp Watch App
//
//  Created by 本村壮志 on 2025/05/20.
//

import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchSessionManager()

    @Published var roundName: String = ""
    @Published var holeCount: Int = 18

    override private init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // ✅ 必須: watchOS でのセッションの有効化結果
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Watch WCSession activated: \(activationState.rawValue)")
    }

    // ✅ 任意: iPhone → Watch のデータ受信（ラウンド情報）
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let name = message["roundName"] as? String {
                self.roundName = name
            }
            if let count = message["holeCount"] as? Int {
                self.holeCount = count
            }
        }
    }

    // ✅ Watch → iPhone にスコア送信
    func sendScoreToPhone(scoreArray: [Int]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["score": scoreArray], replyHandler: nil, errorHandler: { error in
                print("送信失敗: \(error.localizedDescription)")
            })
        }
    }
}


