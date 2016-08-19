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
        
        self.collectionView?.tnkRefreshControl = TNKRefreshControl()
        self.collectionView?.tnkRefreshControl?.tintColor = UIColor.white
        self.collectionView?.tnkRefreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.objectSource.objects.count <= 0 {
            self.refresh(nil)
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func refresh(_ sender: AnyObject?) {
        self.collectionView?.tnkRefreshControl?.beginRefreshing()
        
        self.objectSource.loadNewObjects { (newObjects) in
            self.collectionView?.tnkRefreshControl?.endRefreshing()
            
            var indexPaths: [IndexPath] = []
			for _ in newObjects {
				indexPaths.append(IndexPath(item: 0, section: 0))
            }
			
            self.collectionView?.insertItems(at: indexPaths)
//            self.collectionView?.reloadData()
        }
    }
    
    @IBAction func clear(sender: AnyObject) {
        self.objectSource.objects = []
        self.collectionView?.reloadData()
    }
    

    // MARK: UICollectionViewDataSource

	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.objectSource.objects.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TNKAdvancedCell
		
		let item = self.objectSource.objects[indexPath.item]
        cell.numberLabel.text = "\(item)"
        
        return cell
    }
}
