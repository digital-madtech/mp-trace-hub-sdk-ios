//
//  String.swift
//  MagicPixelTraceHub
//
//  Created by Srivatsav Uppu on 5/9/22.
//  Copyright © 2022 AG. All rights reserved.
//

import Foundation

extension String {
    func toJSON() -> [String: Any]? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
    }
    
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func isEmpty() -> Bool {
        return self == ""
    }
}
