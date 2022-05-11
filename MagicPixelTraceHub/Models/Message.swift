//
//  Message.swift
//  MagicPixelTraceHub
//
//  Created by Srivatsav Uppu on 4/30/20.
//  Copyright © 2020 AG. All rights reserved.
//

import UIKit

@objc class Message: NSObject {
    var data: String
    var messageType: String
    var tag: String
    
    init(data: String, messageType: String, tag: String = "") {
        self.data = data
        self.messageType = messageType
        self.tag = tag
    }
}
