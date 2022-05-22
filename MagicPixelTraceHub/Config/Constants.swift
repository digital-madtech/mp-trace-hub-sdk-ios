//
//  Constants.swift
//  TraceHubLogger
//
//  Copyright © 2020 DigitalMadTech. All rights reserved.
//

import UIKit

class Constants: NSObject {
    enum UserDefaultKeys: String {
        case SessionConfig = "SESSION_CONFIG"
        case LogSetting = "THUB_LOG_SETTING"
    }
    
    enum ConfigKeys: String {
        case WebSocketEndpointKey = "wss"
        case ChannelNameKey = "cName"
        case AuthKey = "auth"
        case ExpiryKey = "exp"
    }
}
