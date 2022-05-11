//
//  Logger.swift
//  MagicPixelTraceHub
//
//  Created by Digital Madtech LLC on 4/4/20.
//  Copyright © 2020 DigitalMadTech. All rights reserved.
//

import UIKit

class Logger {
    
    static let prefix = "###THUBDEBUGMODE###"
    static func log(_ message: Any) {
        if Config.shared.DEBUG_MODE {
            print("\(prefix)\(Config.shared.debugId): \(message)")
        }
    }
}
