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
    
    var tapMediaAction: tapMediaActionTypealias
    
    override class func heightOfFeed(feed: Feed) -> CGFloat {
        
        let height = super.heightOfFeed(feed) + CubeConfig.FeedAnyImagesCell.imageSize.height + 15
        
        return ceil(height)
    }
    
    override func configureWithFeed(feed: Feed, layout: FeedCellLayout, needshowCategory: Bool) {
        super.configureWithFeed(feed, layout: layout, needshowCategory: needshowCategory)
        
        
        switch feed.attachment {
            
        case .Image(let imageAttachments):
            self.imageAttachments = imageAttachments
            
        default:
            break
        }
        
        if let anyImagesLayout = layout.anyImagesLayout {
          mediaCollectionView.frame = anyImagesLayout.mediaCollectionViewFrame
        }
        
    }
    
  
    
    var imageAttachments: [ImageAttachment] = [] {
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
        return imageAttachments.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FeedMediaCellIdentifier, forIndexPath: indexPath) as! FeedMediaCell
        
        let attachment = imageAttachments[indexPath.row]
        
        cell.imageView.cube_setImageAtFeedCellWithAttachment(attachment, withSize: cell.imageView.size)
        
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
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FeedMediaCell {
            
            let transitionView = cell.imageView
            let image = cell.imageView.image
            let imageAttachments = self.imageAttachments
            let index = indexPath.row
            tapMediaAction?(transitionView: transitionView, image: image, imageAttachments: imageAttachments, index: index)
        }
        
    }
    
    
}






















