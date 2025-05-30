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
          if WCSession.default.isReachable {
              do {
                  let data = try JSONEncoder().encode(round)
                  let message: [String: Any] = ["roundData": data]
                  WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
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


    // 必須デリゲートメソッド（空でOK）
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
  
  func sessionDidBecomeActive(_ session: WCSession) {
      print("iPhone側でWCSessionがアクティブになりました")
  }

    func sessionDidDeactivate(_ session: WCSession) {}
}
