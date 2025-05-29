//
//  PhoneSessionManager.swift
//  GolfScoreApp
//
//  Created by 本村壮志 on 2025/05/20.
//

import Foundation
import WatchConnectivity

class PhoneSessionManager: NSObject, ObservableObject, WCSessionDelegate {
  static let shared = PhoneSessionManager()
  
  @Published var receivedStrokes: [Int] = []

  override private init() {
    super.init()
    if WCSession.isSupported() {
      WCSession.default.delegate = self
      WCSession.default.activate()
    }
  }

  // 必須メソッド1: 状態変更ハンドラ
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
      print("WCSession activated: \(activationState.rawValue)")
  }

  // 必須メソッド2: iPhone専用（watchOSでは不要）
  func sessionDidBecomeInactive(_ session: WCSession) {
    print("WCSession did become inactive")
  }

  func sessionDidDeactivate(_ session: WCSession) {
    print("WCSession did deactivate")
    WCSession.default.activate() // 通常ここで再アクティブ化
  }

  // 任意：メッセージ受信処理
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    DispatchQueue.main.async {
      if let scoreArray = message["score"] as? [Int] {
        self.receivedStrokes = scoreArray
      }
    }
  }

  // iPhone → Watch に送信
  func sendRoundToWatch(roundName: String, holeCount: Int) {
    if WCSession.default.isReachable {
      let data: [String: Any] = [
          "roundName": roundName,
          "holeCount": holeCount
      ]
      WCSession.default.sendMessage(data, replyHandler: nil, errorHandler: { error in
          print("送信失敗: \(error.localizedDescription)")
      })
    }
  }
}


