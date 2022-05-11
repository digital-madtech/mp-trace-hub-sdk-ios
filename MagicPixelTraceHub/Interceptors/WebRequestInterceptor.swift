//
//  WebRequestInterceptor.swift
//  MagicPixelTraceHub
//
//  Created by Digital Madtech LLC on 4/22/20.
//  Copyright © 2020 Digital Madtech LLC. All rights reserved.
//

import UIKit
import WebKit

class WebRequestInterceptor: NSObject {
    
    private var nextRequestId = 0;
    
    private var requests: [WebViewListenerRequest] = []

    override init() {
    }
    
    func addWebView(_ webView: WKWebView, tag: String?) -> THWebViewStartListenerResponse {
        
        for req in requests {
            if req.webView == webView {
                return THWebViewStartListenerResponse.alreadyListening
            }
        }
        
        if let _ = webView.navigationDelegate {
            return THWebViewStartListenerResponse.alreadyDelegateSet
        }
        
        webView.navigationDelegate = self
        
        nextRequestId += 1
        requests.append(WebViewListenerRequest(id: nextRequestId, webView: webView, tag: tag))
        return THWebViewStartListenerResponse.started
    }
    
    func removeWebView(_ webView: WKWebView) -> THWebViewStopListenerResponse {
        
        var i = -1;
        for req in requests {
            i += 1
            if req.webView == webView {
                req.webView.navigationDelegate = nil
                requests.remove(at: i)
                return THWebViewStopListenerResponse.stopped
            }
        }
        
        return THWebViewStopListenerResponse.alreadyNotListening
    }
}

extension WebRequestInterceptor: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
        if navigationAction.navigationType == .linkActivated {
        }
        
        sendWebViewData(webView: webView, request: navigationAction.request, response: nil)
    
        decisionHandler(.allow)
    }
        
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        if let httpResponse = navigationResponse.response as? HTTPURLResponse {
            sendWebViewData(webView: webView, request: nil, response: httpResponse)
        }
        
        decisionHandler(.allow)
    }
    
    private func sendWebViewData(webView: WKWebView, request: URLRequest?, response: HTTPURLResponse?) {
        
        var webViewRequest: WebViewListenerRequest?
        for req in requests {
            if req.webView == webView {
                webViewRequest = req
                break
            }
        }
        
        if let request = request, let webViewRequest = webViewRequest {
            if let url = request.url?.absoluteString {
                
                let webViewTag = webViewRequest.tag ?? ""
                
                var body = ""
                if let httpBody = request.httpBody {
                    body = String(data: httpBody, encoding: .utf8) ?? ""
                }
                
                let data = ["typ": "REQ", "url": url, "headers": request.allHTTPHeaderFields ?? [:], "method": request.httpMethod ?? "", "body": body] as [String : Any]
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        WebSocketService.shared.send(data: jsonString, messageType: MessageType.web, tag: webViewTag)
                    }
                    
                } catch {
                }
            }
        }
        
        if let response = response, let webViewRequest = webViewRequest {
            if let url = response.url?.absoluteString {
                
                let webViewTag = webViewRequest.tag ?? ""
                
//                var body = ""
//                if let httpBody = response.body {
//                    body = String(data: httpBody, encoding: .utf8) ?? ""
//                }
                        
                let data = ["typ": "RSP", "url": url, "headers": response.allHeaderFields, "code": response.statusCode, "mime": response.mimeType ?? ""] as [String : Any]
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        WebSocketService.shared.send(data: jsonString, messageType: MessageType.web, tag: webViewTag)
                    }
                    
                } catch {
                }
            }
        }
    }
}
