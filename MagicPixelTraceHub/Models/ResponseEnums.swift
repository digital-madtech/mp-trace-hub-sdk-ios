//
//  ResponseEnums.swift
//  TraceHubLogger
// 
//  Copyright © 2020 DigitalMadTech. All rights reserved.
//

import UIKit

/// Response types that specify the status for execution operations.
@objc public enum THResponse: integer_t {
    
    /// Successful operation
    case success = 10
    
    /// Unauthorized access
    case unauthorized = 20
    
    /// Invalid data provided
    case invalidData = 30
    
    /// Log Collector process already in running state
    case alreadyStarted = 40
    
    /// Config was not provided. Config must be provided before using any functionality.
    case configNotProvided = 50
    
    /// Failed operation
    case failed = -1
}
