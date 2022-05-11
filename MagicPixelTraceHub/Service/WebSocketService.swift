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
    static let WEBSOCKET_ENDPOINT = "wss://thub-pub.stg-mp.magicpixel.io"
    static let DISCONNECT_CLOSE_CODE: UInt16 = 9001
}

class WebSocketService {
    
    private var webSocket: WebSocket!
    private var isConnected: Bool = false
    private var reconnectAttempts = 0
    private var messageQueue: [Message] = []
    
    static var shared: WebSocketService = {
        let instance = WebSocketService()
        return instance
    }()
    
    private init() { }
    
    func connect() {
        if isConnected {
            Logger.log("WebSocketService :: connect :: already connected")
            return
        }
        
        Logger.log("WebSocketService :: connect :: connect attempt")
        
//        if Config.shared.listenerMode == THListenerMode.off {
//            isConnected = false
//            reconnectAttempts = 0
//            self.webSocket = nil
//            return
//        }
        
        webSocketConnect()
    }
    
    private func reconnect() {
        
        Logger.log("reconnect attempt")
        
//        if Config.shared.listenerMode == THListenerMode.off {
//            isConnected = false
//            reconnectAttempts = 0
//            self.webSocket = nil
//            return
//        }
        
        if reconnectAttempts > WebSocketServiceConstants.MAX_RECONNECT_ATTEMPTS {
            return
        }
        
        reconnectAttempts += 1
        
        webSocketConnect()
    }
    
    func disconnect() {
        
        if !isConnected {
            Logger.log("WebSocketService :: disconnect :: Already disconnected")
            reconnectAttempts = 0
            self.webSocket = nil
            return
        }
        
        Logger.log("WebSocketService :: disconnect :: Disconnect attempt")
        
        guard let webSocket = webSocket else {
            return
        }
        
        webSocket.disconnect(closeCode: WebSocketServiceConstants.DISCONNECT_CLOSE_CODE)
        isConnected = false
        self.webSocket = nil
    }
    
    // To be used wisely, no guard checks on this function
    private func webSocketConnect() {
        
        guard let url = URL(string: WebSocketServiceConstants.WEBSOCKET_ENDPOINT) else {
            return
        }
        
        self.webSocket = nil
        
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 10
        urlRequest.addValue(Config.shared.apiKey, forHTTPHeaderField: "x-api-key")
        self.webSocket = WebSocket(request: urlRequest)
        self.webSocket.delegate = self
        self.webSocket.connect()
    }
    
    func send(data: String, messageType: String, tag: String = "") {
        
        // Ignore logs which are printed by the SDK
        if data.contains(Logger.prefix) {
            return
        }
//
//        Logger.log("Sending data")
//
//        if Config.shared.listenerMode == THListenerMode.off {
//            Logger.log("WebSocketService :: Listener mode is off")
//            return
//        }

        // If websocket is not connected, then add the message to the queue.
        // When websocket is connected, the flushQueue method will publish all messages
        if !isConnected {
            messageQueue.append(Message(data: data, messageType: messageType, tag: tag))
            Logger.log("WebSocketService :: send :: Websocket is not connected")
            return
        }

        // If data is empty, then ignore.
        if data.isEmpty {
            Logger.log("WebSocketService :: send :: Data is empty")
            return
        }

        let vendorId = Config.shared.vendorId
        let projectId = Config.shared.projectId
        let debugId = Config.shared.debugId
        
        // Create JSON object to publish
//        let data: [String: Any] = ["message": "publish", "data": ["vid": vendorId, "pid": projectId, "did": debugId, "tag": tag, "typ": messageType, "data": data]]
        
        let data: [String: Any] = ["message": "publish", "data": ["vid": vendorId, "pid": projectId, "did": debugId, "typ": messageType, "data": [["tag": tag, "log": data]]]]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                Logger.log(jsonString)
                
                guard let webSocket = webSocket else {
                    return
                }
                
                webSocket.write(string: jsonString, completion: nil)
            }

        } catch {
        }
    }
    
    private func flushQueue() {
        if !isConnected {
            Logger.log("WebSocketService :: flushQueue :: Websocket is not connected")
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

extension WebSocketService: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let data):
            isConnected = true
            reconnectAttempts = 0
            Logger.log("WebSocketService :: WebSocketDelegate :: websocket is connected")
            Logger.log(data)
            flushQueue()
        case .disconnected(_, let code):
            isConnected = false
            if code != WebSocketServiceConstants.DISCONNECT_CLOSE_CODE {
                reconnect()
            }
            
             Logger.log("WebSocketService :: WebSocketDelegate :: websocket is disconnected with code: \(code)")
            break
        case .text(_):
            break
            // print("Received text: \(string)")
        case .binary(_):
            break
            // print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viablityChanged(_):
            break
        case .reconnectSuggested(_):
            reconnect()
            break
        case .cancelled:
            isConnected = false
            break
        case .error(_):
            // print(error ?? "ws error")
            isConnected = false
            break
        }
    }
}
