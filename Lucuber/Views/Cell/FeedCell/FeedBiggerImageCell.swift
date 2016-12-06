//
//  FeedBiggerImageCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit


class FeedBiggerImageCell: FeedBaseCell {
    
    var tapMediaAction: tapMediaActionTypealias = nil
    
    override class func heightOfFeed(feed: DiscoverFeed) -> CGFloat {
        
        let height = super.heightOfFeed(feed: feed) + Config.FeedBiggerImageCell.imageSize.height + 15
        return ceil(height)
        
    }
    
    override func configureWithFeed(_ feed: DiscoverFeed, layout: FeedCellLayout, needshowCategory: Bool) {
        super.configureWithFeed(feed, layout: layout, needshowCategory: needshowCategory)
        
        if let biggerImageLayout = layout.biggerImageLayout {
            biggerImageView.frame = biggerImageLayout.biggerImageViewFrame
        }
        
        switch feed.attachment {
        case .images(let imageAttachments):
            
            if let attachment = imageAttachments.first {
                //大图还是使用原始大小的图片.
                imageAttachment = attachment
                biggerImageView.showActivityIndicatorWhenLoading = true
                biggerImageView.cube_setImageAtFeedCellWithAttachment(attachment: attachment, withSize: nil)
            }
            
        default:
            break
        }
        
        
    }
    
    lazy var biggerImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.frame = CGRect(x: 65, y: 0, width: Config.FeedBiggerImageCell.imageSize.width, height: Config.FeedBiggerImageCell.imageSize.height)
        
        imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        imageView.layer.borderWidth = 1.0 / UIScreen.main.scale
        
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(FeedBiggerImageCell.tap(sender:)))
        imageView.addGestureRecognizer(tap)
        
        return imageView
        
    }()

    func tap(sender: UIGestureRecognizer) {
        
        if let feed = feed {
            switch feed.attachment {
            case .images(let imageAttachments):
                tapMediaAction?(biggerImageView, biggerImageView.image, imageAttachments , 0)
            default:
                break
            }
        }
    }
    
    var imageAttachment: ImageAttachment?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        biggerImageView.image = nil
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(biggerImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
