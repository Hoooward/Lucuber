//
//  FeedCellLayout.swift
//  Lucuber
//
//  Created by Howard on 7/22/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

struct FeedCellLayout {
    
    /// 所有Cell的公共元素
    struct DefaultLayout {
        
        let avatarImageViewFrame: CGRect
        let nicknameLabelFrame: CGRect
        let categoryButtonFrame: CGRect
        let messageTextViewFrame: CGRect
        let leftBottomLabelFrame: CGRect
        let messageCountLabelFrame: CGRect
        let discussionImageViewFrame: CGRect
        
    }
    var defaultLayout: DefaultLayout
    
    struct BiggerImageLayout {
        
        let biggerImageViewFrame: CGRect
        
    }
    var biggerImageLayout: BiggerImageLayout?
   
    struct AnyImagesLayout {
        
        let mediaCollectionViewFrame: CGRect
    }
    
    var anyImagesLayout: AnyImagesLayout?
    
    
    /// Cell的高度
    var height: CGFloat = 0
    
    
    init(feed: Feed) {
        
       
        switch feed.attachment {
        case .Text:
            height = FeedDefaultCell.heightOfFeed(feed)
        case .Image(let imagesAttachments):
            print(imagesAttachments)
            if imagesAttachments.count > 1 {
                height = FeedAnyImagesCell.heightOfFeed(feed)
            } else {
                height = FeedBiggerImageCell.heightOfFeed(feed)
            }
        default:
            break
        }
        
        let avatarImageViewFrame = CGRect(x: 15, y: 10, width: 40, height: 40)
        
        let nicknameLabelFrame: CGRect
        let categoryButtonFrame: CGRect
        
        if let category = FeedCategory(rawValue: feed.category) {
            
            let rect = (category.rawValue as NSString).boundingRectWithSize(CGSize(width: 320, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: CubeConfig.FeedDetailCell.categryButtonAttributies, context: nil)
            
            let categoryButtonWidth = ceil(rect.width) + 20
            
            categoryButtonFrame = CGRect(x: screenWidth - categoryButtonWidth - 15, y: 19, width: categoryButtonWidth, height: 22)
            
            let nickNameLabelwidth = screenWidth - 65 - 15
            nicknameLabelFrame = CGRect(x: 65, y: 21, width: nickNameLabelwidth, height: 18)
            
            
        } else {
            let nickNameLabelwidth = screenWidth - 65 - 15
            nicknameLabelFrame = CGRect(x: 65, y: 21, width: nickNameLabelwidth, height: 18)
            categoryButtonFrame = CGRectZero
        }
        
        let rect1 = (feed.contentBody! as NSString).boundingRectWithSize(CGSize(width: FeedDefaultCell.messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesFontLeading, .UsesLineFragmentOrigin], attributes: CubeConfig.FeedDetailCell.messageTextViewAttributies, context: nil)
        
        let messageTextViewHeight = ceil(rect1.height)
        let messageTextViewFrame = CGRect(x: 65, y: 54, width: screenWidth - 65 - 15, height: messageTextViewHeight)
        
        let leftBottomLabelOriginY = height - 17 - 15
        let leftBottomLabelFrame = CGRect(x: 65, y: leftBottomLabelOriginY, width: screenWidth - 65 - 85, height: 17)
        
        let messageCountLabelWidth: CGFloat = 30
        let messageConuntLabelFrame = CGRect(x: screenWidth - messageCountLabelWidth - 39 - 8, y: leftBottomLabelOriginY, width: messageCountLabelWidth, height: 19)
        
        let discussionImageViewFrame = CGRect(x: screenWidth - 24 - 15, y: leftBottomLabelOriginY - 1, width: 24, height: 20)
        
        let defaultLayout = FeedCellLayout.DefaultLayout(
            avatarImageViewFrame: avatarImageViewFrame,
            nicknameLabelFrame: nicknameLabelFrame,
            categoryButtonFrame: categoryButtonFrame,
            messageTextViewFrame: messageTextViewFrame,
            leftBottomLabelFrame: leftBottomLabelFrame,
            messageCountLabelFrame: messageConuntLabelFrame,
            discussionImageViewFrame: discussionImageViewFrame
        )
        
        self.defaultLayout = defaultLayout
        
        let beginY = CGRectGetMaxY(messageTextViewFrame) + 15
        
        switch feed.attachment {
            
        case .Image(let imagesAttachments):
            
            if imagesAttachments.count > 1 {
                
                let mediaCollectionViewFrame = CGRect(origin: CGPoint(x:65, y: beginY), size: CubeConfig.FeedAnyImagesCell.mediaCollectionViewSize)
                
                self.anyImagesLayout = AnyImagesLayout(mediaCollectionViewFrame: mediaCollectionViewFrame)
            }
            
            if imagesAttachments.count == 1 {
                
                let biggerImageViewFrame = CGRect(origin: CGPoint(x: 65, y: beginY), size: CubeConfig.FeedBiggerImageCell.imageSize)
                let biggerImageLayout = BiggerImageLayout(biggerImageViewFrame: biggerImageViewFrame)
                self.biggerImageLayout = biggerImageLayout
                
            }
            
  
        default:
            break
        }
    }
    
}