//
//  Config.swift
//  TraceHubLogger
//
//  Copyright © 2020 DigitalMadTech. All rights reserved.
//

class Config: NSObject {
    
    private(set) var debugMode: Bool = false
    
    // REST channel
    private(set) var restEndpoint: String = ""
    private(set) var vendorId: String = ""
    private(set) var appId: String = ""
    private(set) var restApiKey: String = ""
    
    // Websocket channel
    private(set) var wsEndpoint: String = ""
    private(set) var wsChannelName: String = ""
    private(set) var wsApiKey: String = ""
    private(set) var wsExpiry: Double = 0
    
    private(set) var listenerMode: THListenerMode = THListenerMode.off
    
    static var shared: Config = {
        let instance = Config()
        return instance
    }()
    
    private override init() {
        
    }
    
    func setRestEndpoint(val: String) {
        restEndpoint = val
    }
    
    func setVendorId(val: String) {
        vendorId = val
    }
    
    func setAppId(val: String) {
        appId = val
    }
    
    func setRestApiKey(val: String) {
        restApiKey = val
    }
    
    func setDebugMode(_ val: Bool) {
        debugMode = val
    }
    
    func setWsEndpoint(val: String) {
        wsEndpoint = val
    }
    
    func setWsChannelName(val: String) {
        wsChannelName = val
    }
    
    func setWsApiKey(val: String) {
        wsApiKey = val
    }
    
    func setWsExpiry(val: Double) {
        wsExpiry = val
    }
    
    func setListenerMode(val: THListenerMode) {
        listenerMode = val
    }
    
    func doesConfigExists() -> Bool {
        return self.wsApiKey.isEmpty()
    }
    
    func hasSessionExpired() -> Bool {
        if doesConfigExists() {
            return true
        }
        
        let currEpochTime = Date().timeIntervalSince1970 * 1000
        return currEpochTime > self.wsExpiry
    }
}
