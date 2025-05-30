//
//  WatchWCSessionManager.swift
//  GolfScoreApp Watch App
//
//  Created by 本村壮志 on 2025/05/29.
//

import Foundation

import WatchConnectivity

class WatchWCSessionManager: NSObject, ObservableObject, WCSessionDelegate {
  
  // Watch側の状態保持用 Published プロパティ
  @Published var strokes: [Int] = Array(repeating: 0, count: 18)
  @Published var putts: [Int] = Array(repeating: 0, count: 18)

  
  static let shared = WatchWCSessionManager()

      @Published var roundName: String = "未設定"
      @Published var holeCount: Int = 18

      private override init() {
          super.init()
          activateSession()
      }


  func sendScoreToPhone(strokes: [Int], putts: [Int]) {
      guard WCSession.default.isReachable else {
          print("iPhoneが通信可能な状態ではありません")
          return
      }

      let message: [String: Any] = [
          "strokes": strokes,
          "putts": putts
      ]

      WCSession.default.sendMessage(message, replyHandler: nil) { error in
          print("送信失敗: \(error.localizedDescription)")
      }
  }


  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
      DispatchQueue.main.async {
          if let roundData = message["roundData"] as? Data {
              do {
                  let round = try JSONDecoder().decode(Round.self, from: roundData)
                  self.roundName = round.name
                  self.holeCount = round.parList.count
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
  
  func activateSession() {
      if WCSession.isSupported() {
          let session = WCSession.default
          session.delegate = self
          session.activate()
          print("Watch側WCSessionをactivateしました")
      }
  }



      func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

}
