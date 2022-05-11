//
//  String.swift
//  MagicPixelTraceHub
//
//  Created by Srivatsav Uppu on 5/9/22.
//  Copyright © 2022 AG. All rights reserved.
//

import Foundation

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

