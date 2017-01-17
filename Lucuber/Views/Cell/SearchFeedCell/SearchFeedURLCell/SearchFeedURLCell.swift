//
//  SearchFeedURLCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/17.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

final class SearchFeedURLCell: SearchFeedBasicCell {
    
    override class func heightOfFeed(_ feed: DiscoverFeed) -> CGFloat {
        
        let height = super.heightOfFeed(feed) + (10 + 20)
        
        return ceil(height)
    }
    
    var tapURLInfoAction: ((_ URL: URL) -> Void)?
    
    lazy var feedURLContainerView: IconTitleContainerView = {
        let view = IconTitleContainerView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        return view
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(feedURLContainerView)
        
        feedURLContainerView.iconImageView.image = UIImage(named: "icon_link")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureCell(with feed: DiscoverFeed, layout: SearchFeedCellLayout, keyword: String?) {
        super.configureCell(with: feed, layout: layout, keyword: keyword)
        
        
        if let attachment = feed.attachment {
            
            switch attachment {
                
            case .URL(let openGraphInfo):
               
                
                feedURLContainerView.titleLabel.text = openGraphInfo.title
                
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
}








