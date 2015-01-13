//
//  TNKDateSource.swift
//  TNKRefreshControl
//
//  Created by David Beck on 1/13/15.
//  Copyright (c) 2015 David Beck. All rights reserved.
//

import UIKit


extension NSTimer {
    class func scheduledTimerWithTimeInterval(interval: NSTimeInterval, repeats: Bool, handler: NSTimer! -> Void) -> NSTimer {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let repeatInterval = repeats ? interval : 0
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, repeatInterval, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        return timer
    }
}

class TNKDateSource: NSObject {
    var dates: [NSDate] = []
    
    func refresh(completed: (dates: [NSDate]) -> ()) {
        NSTimer.scheduledTimerWithTimeInterval(3.0, repeats: false) { (timer) in
            var newDates: [NSDate] = []
            for i in 0..<20 {
                newDates.append(NSDate(timeIntervalSinceNow: NSTimeInterval(i) * 30.0))
            }
            
            self.dates = newDates
            completed(dates: newDates)
        }
    }
    
    func loadNewDates(completed: (dates: [NSDate]) -> ()) {
        if let sinceDate = self.dates.first {
            let toDate = NSDate()
            
            NSTimer.scheduledTimerWithTimeInterval(5.0, repeats: false) { (timer) in
                var newDates: [NSDate] = []
                var i: NSTimeInterval = sinceDate.timeIntervalSince1970 + 30.0
                while i < toDate.timeIntervalSince1970 {
                    newDates.append(NSDate(timeIntervalSince1970: i))
                    
                    i += 30.0
                }
                
                self.dates += newDates
                completed(dates: newDates)
            }
        } else {
            self.refresh(completed)
        }
    }
}
