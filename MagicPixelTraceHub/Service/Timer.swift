//
//  Timer.swift
//  MagicPixelTraceHub
//
//  Created by Srivatsav Uppu on 5/9/22.
//  Copyright © 2022 AG. All rights reserved.
//

import Foundation

class TimerService {
    
    private(set) static var timer: Timer?
    static func startValidationTimer() {
        stopValidationTimer()
        
        TimerService.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            // Call validate OTP api
        }
    }
    
    static func stopValidationTimer() {
        if (timer != nil) {
            timer?.invalidate()
        }
    }
}
