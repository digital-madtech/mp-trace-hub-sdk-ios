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
//    @objc public private(set) static var shared: MagicPixelTraceHub = {
//        let instance = MagicPixelTraceHub()
//        return instance
//    }()
    
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
    /// - Parameter callback: The callback handler is called when configuration setup is complete. This handler provide the confguration status.
    @objc public func configure(callback: (THResponse) -> Void) {
        
        let plistProperties = getPlistProperties()
        let vendorId = plistProperties.vendorId;
        let projectId = plistProperties.projectId
        let clientCode = plistProperties.clientCode
        let apiKey = plistProperties.apiKey
        
        Config.shared.setVendorId(val: vendorId)
        Config.shared.setProjectId(val: projectId)
        Config.shared.setClientCode(val: clientCode)
        Config.shared.setClientPrefix(val: clientCode)
        Config.shared.setApiKey(val: apiKey)
        Config.shared.setDebugId(val: debugId())
        
        // If listener was already set to "ON" before, then go ahead and fetch config from server.
        let setting = loggerStatus()
        if setting {
            // Get expiration time
            let storedTs = getExpirationTime()
            let currentTs = NSDate().timeIntervalSince1970
            if storedTs != 0 && storedTs < currentTs  {
                // Log period expired
                self.setSettings(setting: false)
                callback(THResponse.success)
                return
            }
            
            // Call API to get config
            getConfigFromServer { (response) in
                
                Config.shared.setListenerMode(val: THListenerMode.on)
                
                // Initialize Log Interceptor
                logInterceptor.initialize()
                
                // Start Log Interceptor listener
                let response = logInterceptor.startListening()
                
                WebSocketService.shared.connect()
                
                callback(response)
            }
        } else {
            callback(THResponse.success)
        }
    }
    
    func getConfigFromServer(_ callback: (THResponse) -> ()) {
        Api.shared.getConfig(callback: { (response) in
            callback(response)
        })
    }
    
    func setSettings(setting: Bool) {
        let key = Constants.UserDefaultKeys.LogSetting.rawValue
        let defaults = UserDefaults.standard
        defaults.set(setting, forKey: key)
        
        Config.shared.setListenerMode(val: setting ? THListenerMode.on : THListenerMode.off)
    }
    
    func getPlistProperties() -> (vendorId: String, projectId: String, clientCode: String, apiKey: String) {
        let fileName = Constants.PropertyListFile.FileName.rawValue
        
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
        var plistData: [String: AnyObject] = [:]
        guard let plistPath: String = Bundle.main.path(forResource: fileName, ofType: "plist") else {
            fatalError("Unable to find \(fileName).plist file.")
        }
        
        guard let plistXML = FileManager.default.contents(atPath: plistPath) else {
            fatalError("Unable to find \(fileName).plist file.")
        }
        
        do {//convert the data to a dictionary and handle errors.
            plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! [String:AnyObject]
            
            let vendorIdKey = Constants.PropertyListFile.VendorIdKey.rawValue
            let projectIdKey = Constants.PropertyListFile.ProjectIdKey.rawValue
            let clientCodeKey = Constants.PropertyListFile.ClientCodeKey.rawValue
            let apiKeyKey = Constants.PropertyListFile.ApiKeyKey.rawValue
            
            guard let vendorId = plistData[vendorIdKey] as? String else {
                fatalError("\(vendorIdKey) is manadatory in \(fileName).plist file.")
            }
            
            guard let projectId = plistData[projectIdKey] as? String else {
                fatalError("\(projectIdKey) is manadatory in \(fileName).plist file.")
            }
            
            guard let clientCode = plistData[clientCodeKey] as? String else {
                fatalError("\(clientCodeKey) is manadatory in \(fileName).plist file.")
            }
            
            guard let apiKey = plistData[apiKeyKey] as? String else {
                fatalError("\(apiKeyKey) is manadatory in \(fileName).plist file.")
            }
            
            return (vendorId: vendorId, projectId: projectId, clientCode: clientCode, apiKey: apiKey)
            
        } catch {
            fatalError("Error while reading \(fileName).plist file. Make sure the file is in the correct format.")
        }
    }
    
    func setExpirationTime() {
        let ts = NSDate().timeIntervalSince1970 + 86400 // Adding 1 day
        let key = Constants.UserDefaultKeys.ExpiryTime.rawValue
        let defaults = UserDefaults.standard
        defaults.set(ts, forKey: key)
    }
    
    func getExpirationTime() -> Double {
        // Check if Config was provided
        if Config.shared.vendorId == "" {
            return -1
        }
        
        let key = Constants.UserDefaultKeys.ExpiryTime.rawValue
        let defaults = UserDefaults.standard
        let val = defaults.double(forKey: key)
        return val
    }
}

// Public helper functions

extension MagicPixelTraceHub {
    
    /// This method will start the logger process.
    /// - Parameter callback: The callback handler is called when logger process is complete. This handler provide the operation status.
    @objc public func startLogCollector(_ callback: (THResponse) -> ()) {
        
        // Check if Config was provided
        if Config.shared.vendorId == "" {
            callback(THResponse.configNotProvided)
            return;
        }
        
        setExpirationTime()
        
        if loggerStatus() {
            callback(THResponse.alreadyStarted)
            return
        }
        
        TimerService.startValidationTimer()
        
        // Call API to get config
        getConfigFromServer { (response) in
            self.setSettings(setting: true)
            logInterceptor.initialize()
            WebSocketService.shared.connect()
            let response = logInterceptor.startListening()
            callback(response)
        }
    }
    
    /// This method will stop the logger process.
    /// - Parameter callback: The callback handler is called when logger process is stopped. This handler provide the operation status.
    @objc public func stopLogCollector(_ callback: (THResponse) -> ()) {
        
        // Check if Config was provided
        if Config.shared.vendorId == "" {
            callback(THResponse.configNotProvided)
            return;
        }
        
        setSettings(setting: false)
        logInterceptor.stopListening()
        WebSocketService.shared.disconnect()
        callback(THResponse.success)
    }
    
    /// This method will log the statement with the tag.
    @objc public func log(message: String, tag: String) -> THResponse {
        
        // Check if Config was provided
        if Config.shared.vendorId == "" {
            return THResponse.configNotProvided
        }
        
        // Connect to Websocket, if already connect, the connect method will ignore the request
        WebSocketService.shared.connect()
        WebSocketService.shared.send(data: message, messageType: MessageType.log, tag: tag)
        
        return THResponse.success
    }
    
    /// This method will provide the random Debug ID generated by the SDK. This value will not change for the lifetime of the app on the device.
    @objc public func debugId() -> String {
        // Check if Config was provided
        if Config.shared.vendorId == "" {
            return ""
        }
        
        let key = Constants.UserDefaultKeys.DebugId.rawValue
        let defaults = UserDefaults.standard
        guard let val = defaults.string(forKey: key) else {
            let clientCode = Config.shared.clientCode
            let randomInt = Int.random(in: 100000...999999)
            let id = "\(clientCode)\(randomInt)"
            defaults.set(id, forKey: key)
            return id
        }
        return val
    }
    
    /// This method will provide logger status.
    @objc public func loggerStatus() -> Bool {
        
        // Check if Config was provided
        if Config.shared.vendorId == "" {
            return false
        }
        
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
        if Config.shared.vendorId == "" {
            return -1
        }
        
        let key = Constants.UserDefaultKeys.ExpiryTime.rawValue
        let defaults = UserDefaults.standard
        if let _ = defaults.object(forKey: key) {
            let ts = defaults.double(forKey: key)
            return ts
        }
        
        let ts = Date().timeIntervalSince1970
        defaults.set(ts, forKey: key)
        return ts
    }
    
    /// This method will start listener for web view requests
    /// - Parameter callback: The callback handler provide the WebView listener status.
    @objc public func startListenerFor(_ webView: WKWebView, tag: String?, callback: (THWebViewStartListenerResponse) -> ()) {
        
        Config.shared.setListenerMode(val: THListenerMode.on)
        WebSocketService.shared.connect()
        
        // Check if Config was provided
        if Config.shared.vendorId == "" {
            callback(THWebViewStartListenerResponse.configNotProvided)
            return
        }
        
        let webRequestInterceptorResponse = webRequestInterceptor.addWebView(webView, tag: tag)
        callback(webRequestInterceptorResponse)
    }
    
    /// This method will stop listener for web view requests
    /// - Parameter callback: The callback handler provide the WebView listener status.
    @objc public func stopListenerFor(_ webView: WKWebView, callback: (THWebViewStopListenerResponse) -> ()) {
        
        // Check if Config was provided
        if Config.shared.vendorId == "" {
            callback(THWebViewStopListenerResponse.configNotProvided)
            return
        }
        
        let webRequestInterceptorResponse = webRequestInterceptor.removeWebView(webView)
        callback(webRequestInterceptorResponse)
    }
}
