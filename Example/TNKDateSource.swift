//
//  TNKDateSource.swift
//  TNKRefreshControl
//
//  Created by David Beck on 1/13/15.
//  Copyright (c) 2015 David Beck. All rights reserved.
//

import UIKit


class TNKDateSource: NSObject {
	var objects: [Any] = []
	private var highestNumber = 0
	private var completion: ((_ newObjects: [Any]) -> ())?
	
	func loadNewObjects(completion: @escaping (_ newObjects: [Any]) -> ()) {
		self.completion = completion
		Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(objectsLoaded), userInfo: nil, repeats: false)
	}
	
	@objc private func objectsLoaded() {
		var newObjects: [Any] = []
		for _ in 0..<5 {
			self.highestNumber += 1
			newObjects.insert(self.highestNumber, at: 0)
		}
		
		self.objects = newObjects + self.objects
		completion?(newObjects)
	}
}
