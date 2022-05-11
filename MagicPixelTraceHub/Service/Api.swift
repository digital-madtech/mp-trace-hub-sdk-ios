//
//  Api.swift
//

import UIKit

class Api {

    static var shared: Api = {
        let instance = Api()
        return instance
    }()
    
    private init() {
        
    }
    
    func sendLogs(msg: String) {
        
//        let apiKey = Config.shared.API_KEY
        let vendorId = Config.shared.vendorId
        let projectId = Config.shared.projectId
        let clientCode = Config.shared.clientCode
        let debugId = Config.shared.debugId
        
        let urlStr: String = "https://\(clientCode).magicpixel.io/\(vendorId)/project/\(projectId)/logs/iOS/\(debugId)"
        
        let session = URLSession.shared
        guard let url = URL(string: urlStr) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Authorization", forHTTPHeaderField: apiKey)
        
        let json = [
            "msg": msg
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            if let _ = response as? HTTPURLResponse {
//                print("HTTPURLResponse: \(urlResponse.statusCode)")
            }
            if let data = data, let _ = String(data: data, encoding: .utf8) {
//                print("Api Response: \(dataString)")
            }
        }
        
        task.resume()
    }
    
    func getConfig(callback: (THResponse) -> ()) {
        
//        let apiKey = Config.shared.API_KEY
//        let clientCode = Config.shared.CLIENT_CODE
//
//        let _: String = "https://\(clientCode).magicpixel.io/config/iOS"
//
//        let session = URLSession.shared
//        guard let url = URL(string: "https://beee6fd0-dafb-4250-80ca-6cf61323c0e6.mock.pstmn.io/logs") else {
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Authorization", forHTTPHeaderField: apiKey)
//
//        let task = session.dataTask(with: url, completionHandler: { data, response, error in
//            // Do something...
//        })
//
//        task.resume()
        callback(.success)
    }
    
    func validateOtp(_ otp: String, callback: (THResponse) -> ()) {
        
//        let apiKey = Config.shared.API_KEY
        let vendorId = Config.shared.vendorId
        let projectId = Config.shared.projectId
        let clientCode = Config.shared.clientCode
        let debugId = Config.shared.debugId
        
        let urlStr: String = "https://\(clientCode).magicpixel.io/\(vendorId)/project/\(projectId)/logs/iOS/\(debugId)"
        
        let session = URLSession.shared
        guard let url = URL(string: urlStr) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Authorization", forHTTPHeaderField: apiKey)
        
        let json = [
            "otp": otp
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            if let _ = response as? HTTPURLResponse {
//                print("HTTPURLResponse: \(urlResponse.statusCode)")
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                print("Api Response: \(dataString)")
                let resObj = String.toJSON(dataString)
            }
        }
        
        task.resume()
    }
}
