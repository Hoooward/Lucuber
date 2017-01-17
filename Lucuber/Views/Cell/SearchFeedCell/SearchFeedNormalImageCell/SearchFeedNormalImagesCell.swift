//
//  SearchFeedNormalImagesCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/16.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import AsyncDisplayKit

final class SearchFeedNormalImagesCell: SearchFeedBasicCell {
    
    override class func heightOfFeed(_ feed: DiscoverFeed) -> CGFloat {
        let height = super.heightOfFeed(feed) + (10 + Config.SearchFeedNormalImagesCell.imageSize.height)
        return ceil(height)
    }
    
    var tapMediaAction: tapMediaActionTypealias = nil
    
    fileprivate func creatImageNode() -> ASImageNode {
        let node = ASImageNode()
        node.frame = CGRect(origin: CGPoint.zero, size: Config.SearchFeedNormalImagesCell.imageSize)
        node.contentMode = UIViewContentMode.scaleAspectFill
        node.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        node.borderWidth = 1
        node.borderColor = UIColor.cubeBorderColor().cgColor
        node.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SearchFeedNormalImagesCell.tap(sender:)))
        node.view.addGestureRecognizer(tap)
        return node
    }
    
    fileprivate lazy var imageNode1: ASImageNode = {
        return self.creatImageNode()
    }()
    
    fileprivate lazy var imageNode2: ASImageNode = {
        return self.creatImageNode()
    }()
    
    fileprivate lazy var imageNode3: ASImageNode = {
        return self.creatImageNode()
    }()
    
    fileprivate lazy var imageNode4: ASImageNode = {
        return self.creatImageNode()
    }()
    
    fileprivate var imageNodes: [ASImageNode] = []
    
    fileprivate var needAllImageNodes: Bool = SearchFeedsViewController.feedNormalImagesCount == 4
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if needAllImageNodes {
            imageNodes = [imageNode1, imageNode2, imageNode3, imageNode4]
        } else {
            imageNodes = [imageNode1, imageNode2, imageNode3]
        }
        
        imageNodes.forEach({
            contentView.addSubview($0.view)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageNodes.forEach({ $0.image = nil })
    }
    
    
    override func configureCell(with feed: DiscoverFeed, layout: SearchFeedCellLayout, keyword: String?) {
        
        super.configureCell(with: feed, layout: layout, keyword: keyword)
        
        
        if let attachment = feed.attachment {
            
            switch attachment {
            case .images(let imageAttachments):
                
                
                for i in 0..<imageNodes.count {
                    
                    if let attachment = imageAttachments[safe: i] {
                        
                        if attachment.isTemporary {
                            imageNodes[i].image = attachment.image
                        } else {
                            imageNodes[i].showActivityIndicatorWhenLoading = true
                            imageNodes[i].cube_setImageAtFeedCellWithAttachment(attachment: attachment, withSize: Config.FeedNormalImagesCell.imageSize)
                        }
                        
                        imageNodes[i].isHidden = false
                    } else {
                        imageNodes[i].isHidden = true
                    }
                    
                }
                
            default:
                break
            }
            
            let normalImagesLayout = layout.normalImagesLayout!
            imageNode1.frame = normalImagesLayout.imageView1Frame
            imageNode2.frame = normalImagesLayout.imageView2Frame
            imageNode3.frame = normalImagesLayout.imageView3Frame
            if needAllImageNodes {
                imageNode4.frame = normalImagesLayout.imageView4Frame
            }
        }
    }
    
    // MARK: - Target & Action
    @objc fileprivate func tap(sender: UITapGestureRecognizer) {
        
        guard let attachments = feed?.imageAttachments else {
            return
        }
        
        guard let _ = attachments.first else {
            return
        }
        
        let views = imageNodes.map {$0.view}
        
        guard let view = sender.view, let index = views.index(of: view) else {
            return
        }
        
        let transitionView = imageNodes[index].view
        let image = imageNodes[index].image
        let imageAttachments = attachments
        tapMediaAction?(transitionView, image, imageAttachments, index)
        
    }
    
}
