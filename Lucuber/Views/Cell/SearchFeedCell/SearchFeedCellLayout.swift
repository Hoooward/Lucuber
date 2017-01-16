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
        let FormulaContainerViewFrame: CGRect
    }
    
    var _FormulaLayout: FormulaLayout?
    
    init(height: CGFloat, basicLayout: BasicLayout) {
        self.height = height
        self.basicLayout = basicLayout
    }
    
    init(feed: DiscoverFeed) {
        
        switch feed.category {
            
            
        case .text:
            height = SearchFeedBasicCell.heightOfFeed(feed)
            
        case .url:
            break
        default:
            break
        }
    }
    
}


















