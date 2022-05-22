//
//  TraceHubLogger.swift
//

import Foundation
import WebKit

public class MagicPixelTraceHub: NSObject {
    
    // 24 hours lifetime
    
    private let logInterceptor:LogInterceptor = LogInterceptor()
    private let webRequestInterceptor:WebRequestInterceptor = WebRequestInterceptor()
    private static var instance: MagicPixelTraceHub?
    
    /// The shared singleton object
    @objc public static func shared() -> MagicPixelTraceHub {
        guard let val = instance else {
            let sharedInstance = MagicPixelTraceHub()
            instance = sharedInstance
            return sharedInstance
        }
        return val
    }
    
    private override init() {}
    
    /// The initial method to be inovked before using other methods.
    /// - Parameter config: Base64 Encoded String provided in the Magic Pixel Portal
    /// - Parameter callback: The callback handler is called when configuration setup is complete. This handler provide the confguration status.
    @objc public func configure(config: String, callback: (THResponse) -> Void) {
        
        self.decodeEncodedString(base64EncodedString: config)
        callback(THResponse.success)
    }
    
    func setSettings(setting: Bool) {
        let key = Constants.UserDefaultKeys.LogSetting.rawValue
        let defaults = UserDefaults.standard
        defaults.set(setting, forKey: key)
        
        Config.shared.setListenerMode(val: setting ? THListenerMode.on : THListenerMode.off)
    }
    
    func decodeEncodedString(base64EncodedString: String) -> Void {
        
        //convert the data to a dictionary and handle errors.
        guard let decodedData = base64EncodedString.base64Decoded() else {
            fatalError("Cannot decode Base64 Encoded string")
        }
        
        guard let config = decodedData.toJSON() else {
            fatalError("Base64 decoded string is not in JSON format")
        }
        
        let webSocketEndpointKey = Constants.ConfigKeys.WebSocketEndpointKey.rawValue
        let channelNameKey = Constants.ConfigKeys.ChannelNameKey.rawValue
        let authKey = Constants.ConfigKeys.AuthKey.rawValue
        let expiryKey = Constants.ConfigKeys.ExpiryKey.rawValue
        
        guard let webSocketEndpoint = config[webSocketEndpointKey] as? String else {
            fatalError("\(webSocketEndpointKey) not found in decoded Json")
        }
        
        guard let channelName = config[channelNameKey] as? String else {
            fatalError("\(channelNameKey) not found in decoded Json")
        }
        
        guard let apiKey = config[authKey] as? String else {
            fatalError("\(authKey) not found in decoded Json")
        }
        
        guard let expiry = config[expiryKey] as? Double else {
            fatalError("\(expiryKey) not found in decoded Json")
        }
        
        Config.shared.setWebsocketEndpoint(val: webSocketEndpoint)
        Config.shared.setChannelName(val: channelName)
        Config.shared.setApiKey(val: apiKey)
        Config.shared.setExpiry(val: expiry)
        
        let key = Constants.UserDefaultKeys.SessionConfig.rawValue
        let defaults = UserDefaults.standard
        defaults.set(base64EncodedString, forKey: key)
    }
    
    /// This method will provide logger status.
    func getStoredConfig() -> String! {
        
        let key = Constants.UserDefaultKeys.SessionConfig.rawValue
        let defaults = UserDefaults.standard
        guard let encodedString = defaults.object(forKey: key) else {
            return nil
        }
        
        return encodedString as? String
    }
}

// Public helper functions

extension MagicPixelTraceHub {
    
    /// This method will start the logger process.
    /// - Parameter callback: The callback handler is called when logger process is complete. This handler provide the operation status.
    @objc public func startLogCollector(callback: (THResponse) -> ()) {
        
        // Check if Config was provided
        if Config.shared.doesConfigExists() {
            callback(THResponse.configNotProvided)
            return
        }
        
        if Config.shared.hasSessionExpired() {
            callback(THResponse.sessionExpired)
            return
        }
                
        // Start timer to periodically validate Code
        TimerService.startValidationTimer()
        
        // Call API to get config
        self.setSettings(setting: true)
        logInterceptor.initialize()
        WebSocketService.shared.connect()
        let response = logInterceptor.startListening()
        callback(response)
    }
    
    /// This method will stop the logger process.
    /// - Parameter callback: The callback handler is called when logger process is stopped. This handler provide the operation status.
    @objc public func stopLogCollector(_ callback: (THResponse) -> ()) {
        
        // Check if Config was provided
        if Config.shared.doesConfigExists() {
            callback(THResponse.configNotProvided)
            return
        }
        
        // Start timer to periodically validate Code
        TimerService.stopValidationTimer()
        
        setSettings(setting: false)
        logInterceptor.stopListening()
        WebSocketService.shared.disconnect()
        callback(THResponse.success)
    }
    
    /// This method will log the statement with the tag.
    @objc public func log(message: String, tag: String) -> THResponse {
        
        // Check if Config was provided
        if Config.shared.doesConfigExists() {
            return THResponse.configNotProvided
        }
        
        if Config.shared.hasSessionExpired() {
            return THResponse.sessionExpired
        }
        
        // Connect to Websocket Endpoint.
        // If already connected, the connect method will ignore the request
        WebSocketService.shared.connect()
        WebSocketService.shared.send(data: message, messageType: MessageType.log, tag: tag)
        
        return THResponse.success
    }
    
    /// This method will provide logger status.
    @objc public func loggerStatus() -> Bool {
        
        let key = Constants.UserDefaultKeys.LogSetting.rawValue
        let defaults = UserDefaults.standard
        if let _ = defaults.object(forKey: key) {
            let val = defaults.bool(forKey: key)
            return val
        }
        
        defaults.set(false, forKey: key)
        return false
    }
    
    /// This method will provide the expiration time of the logger process in epoch format.
    @objc public func expirationTime() -> Double {
        // Check if Config was provided
        if Config.shared.doesConfigExists() {
            return -1
        }
        
        return Config.shared.expiry
    }
    
    /// This method will provide the expiration time of the logger process in epoch format.
    @objc public func channelName() -> String {
        return Config.shared.channelName
    }
    
    /// This method will provide the expiration time of the logger process in epoch format.
    @objc public func setDebugMode(mode: Bool) {
        Config.shared.setDebugMode(mode)
    }
    
    /// This method will start listener for web view requests
    /// - Parameter callback: The callback handler provide the WebView listener status.
    @objc public func startListenerFor(_ webView: WKWebView, tag: String?, callback: (THWebViewStartListenerResponse) -> ()) {
        
        // Check if Config was provided
        if Config.shared.doesConfigExists() {
            callback(THWebViewStartListenerResponse.configNotProvided)
            return
        }
        
        // Check if session has expired
        if Config.shared.hasSessionExpired() {
            callback(THWebViewStartListenerResponse.sessionExpired)
            return
        }
        
        Config.shared.setListenerMode(val: THListenerMode.on)
        WebSocketService.shared.connect()
        
        let webRequestInterceptorResponse = webRequestInterceptor.addWebView(webView, tag: tag)
        callback(webRequestInterceptorResponse)
    }
    
    /// This method will stop listener for web view requests
    /// - Parameter callback: The callback handler provide the WebView listener status.
    @objc public func stopListenerFor(_ webView: WKWebView, callback: (THWebViewStopListenerResponse) -> ()) {
        
        // Check if Config was provided
        if Config.shared.doesConfigExists() {
            callback(THWebViewStopListenerResponse.configNotProvided)
            return
        }
        
        // Check if session has expired
        if Config.shared.hasSessionExpired() {
            callback(THWebViewStopListenerResponse.sessionExpired)
            return
        }
        
        let webRequestInterceptorResponse = webRequestInterceptor.removeWebView(webView)
        callback(webRequestInterceptorResponse)
    }
}
