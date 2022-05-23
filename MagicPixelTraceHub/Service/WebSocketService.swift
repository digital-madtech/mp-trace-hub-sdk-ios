//
//  WebSocketService.swift
//  LogInterceptorApp
//
//  Created by Digital Madtech LLC on 4/3/20.
//  Copyright © 2020 DigitalMadTech. All rights reserved.
//

import UIKit

private class WebSocketServiceConstants {
    static let MAX_RECONNECT_ATTEMPTS = 10
    static let CLIENT_DISCONNECT: String = "CLIENT_DISCONNECT"
    static let FORBIDDEN_ACCESS: String = "FORBIDDEN_ACCESS"
}

class WebSocketService {
    
    private var webSocketManager: SocketManager!
    private var webSocketClient: SocketIOClient!
    private var reconnectAttempts = 0
    private var messageQueue: [Message] = []
    
    static var shared: WebSocketService = {
        let instance = WebSocketService()
        return instance
    }()
    
    private init() { }
    
    func connect() {
        if self.isConnected() {
            return
        }
        
        webSocketConnect()
    }
    
    private func isConnected() -> Bool {
        guard let webSocketClient = self.webSocketClient else {
            Logger.log("WebSocketService :: connect :: Not connected")
            return false
        }
        
        Logger.log("WebSocketService :: Connection Status = \(webSocketClient.status)")
        
        if webSocketClient.status != .connected {
            Logger.log("WebSocketService :: connect :: Not connected")
            return false
        }
        
        Logger.log("WebSocketService :: connect :: already connected")
        
        return true
    }
    
    private func reconnect() {
        
        Logger.log("reconnect attempt")
        
        if reconnectAttempts > WebSocketServiceConstants.MAX_RECONNECT_ATTEMPTS {
            return
        }
        
        reconnectAttempts += 1
        
        webSocketConnect()
    }
    
    func disconnect() {
        
        if !isConnected() {
            
            if let webSocketClient = self.webSocketClient {
                webSocketClient.disconnect()
            }
            
            if let webSocketManager = self.webSocketManager {
                webSocketManager.disconnect()
            }
            
            Logger.log("WebSocketService :: disconnect :: Already disconnected")
            reconnectAttempts = 0
            self.webSocketManager = nil
            self.webSocketClient = nil
            return
        }
        
        Logger.log("WebSocketService :: disconnect :: Disconnect attempt")
        
        guard let webSocketClient = webSocketClient else {
            return
        }
        
        webSocketClient.disconnect()
//        webSocket.disconnect(closeCode: WebSocketServiceConstants.DISCONNECT_CLOSE_CODE)
        
        self.webSocketManager = nil
        self.webSocketClient = nil
    }
    
    // To be used wisely, no guard checks on this function
    private func webSocketConnect() {
        
        Logger.log("WebSocketService :: webSocketConnect :: Connection attempt")
        
        self.webSocketManager = nil
        self.webSocketClient = nil
        
        guard let url = URL(string: Config.shared.websocketEndpoint) else {
            Logger.log("WebSocketService :: webSocketConnect :: Invalid URL")
            return
        }
        
        self.webSocketManager = SocketManager(socketURL: url, config: [.log(false), .compress])
        self.webSocketClient = self.webSocketManager.defaultSocket
        
        self.listenToWebSocketEvents()
        self.webSocketClient.connect(withPayload: ["token": Config.shared.apiKey, "cName": Config.shared.channelName])
    }
    
    private func listenToWebSocketEvents() {
        guard let webSocketClient = self.webSocketClient else {
            return
        }
        
        webSocketClient.on(clientEvent: .connect) {data, ack in
            self.reconnectAttempts = 0
            Logger.log("WebSocketService :: WebSocketDelegate :: Websocket is connected")
            Logger.log(data)
            self.flushQueue()
        }
        
        webSocketClient.on(clientEvent: .disconnect) {data, ack in
            Logger.log(data)
            Logger.log("WebSocketService :: WebSocketDelegate :: Websocket is disconnected")
        }
        
        webSocketClient.on(clientEvent: .reconnect) {data, ack in
            Logger.log(data)
            Logger.log("WebSocketService :: WebSocketDelegate :: Websocket attempting to reconnect")
        }
        
        webSocketClient.on(clientEvent: .statusChange) {data, ack in
            Logger.log(data)
            Logger.log("WebSocketService :: WebSocketDelegate :: Websocket connection status changed to \(data)")
        }
        
        webSocketClient.on(clientEvent: .error) {data, ack in
            Logger.log(data)
            Logger.log("WebSocketService :: WebSocketDelegate :: Websocket connection error")
        }
    }
    
    func send(data: String, messageType: String, tag: String = "") {
        
        // Ignore logs which are printed by the SDK
        if data.contains(Logger.prefix) {
            return
        }

        // If Websocket is not connected, then add the message to the queue.
        // When Websocket is connected, the flushQueue method will publish all messages
        if !self.isConnected() {
            messageQueue.append(Message(data: data, messageType: messageType, tag: tag))
            return
        }

        // If data is empty, then ignore.
        if data.isEmpty {
            Logger.log("WebSocketService :: send :: Data is empty")
            return
        }

        // Create JSON object to publish
//        let data: [String: Any] = ["message": "publish", "data": ["vid": vendorId, "pid": projectId, "did": debugId, "tag": tag, "typ": messageType, "data": data]]
        
        let data: [String: Any] = ["data": [["tag": tag, "log": data]]]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                Logger.log(jsonString)
                
                guard let webSocketClient = webSocketClient else {
                    return
                }
                
                webSocketClient.emitWithAck("traceHubLog", jsonString).timingOut(after: 1) {data in
                    Logger.log(data)
                }
            }

        } catch {
            Logger.log("WebSocketService :: send :: Error while sending data")
        }
    }
    
    private func flushQueue() {
        if !self.isConnected() {
            return
        }
        
        Logger.log("WebSocketService :: flushQueue :: Flushing queue...")
        
        for message in messageQueue {
            send(data: message.data, messageType: message.messageType, tag: message.tag)
            if let index = messageQueue.firstIndex(where: {$0 === message}) {
                messageQueue.remove(at: index)
            }
        }
    }
}
