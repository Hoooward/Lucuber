//
//  SearchFeedCellLayout.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/16.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

private let screenWidth: CGFloat = UIScreen.main.bounds.width

struct SearchFeedCellLayout {
    
    let height: CGFloat
    
    struct BasicLayout {
        
        fileprivate let nicknameLabelFrame: CGRect
        let categoryButtonFrame: CGRect
        let avatarImageViewFrame: CGRect
        
        func nicknameLabelFrameWhen(hasLogo: Bool, hasCategory: Bool) -> CGRect {
            var frame = nicknameLabelFrame
            frame.size.width -= hasLogo ? (18 + 10) : 0
            frame.size.width -= hasCategory ? (categoryButtonFrame.width + 10) : 0
            return frame
        }
        
        let messageTextViewFrame: CGRect
        
        init(avatarImageViewFrame: CGRect,
             nicknameLabelFrame: CGRect,
             categoryButtonFrame: CGRect,
             messageTextViewFrame: CGRect) {
            self.avatarImageViewFrame = avatarImageViewFrame
            self.nicknameLabelFrame = nicknameLabelFrame
            self.categoryButtonFrame = categoryButtonFrame
            self.messageTextViewFrame = messageTextViewFrame
        }
    }
    
    let basicLayout: BasicLayout
    
    struct NormalImagesLayout {
        
        let imageView1Frame: CGRect
        let imageView2Frame: CGRect
        let imageView3Frame: CGRect
        let imageView4Frame: CGRect
        
        init(imageView1Frame: CGRect, imageView2Frame: CGRect, imageView3Frame: CGRect, imageView4Frame: CGRect) {
            self.imageView1Frame = imageView1Frame
            self.imageView2Frame = imageView2Frame
            self.imageView3Frame = imageView3Frame
            self.imageView4Frame = imageView4Frame
        }
    }
    
    var normalImagesLayout: NormalImagesLayout?
    
    struct AnyImagesLayout {
        
        let mediaCollectionViewFrame: CGRect
        
        init(mediaCollectionViewFrame: CGRect) {
            self.mediaCollectionViewFrame = mediaCollectionViewFrame
        }
    }
    var anyImagesLayout: AnyImagesLayout?
    
    struct URLLayout {
        let URLContainerViewFrame: CGRect
    }
    var _URLLayout: URLLayout?
    
    struct FormulaLayout {
        let formulaContainerViewFrame: CGRect
    }
    
    var _formulaLayout: FormulaLayout?
    
    init(height: CGFloat, basicLayout: BasicLayout) {
        self.height = height
        self.basicLayout = basicLayout
    }
    
    init(feed: DiscoverFeed) {
       let height: CGFloat
        
        switch feed.category {
            
            
        case .text:
            height = SearchFeedBasicCell.heightOfFeed(feed)
            
        case .url:
            height = SearchFeedURLCell.heightOfFeed(feed)
            
        case .formula:
            height = SearchFeedFormulaCell.heightOfFeed(feed)
            
        case .image:
            
            if feed.imageAttachmentsCount <= SearchFeedsViewController.feedNormalImagesCount {
                height = SearchFeedNormalImagesCell.heightOfFeed(feed)
            } else {
                height = SearchFeedAnyImagesCell.heightOfFeed(feed)
            }
            
        default:
            height = SearchFeedBasicCell.heightOfFeed(feed)
        }
        
        self.height = height
        
        let avatarImageViewFrame = CGRect(x: 10, y: 15, width: 30, height: 30)
        let nicknameLabelFrame: CGRect
        let categotyButtonFrame: CGRect
        
        let formulaCategoryString = feed.withFormula?.category ?? ""
        if !formulaCategoryString.isEmpty {
            let rect = formulaCategoryString.boundingRect(with: CGSize(width: 320, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Config.FeedDetailCell.categryButtonAttributies, context: nil)
            
            let categotyButtonWidth = ceil(rect.width) + 20
            categotyButtonFrame = CGRect(x: screenWidth - categotyButtonWidth - 10, y: 18, width: categotyButtonWidth, height: 22)
            
            let nicknameLabelWidth = screenWidth - 50 - 10
            nicknameLabelFrame = CGRect(x: 50, y: 20, width: nicknameLabelWidth, height: 18)
            
        } else {
            let nicknameLabelWidth = screenWidth - 50 - 10
            nicknameLabelFrame = CGRect(x: 50, y: 20, width: nicknameLabelWidth, height: 18)
            categotyButtonFrame = CGRect.zero
        }
        
        let _rect1 = feed.body.boundingRect(with: CGSize(width: SearchFeedBasicCell.messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Config.FeedDetailCell.messageTextViewAttributies, context: nil)
        
        let messageTextViewHeight = ceil(_rect1.height)
        let messageTextViewFrame = CGRect(x: 50, y: 15 + 30 + 4, width: screenWidth - 50 - 10, height: messageTextViewHeight)
        
        let basicLayout = SearchFeedCellLayout.BasicLayout(
            avatarImageViewFrame: avatarImageViewFrame,
            nicknameLabelFrame: nicknameLabelFrame,
            categoryButtonFrame: categotyButtonFrame,
            messageTextViewFrame: messageTextViewFrame
        )
        
        self.basicLayout = basicLayout
        
        
        let beginY = messageTextViewFrame.origin.y + messageTextViewFrame.height + 10
        
        switch feed.category {
            
        case .formula:
            
            let height: CGFloat = 20
            let formulaContainerViewFrame = CGRect(x: 50, y: beginY, width: screenWidth - 50 - 60, height: height)
            let _formulaLayout = SearchFeedCellLayout.FormulaLayout(formulaContainerViewFrame: formulaContainerViewFrame)
            
            self._formulaLayout = _formulaLayout
            
        case .url:
            let height: CGFloat = 20
            let URLContainerViewFrame = CGRect(x: 50, y: beginY, width: screenWidth - 50 - 60, height: height)
            
            let _URLLayout = SearchFeedCellLayout.URLLayout(URLContainerViewFrame: URLContainerViewFrame)
            
            self._URLLayout = _URLLayout
            
            
        case .image:
            
            if feed.imageAttachmentsCount <= SearchFeedsViewController.feedNormalImagesCount {
                
                let x1 = 50 + (Config.SearchFeedNormalImagesCell.imageSize.width + 5) * 0
                let imageView1Frame = CGRect(origin: CGPoint(x: x1, y: beginY), size: Config.SearchFeedNormalImagesCell.imageSize)
                
                let x2 = 50 + (Config.SearchFeedNormalImagesCell.imageSize.width + 5) * 1
                let imageView2Frame = CGRect(origin: CGPoint(x: x2, y: beginY), size: Config.SearchFeedNormalImagesCell.imageSize)
                
                let x3 = 50 + (Config.SearchFeedNormalImagesCell.imageSize.width + 5) * 2
                let imageView3Frame = CGRect(origin: CGPoint(x: x3, y: beginY), size: Config.SearchFeedNormalImagesCell.imageSize)
                
                let x4 = 50 + (Config.SearchFeedNormalImagesCell.imageSize.width + 5 ) * 3
                let imageView4Frame = CGRect(origin: CGPoint(x: x4, y: beginY), size: Config.SearchFeedNormalImagesCell.imageSize)
                
                let normalImagesLayout = SearchFeedCellLayout.NormalImagesLayout(imageView1Frame: imageView1Frame, imageView2Frame: imageView2Frame, imageView3Frame: imageView3Frame, imageView4Frame: imageView4Frame)
                
                self.normalImagesLayout = normalImagesLayout
                
            } else {
                
                let height = Config.FeedNormalImagesCell.imageSize.height
                let mediaCollectionViewFrame = CGRect(x: 0, y: beginY, width: screenWidth, height: height)
                
                let anyImagesLayout = SearchFeedCellLayout.AnyImagesLayout(mediaCollectionViewFrame: mediaCollectionViewFrame)
                
                self.anyImagesLayout = anyImagesLayout
            }
           
        default:
            break
        }
    }
}
