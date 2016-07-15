//
//  TNKAdvancedViewController.swift
//  TNKRefreshControl
//
//  Created by David Beck on 1/15/15.
//  Copyright (c) 2015 David Beck. All rights reserved.
//

import UIKit

import TNKRefreshControl


let reuseIdentifier = "NumberCell"


class TNKAdvancedCell: UICollectionViewCell {
    @IBOutlet weak var numberLabel: UILabel!
}


class TNKAdvancedViewController: UICollectionViewController {
    private let objectSource = TNKDateSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.alwaysBounceVertical = true
        
        self.collectionView?.tnk_refreshControl = TNKRefreshControl()
        self.collectionView?.tnk_refreshControl.tintColor = UIColor.whiteColor()
        self.collectionView?.tnk_refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.objectSource.objects.count <= 0 {
            self.refresh(nil)
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func refresh(sender: AnyObject?) {
        self.collectionView?.tnk_refreshControl.beginRefreshing()
        
        self.objectSource.loadNewObjects { (newObjects) in
            self.collectionView?.tnk_refreshControl.endRefreshing()
            
            var indexPaths: [NSIndexPath] = []
			for _ in newObjects {
				indexPaths.append(NSIndexPath(forItem: 0, inSection: 0))
            }
			
            self.collectionView?.insertItemsAtIndexPaths(indexPaths)
//            self.collectionView?.reloadData()
        }
    }
    
    @IBAction func clear(sender: AnyObject) {
        self.objectSource.objects = []
        self.collectionView?.reloadData()
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.objectSource.objects.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TNKAdvancedCell
        
        cell.numberLabel.text = self.objectSource.objects[indexPath.item].description
        
        return cell
    }
}
