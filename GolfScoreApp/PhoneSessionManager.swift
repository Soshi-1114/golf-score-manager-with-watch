//
//  PhoneSessionManager.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/20.
//

import Foundation
import WatchConnectivity

/// iPhone 側の WatchConnectivity 管理クラス
class PhoneSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WCSessionManager()

    override private init() {
        super.init()
        activateSession()
    }

    func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    // iPhone -> Watch にデータを送る
    func sendRoundToWatch(round: Round) {
        if WCSession.default.isReachable {
            do {
                let data = try JSONEncoder().encode(round)
                let dictionary: [String: Any] = ["roundData": data]
                WCSession.default.sendMessage(dictionary, replyHandler: nil, errorHandler: nil)
            } catch {
                print("送信エラー: \(error.localizedDescription)")
            }
        }
    }

    // Watch -> iPhone からの受信
    func session(_: WCSession, didReceiveMessage message: [String: Any]) {
        if let data = message["scoreData"] as? Data {
            do {
                let updatedScore = try JSONDecoder().decode(PlayerScore.self, from: data)
                DispatchQueue.main.async {
                    // AppModel などに統合
                    AppModel.shared.updateScoreFromWatch(score: updatedScore)
                }
            } catch {
                print("デコードエラー: \(error)")
            }
        }
    }

    func sessionDidBecomeInactive(_: WCSession) {}
    func sessionDidDeactivate(_: WCSession) {}
    func sessionWatchStateDidChange(_: WCSession) {}
    func session(_: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {}
}
