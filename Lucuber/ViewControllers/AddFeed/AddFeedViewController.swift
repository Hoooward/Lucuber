//
//  AddFeedViewController.swift
//  Lucuber
//
//  Created by Howard on 7/23/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class AddFeedViewController: UIViewController {

    // MARK: - Properties
    enum Attachment {
        case Default
        case Formula
    }
    
    var attachment: Attachment = .Default
    
    
    private var isNeverInputMessage = true
    private var isDirty = false {
        willSet {
            
        }
    }
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var mediaCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private let FeedMediaAddCellIdentifier = "FeedMediaAddCell"
    private let FeedMediaCellIdentifier = "FeedMediaCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaCollectionView.backgroundColor = UIColor.clearColor()
        
        mediaCollectionView.contentInset.left = 15
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.showsHorizontalScrollIndicator = false

    }

}

extension AddFeedViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
    }
}








