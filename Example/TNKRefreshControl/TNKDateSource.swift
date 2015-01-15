//
//  TNKDateSource.swift
//  TNKRefreshControl
//
//  Created by David Beck on 1/13/15.
//  Copyright (c) 2015 David Beck. All rights reserved.
//

import UIKit


private let TimeInterval = 5.0

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
    var objects: [AnyObject] = []
    private var highestNumber = 0
    
    func loadNewObjects(completed: (newObjects: [AnyObject]) -> ()) {
        NSTimer.scheduledTimerWithTimeInterval(3.0, repeats: false) { (timer) in
            var newObjects: [AnyObject] = []
            for i in 0..<5 {
                self.highestNumber++
                newObjects.insert(self.highestNumber, atIndex: 0)
            }
            
            self.objects = newObjects + self.objects
            completed(newObjects: newObjects)
        }
    }
}
