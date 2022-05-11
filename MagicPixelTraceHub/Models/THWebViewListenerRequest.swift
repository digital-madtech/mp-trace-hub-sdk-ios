//
//  THWebViewListenerRequest.swift
//  MagicPixelTraceHub
//
//  Created by Digital Madtech LLC on 4/22/20.
//  Copyright © 2020 Digital Madtech LLC. All rights reserved.
//

import UIKit
import WebKit

@objc class WebViewListenerRequest: NSObject {
    
    var tag: String?
    var webView: WKWebView
    var id: NSInteger
    
    internal init(id: NSInteger, webView: WKWebView, tag: String?) {
        self.id = id
        self.tag = tag
        self.webView = webView
    }
}
