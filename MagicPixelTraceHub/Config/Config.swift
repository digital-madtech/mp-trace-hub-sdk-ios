//
//  Config.swift
//  TraceHubLogger
//
//  Copyright © 2020 DigitalMadTech. All rights reserved.
//

class Config: NSObject {
    
    private(set) var debugMode: Bool = false
    private(set) var websocketEndpoint: String = ""
    private(set) var channelName: String = ""
    private(set) var apiKey: String = ""
    private(set) var expiry: Double = 0
    private(set) var listenerMode: THListenerMode = THListenerMode.off
    
    static var shared: Config = {
        let instance = Config()
        return instance
    }()
    
    private override init() {
        
    }
    
    func setDebugMode(_ val: Bool) {
        debugMode = val
    }
    
    func setWebsocketEndpoint(val: String) {
        websocketEndpoint = val
    }
    
    func setChannelName(val: String) {
        channelName = val
    }
    
    func setApiKey(val: String) {
        apiKey = val
    }
    
    func setExpiry(val: Double) {
        expiry = val
    }
    
    func setListenerMode(val: THListenerMode) {
        listenerMode = val
    }
    
    func doesConfigExists() -> Bool {
        return self.apiKey.isEmpty()
    }
    
    func hasSessionExpired() -> Bool {
        if doesConfigExists() {
            return true
        }
        
        let currEpochTime = Date().timeIntervalSince1970 * 1000
        return currEpochTime > self.expiry
    }
}
