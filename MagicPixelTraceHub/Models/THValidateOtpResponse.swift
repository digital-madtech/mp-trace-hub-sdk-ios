//
//  Message.swift
//  MagicPixelTraceHub
//
//  Created by Srivatsav Uppu on 4/30/20.
//  Copyright © 2020 AG. All rights reserved.
//

import UIKit

@objc class THValidateOtpResponse: NSObject {
    var expired: Bool
    var collectorUrl: String
    
    init(expired: Bool, collectorUrl: String) {
        self.expired = expired
        self.collectorUrl = collectorUrl
    }
}
