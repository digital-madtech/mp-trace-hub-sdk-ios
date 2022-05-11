//
//  THWebViewListenerResponse.swift
//  MagicPixelTraceHub
//
//  Created by Digital Madtech LLC on 4/22/20.
//  Copyright © 2020 Digital Madtech LLC. All rights reserved.
//

import UIKit

/// Response types that specify the status for WebView listener requests.
@objc public enum THWebViewStartListenerResponse: integer_t {
    
    /// Failed operation
    case failed = -1
    
    /// Config was not provided. Config must be provided before using any functionality.
    case configNotProvided = 10
    
    /// Started Listening
    case started = 20
    
    /// Unauthorized access
    case unauthorized = 30
    
    /// Invalid data provided
    case invalidData = 40
    
    /// Requests for the WebView is already being interecpted
    case alreadyListening = 50
    
    /// A delegate was already set for this WebView
    case alreadyDelegateSet = 60
}

