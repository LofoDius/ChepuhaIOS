//
//  WsClient.swift
//  Chepuha
//
//  Created by LofoD on 31.05.2021.
//

import Foundation
import SwiftStomp

struct WsClient : SwiftStompDelegate {
    func onSocketEvent(eventName: String, description: String) {
        
    }
    
    public static var shared: WsClient = WsClient()
    
    
    
    
    func onConnect(swiftStomp : SwiftStomp, connectType : StompConnectType) {
        stompClinet.subscribe(to: "/topic/spam")
    }
        
    func onDisconnect(swiftStomp : SwiftStomp, disconnectType : StompDisconnectType) {
        
    }

    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers : [String : String]) {
        print(message.unsafelyUnwrapped)
    }

    func onReceipt(swiftStomp : SwiftStomp, receiptId : String) {
        
    }

    func onError(swiftStomp : SwiftStomp, briefDescription : String, fullDescription : String?, receiptId : String?, type : StompErrorType) {
        
    }

    func subToConnectedPlayers(gameCode: String) {
        stompClinet.subscribe(to: "/topic/connectedPlayers/\(gameCode)")
    }
    
}
