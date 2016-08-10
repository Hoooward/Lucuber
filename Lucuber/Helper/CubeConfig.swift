//
//  CubeConfig.swift
//  Lucuber
//
//  Created by Howard on 7/15/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

public let FRrotation: Rotation = Rotation.FR("FR", "图例的状态")
public let FLrotation: Rotation = Rotation.FL("FL", "魔方整体顺时针旋转 90° 的状态")
public let BLrotation: Rotation = Rotation.BL("BL", "魔方整体顺时针旋转 180° 的状态")
public let BRrotation: Rotation = Rotation.BR("BR", "魔方整体顺时针旋转 270° 的状态")

public let defaultRotations = [FRrotation, FLrotation, BLrotation, BRrotation]


final public class CubeConfig {
   
    public static let forcedHideActivityIndicatorTimeInterval: NSTimeInterval = 30
    
    
    
    public struct CagetoryMenu {
        public static let rowHeight: CGFloat = 44
        public static let menuWidth: CGFloat = screenWidth / 2
        public static let menuOrignX: CGFloat = screenWidth - CagetoryMenu.menuWidth - 10
    }
    
    public struct DetailFormula {
        public static let screenMargin: CGFloat = 38
        public static let masterRowHeight: CGFloat = 50
        public static let separatorRowHeight: CGFloat = 40
        public static let ratingViewWidth: CGFloat = 100
        public static let commentRowHeight: CGFloat = 80
    }
    
    public struct ContactsCell {
        public static let separatorInset = UIEdgeInsets(top: 0, left: 85, bottom: 0, right: 0)
    }
    
    public struct FeedDetailCell {
        
        public static let categryButtonAttributies = [NSFontAttributeName: UIFont.feedCategoryButtonTitleFont()]
        
        public static let messageTextViewAttributies = [NSFontAttributeName: UIFont.feedMessageTextViewFont()]
        
        public static let bottomLabelTextAttributies = [NSFontAttributeName: UIFont.feedBottomLabelFont()]
    }
    
    public struct FeedBiggerImageCell {
        public static let imageSize = CGSize(width: 160, height: 160)
    }
    
    public struct FeedAnyImagesCell {
        public static let maxImageCount = 4
        public static let width = CGFloat((screenWidth - 65 - 15 - 16) / 4)
        public static let imageSize = CGSize(width: width, height: width)
        public static let mediaCollectionViewSize = CGSize(width: screenWidth, height: width)
    }
    
    public struct NewFeedFullImage {
        public static let MaxSize: CGFloat = 800
    }
    
    
}