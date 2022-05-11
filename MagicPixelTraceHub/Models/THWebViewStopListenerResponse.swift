//
//  THWebViewStopListenerResponse.swift
//  MagicPixelTraceHub
//
//  Created by Digital Madtech LLC on 4/23/20.
//  Copyright © 2020 Digital Madtech LLC. All rights reserved.
//

import UIKit

/// Response types that specify the status for WebView listener requests.
@objc public enum THWebViewStopListenerResponse: integer_t {
    
    /// Failed operation
    case failed = -1

    /// Config was not provided. Config must be provided before using any functionality.
    case configNotProvided = 10
    
    /// Started Listening
    case stopped = 20
    
    /// Unauthorized access
    case unauthorized = 30
    
    /// Requests for the WebView are already not being interecpted
    case alreadyNotListening = 40
}
