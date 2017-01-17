//
//  SearchFeedAnyImagesCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/16.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import AsyncDisplayKit

final class SearchFeedAnyImagesCell: SearchFeedBasicCell {
    
    override class func heightOfFeed(_ feed: DiscoverFeed) -> CGFloat {
        
        let height = super.heightOfFeed(feed) + Config.SearchFeedNormalImagesCell.imageSize.height + 10
        return ceil(height)
    }
    
    var tapMediaAction: tapMediaActionTypealias = nil
    
    lazy var mediaCollectionNode: ASCollectionNode = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        layout.itemSize = Config.SearchFeedNormalImagesCell.imageSize
        
        let node = ASCollectionNode(collectionViewLayout: layout)
        
        node.view.scrollsToTop = false
        node.view.contentInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 10)
        node.view.showsHorizontalScrollIndicator = false
        node.view.backgroundColor = UIColor.clear
        
        node.dataSource = self
        node.delegate = self
        
//        let backgroundView = TouchClosuresView(frame: node.view.bounds)
//        backgroundView.touchesBeganAction = { [weak self] in
//            if let strongSelf = self {
//                strongSelf.touchesBeganAction?(strongSelf)
//            }
//        }
//        backgroundView.touchesEndedAction = { [weak self] in
//            if let strongSelf = self {
//                if strongSelf.isEditing {
//                    return
//                }
//                strongSelf.touchesEndedAction?(strongSelf)
//            }
//        }
//        backgroundView.touchesCancelledAction = { [weak self] in
//            if let strongSelf = self {
//                strongSelf.touchesCancelledAction?(strongSelf)
//            }
//        }
//        node.view.backgroundView = backgroundView
        
        return node
    }()
    
    var imageAttachments: [ImageAttachment] = [] {
        didSet {
            mediaCollectionNode.reloadData()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(mediaCollectionNode.view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageAttachments = []
    }
    
    override func configureCell(with feed: DiscoverFeed, layout: SearchFeedCellLayout, keyword: String?) {
        
        super.configureCell(with: feed, layout: layout, keyword: keyword)
        
        if let attachment = feed.attachment {
            if case let .images(imageAttachments) = attachment {
                self.imageAttachments = imageAttachments
            }
        }
        
        let anyImagesLayout = layout.anyImagesLayout!
        mediaCollectionNode.frame = anyImagesLayout.mediaCollectionViewFrame
    }
}

extension SearchFeedAnyImagesCell: ASCollectionDelegate, ASCollectionDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageAttachments.count
    }
    
    func collectionView(_ collectionView: ASCollectionView, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        
        let node = FeedImageCellNode()
        
        if let attachment = imageAttachments[safe: indexPath.item] {
            node.configureWithAttachment(attachment, imageSize: Config.FeedNormalImagesCell.imageSize)
        }
        return node
        
    }
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        
        let size = Config.FeedNormalImagesCell.imageSize
        return ASSizeRange(min: size, max: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        guard let firstAttachment = imageAttachments.first, !firstAttachment.isTemporary else {
//            return
//        }
        
        guard let node = mediaCollectionNode.view.nodeForItem(at: indexPath) as? FeedImageCellNode else {
            return
        }
        
        let transitionView = node.view
        let image = node.imageNode.image
        let imageAttachments = self.imageAttachments
        let index = indexPath.item
        tapMediaAction?(transitionView, image, imageAttachments, index)

    }
    
    
}
