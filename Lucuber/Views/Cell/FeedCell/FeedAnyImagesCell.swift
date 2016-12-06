//
//  FeedAnyImagesCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

private let FeedMediaCellIdentifier = "FeedMediaCell"

class FeedAnyImagesCell: FeedBaseCell  {
    
    var tapMediaAction: tapMediaActionTypealias
    
    override class func heightOfFeed(feed: DiscoverFeed) -> CGFloat {
        
        let height = super.heightOfFeed(feed: feed) + Config.FeedAnyImagesCell.imageSize.height + 15
        
        return ceil(height)
    }
    
    override func configureWithFeed(_ feed: DiscoverFeed, layout: FeedCellLayout, needshowCategory: Bool) {
        super.configureWithFeed(feed, layout: layout, needshowCategory: needshowCategory)
        
        
        switch feed.attachment {
            
        case .images(let imageAttachments):
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
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.scrollsToTop = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: FeedMediaCellIdentifier, bundle: nil), forCellWithReuseIdentifier: FeedMediaCellIdentifier)
        collectionView.backgroundColor = UIColor.clear
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
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageAttachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedMediaCellIdentifier, for: indexPath) as! FeedMediaCell
        
//        let attachment = imageAttachments[indexPath.row]
//        
//        cell.imageView.cube_setImageAtFeedCellWithAttachment(attachment: attachment, withSize: cell.imageView.size)
//        
//        cell.deleteImageView.isHidden = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? FeedMediaCell else {
            return
        }
        
        let attachment = imageAttachments[indexPath.row]
        cell.imageView.showActivityIndicatorWhenLoading = true
        cell.imageView.cube_setImageAtFeedCellWithAttachment(attachment: attachment, withSize: cell.imageView.size)
        cell.deleteImageView.isHidden = true

        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return Config.FeedAnyImagesCell.imageSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? FeedMediaCell {
            
            let transitionView = cell.imageView
            let image = cell.imageView.image
            let imageAttachments = self.imageAttachments
            let index = indexPath.item
            tapMediaAction?(transitionView!, image, imageAttachments, index)
        }
        
    }
    
    
}



