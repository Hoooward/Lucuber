//
//  FeedAnyImagesCell.swift
//  Lucuber
//
//  Created by Howard on 7/27/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

private let FeedMediaCellIdentifier = "FeedMediaCell"

class FeedAnyImagesCell: FeedDefaultCell  {
    
    
    override class func heightOfFeed(feed: Feed) -> CGFloat {
        
        let height = super.heightOfFeed(feed) + CubeConfig.FeedAnyImagesCell.imageSize.height + 15
        
        return ceil(height)
    }
    
    override func configureWithFeed(feed: Feed, layout: FeedCellLayout, needshowCategory: Bool) {
        super.configureWithFeed(feed, layout: layout, needshowCategory: needshowCategory)
        
        
        switch feed.attachment {
            
        case .AnyImages(let urls):
            imageUrls = urls
            
        default:
            break
        }
        
        if let anyImagesLayout = layout.anyImagesLayout {
          mediaCollectionView.frame = anyImagesLayout.mediaCollectionViewFrame
        }
        
    }
    
    var imageUrls = [String]() {
        didSet {
            mediaCollectionView.reloadData()
        }
    }
    
    lazy var mediaCollectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.scrollDirection = .Horizontal
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.scrollsToTop = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(UINib(nibName: FeedMediaCellIdentifier, bundle: nil), forCellWithReuseIdentifier: FeedMediaCellIdentifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        return collectionView
        
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(mediaCollectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension FeedAnyImagesCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FeedMediaCellIdentifier, forIndexPath: indexPath) as! FeedMediaCell
        
        if let url = NSURL(string: imageUrls[indexPath.row]) {
            cell.imageView.setImageWithURL(url)
        }
        
        cell.deleteImageView.hidden = true
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CubeConfig.FeedAnyImagesCell.imageSize
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
}






















