//
//  Config.swift
//  TraceHubLogger
//
//  Copyright © 2020 DigitalMadTech. All rights reserved.
//

class Config: NSObject {
    
    let DEBUG_MODE = true
    
    private(set) var vendorId: String = ""
    private(set) var projectId: String = ""
    private(set) var clientCode: String = ""
    private(set) var clientPrefix: String = ""
    private(set) var debugId: String = ""
    private(set) var apiKey: String = ""
    private(set) var listenerMode: THListenerMode = THListenerMode.off
    
    static var shared: Config = {
        let instance = Config()
        return instance
    }()
    
    private override init() {
        
    }
    
    func setVendorId(val: String) {
        vendorId = val
    }
    
    func setProjectId(val: String) {
        projectId = val
    }
    
    func setClientCode(val: String) {
        clientCode = val
    }
    
    func setClientPrefix(val: String) {
        clientPrefix = val
    }
    
    func setApiKey(val: String) {
        apiKey = val
    }
    
    func setDebugId(val: String) {
        debugId = val
    }
    
    func setListenerMode(val: THListenerMode) {
        listenerMode = val
    }
}
