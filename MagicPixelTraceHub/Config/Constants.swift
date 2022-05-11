//
//  Constants.swift
//  TraceHubLogger
//
//  Copyright © 2020 DigitalMadTech. All rights reserved.
//

import UIKit

class Constants: NSObject {
    enum UserDefaultKeys: String {
        case LogSetting = "THUB_LOG_SETTING"
        case DebugId = "THUB_DEBUG_ID"
        case ExpiryTime = "THUB_EXP_EPCH_TS"
    }
    
    enum PropertyListFile: String {
        case FileName = "MagicPixel-services"
        case ClientCodeKey = "CLIENT_CODE"
        case VendorIdKey = "VENDOR_ID"
        case ProjectIdKey = "PROJECT_ID"
        case ApiKeyKey = "API_KEY"
    }
}
