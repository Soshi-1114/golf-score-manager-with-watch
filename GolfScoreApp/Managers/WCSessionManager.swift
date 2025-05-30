//
//  WCSessionManager.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/29.
//

// WCSessionManager.swift
import Foundation
import WatchConnectivity

class WCSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WCSessionManager()
    
    override private init() {
        super.init()
        activateSession()
    }
    
    func activateSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
  func sendRoundToWatch(round: Round) {
    guard AppModel.shared.isWatchSyncEnabled else {
        print("⏹ Apple Watch連携がOFFのため、送信をスキップ")
        return
    }

    if WCSession.default.isReachable {
        do {
            let data = try JSONEncoder().encode(round)
            WCSession.default.sendMessage(["roundData": data], replyHandler: nil, errorHandler: nil)
        } catch {
            print("送信エラー: \(error.localizedDescription)")
        }
    }
  }
    
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
          print("iPhone側メッセージ受信: \(message)")

          if let strokes = message["strokes"] as? [Int],
             let putts = message["putts"] as? [Int] {
              DispatchQueue.main.async {
                  AppModel.shared.updateScoresFromWatch(strokes: strokes, putts: putts)
              }
          }
      }
  
  func sendScoresToWatch(player: PlayerScore) {
    guard AppModel.shared.isWatchSyncEnabled else {
        print("⏹ Apple Watch連携がOFFのため、スコア送信をスキップ")
        return
    }

    let strokes = player.holeScores.map { $0.strokes }
    let putts = player.holeScores.map { $0.putts }

    let message: [String: Any] = [
        "strokes": strokes,
        "putts": putts
    ]

    if WCSession.default.isReachable {
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
  }
  
  func sendUnlinkSignalToWatch() {
    let context: [String: Any] = [
        "isWatchSyncEnabled": false,
        "roundName": ""  // Watch側で未開始状態と判定しやすくする
    ]
    try? WCSession.default.updateApplicationContext(context)
    
  }

  func sendRoundClearedToWatch() {
      guard WCSession.default.isPaired,
            WCSession.default.isWatchAppInstalled else {
          print("Watch is not pairing")
          return
      }

      let context: [String: Any] = [
          "isWatchSyncEnabled": true,
          "roundName": "",
          "strokes": Array(repeating: 0, count: 18),
          "putts": Array(repeating: 0, count: 18)
      ]

      do {
          try WCSession.default.updateApplicationContext(context)
          print("Send end round to Watch")
      } catch {
          print("fale to send end round to Watch: \(error.localizedDescription)")
      }
  }
  
  func sendScoreToWatch(strokes: [Int], putts: [Int]) {
      let context: [String: Any] = [
          "isWatchSyncEnabled": true,
          "roundName": AppModel.shared.currentRound?.name ?? "",
          "strokes": strokes,
          "putts": putts
      ]
      
      do {
          try WCSession.default.updateApplicationContext(context)
          print("📤 Watchにスコアデータ送信")
      } catch {
          print("⚠️ スコア送信エラー: \(error)")
      }
  }




    // 必須デリゲートメソッド（空でOK）
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
  
  func sessionDidBecomeActive(_ session: WCSession) {
      print("Activate WCSession for iPhone")
  }

    func sessionDidDeactivate(_ session: WCSession) {}
}
