//
//  FeedBiggerImageCell.swift
//  Lucuber
//
//  Created by Howard on 7/25/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FeedBiggerImageCell: FeedDefaultCell {
    
    var tapMediaAction: ((transitionView: UIView, image: UIImage?, index: Int) -> Void)?

    override class func heightOfFeed(feed: Feed) -> CGFloat {
        
        let height = super.heightOfFeed(feed) + CubeConfig.FeedBiggerImageCell.imageSize.height + 15
        return ceil(height)
        
    }
    
    lazy var biggerImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.frame = CGRect(x: 65, y: 0, width: CubeConfig.FeedBiggerImageCell.imageSize.width, height: CubeConfig.FeedBiggerImageCell.imageSize.height)
        
        imageView.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor
        imageView.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        
        imageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(FeedBiggerImageCell.tap(_:)))
        imageView.addGestureRecognizer(tap)
        
        return imageView
        
    }()
    
    func tap(sender: UIGestureRecognizer) {
       
        printLog("")
        tapMediaAction?(transitionView: biggerImageView, image: biggerImageView.image, index: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        biggerImageView.image = nil
    }
    
    
    override func configureWithFeed(feed: Feed, layout: FeedCellLayout, needshowCategory: Bool) {
        super.configureWithFeed(feed, layout: layout, needshowCategory: needshowCategory)
        
        if let biggerImageLayout = layout.biggerImageLayout {
            biggerImageView.frame = biggerImageLayout.biggerImageViewFrame
        }
        
        switch feed.attachment {
        case .Image(let imageAttachments):
            
            if let attachment = imageAttachments.first,
               let url = NSURL(string: attachment.URLString) {
                biggerImageView.setImageWithURL(url)
            }
            
        default:
            break
        }
        
      
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(biggerImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    


}
