//
//  FeedURLCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/6.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FeedURLCell: FeedBaseCell {
    
    override class func heightOfFeed(feed: DiscoverFeed) -> CGFloat {
        
        let height = super.heightOfFeed(feed: feed) + (100 + 15)
        
        return ceil(height)
    }
    
    public var tapURLInfoAction: ((URL) -> Void)?
    
    lazy var feedURLContainerView: FeedURLContainerView = {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 150)
        let view = FeedURLContainerView(frame: rect)
        view.compressionMode = false
        return view
    }()
    
    override func configureWithFeed(_ feed: DiscoverFeed, layout: FeedCellLayout, needshowCategory: Bool) {
        
        
        super.configureWithFeed(feed, layout: layout, needshowCategory: needshowCategory)
        
        if let attachment = feed.attachment {
            
            switch attachment {
            case .URL(let openGraphInfo):
                
                feedURLContainerView.configureWithOpenGraphInfoType(openGraphInfo: openGraphInfo)
                
                feedURLContainerView.tapAction = { [weak self] in
                    self?.tapURLInfoAction?(openGraphInfo.URL)
                }
                
            default:
                break
            }
        }
        
        let _URLLayout = layout._URLLayout!
        feedURLContainerView.frame = _URLLayout.URLContainerViewFrame
        
       
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(feedURLContainerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
