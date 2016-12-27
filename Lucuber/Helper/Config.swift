//
//  Config.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

extension Notification.Name {
    
    static let formulaCategoryMenuDidmissNotification = Notification.Name("formulaCategoryMenuDismissNotification")
    
    static let categotyPickViewDidSeletedRowNotification = Notification.Name("categoryPickViewDidSelectedRowNotification")
    
    static let changeRootViewControllerNotification = Notification.Name("changeRootViewController")
    
    static let updateFormulasLibraryNotification = Notification.Name("updateFormulasLibrary")
    
    static let needReloadFormulaFromRealmNotification = Notification.Name("reloadFormulaFromRealm")
    
    static let updateMessageStatesNotification = Notification.Name("updateMessageStates")
    
    static let updateDraftOfConversationNotification = Notification.Name("updateDraftOfConversation")
    
    static let newMessageIDsReceivedNotification = Notification.Name("newMessageIDsReceived")
    
    static let afterUploadUserInformationNotification = Notification.Name("afterUploadUserInformation")

    static let changedConversationNotification = Notification.Name("changedConversationNotification")

    // AppDelegate
    static let applicationDidBecomeActiveNotification = Notification.Name("applicationDidBecomeActive")

}

public class Config {
    
    public static let forcedHideActivityIndicatorTimeInterval: TimeInterval = 30
    
    public static let mobilePhoneCodeInSeconds = 59
    
    public class func timerDateFormatter() -> DateFormatter  {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "mm:ss:SS"
        return dateFormatter
    }
    
    public class func timeSectionFormatter() -> DateFormatter  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    public class func chatCellAvatarSize() -> CGFloat {
        return 40.0
    }
    
    public class func chatCellGapBetweenTextContentLabelAndAvatar() -> CGFloat {
        return 23
    }
    
    public class func chatCellGapBetweenWallAndAvatar() -> CGFloat {
        return 15
    }
    
    public class func chatTextGapBetweenWallAndContentLabel() -> CGFloat {
        return 50
    }
    
    public struct ErrorCode {
        
        public static let registered: Int = 888888
    }
    
    public struct TopControl {
        public static let height: CGFloat = 36
        public static let indicaterHeight: CGFloat = 2
        public static let buttonTagBaseValue = 100
    }

    public struct FormulaCell {
        
        public static let normalCellEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        public static let cardCellEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        public static let normalCellSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 80)
        
        public static let cardCellSize: CGSize = CGSize(width: (UIScreen.main.bounds.width - (10 + 10 + 10)) * 0.5, height: 280)

    }
    
    public struct DetailFormula {
        public static let screenMargin: CGFloat = 38
        public static let masterRowHeight: CGFloat = 50
        public static let separatorRowHeight: CGFloat = 40
        public static let ratingViewWidth: CGFloat = 100
        public static let commentRowHeight: CGFloat = 80
    }
   
    public struct CategoryMenu {
        
        public static let rowHeight: CGFloat = 44
        public static let menuWidth: CGFloat = UIScreen.main.bounds.width * 0.5
        public static let menuOrignX: CGFloat = UIScreen.main.bounds.width - CategoryMenu.menuWidth - 10
    }
    
    public struct InputAccessory {
        
        public static let buttonWidth: CGFloat = 35
        public static let buttonHeight: CGFloat = 25
    }
    
    public struct NewFormulaNotificationKey {
        
        public static let name: String = "nameChanged" 
        public static let category: String = "categoryChanged"
        public static let categoryEnglish: String = "categoryEnglishChanged"
        public static let categoryChinese: String = "categoryChineseChanged"
        public static let starRating: String = "starRatingChanged"
        public static let formula: String = "formulaChanged"
        
    }
    
    public struct Avatar {
        public static let maxSize: CGSize = CGSize(width: 414, height: 414)
    }
    
    public struct FormulaDetail {
        public static let screenMargin: CGFloat = 38
        public static let masterRowHeight: CGFloat = 50
        public static let separatorRowHeight: CGFloat = 40
        public static let commentRowHeight: CGFloat = 80
        
        public static let contentsegmentedControlHeight = 38
        public static let totalContentLayoutMargin: CGFloat = 10 +  12 + 35 + 20 + 20

    }
    public struct DetailHeaderView {
        public static let screenMargin: CGFloat = 46
        public static let imageViewWidth: CGFloat = UIScreen.main.bounds.width - 46 - 46
        public static let starRatingViewWidth: CGFloat = 100
        public static let collectionViewMinimumLineSpacing: CGFloat = 6
        
    }
    
    public struct ContentCell {
        
        public static let topMarge: CGFloat = 10
        public static let marge: CGFloat = 38
    }
    
    public struct ChatCell {
        
        public static let marginTopForGroup: CGFloat = 22
        public static let nameLabelHeightForGroup: CGFloat = 17
        
        public static let magicWidth: CGFloat = 4
        
        public static let lineSpacing: CGFloat = 5
        
        public static let minTextWidth: CGFloat = 17
        
        public static let gapBetweenDotImageViewAndBubble: CGFloat = 13
        
        public static let gapBetweenAvatarImageViewAndBubble: CGFloat = 5
        
        public static let playImageViewXOffset: CGFloat = 3
        
        public static let locationNameLabelHeight: CGFloat = 20
        
        public static let mediaPreferredWidth: CGFloat = CubeRuler.iPhoneHorizontal(192, 225, 250).value
        public static let mediaPreferredHeight: CGFloat = CubeRuler.iPhoneHorizontal(208, 244, 270).value

        public static let mediaMinWidth: CGFloat = 60
        public static let mediaMinHeight: CGFloat = 45
        
        public static let imageMaxWidth: CGFloat = CubeRuler.iPhoneHorizontal(230, 260, 300).value
        
        public static let centerXOffset: CGFloat = 4
        
        public static let bubbleCornerRadius: CGFloat = 18
        
        public static let imageAppearDuration: TimeInterval = 0.1
        
        public static let textAttributes:[String: NSObject] = [
            NSFontAttributeName: UIFont.chatTextFont(),
            ]
    }
    
    public struct Media {
        
        public static let imageWidth: CGFloat = 2048
        public static let imageHeight: CGFloat = 2048
        
        public static let miniImageWidth: CGFloat = 200
        public static let miniImageHeight: CGFloat = 200
    }
    
    public struct MetaData {
        
        public static let imageWidth = "image_width"
        public static let imageHeight = "image_height"
        
        public static let thumbnailString = "thumbnail_string"
        public static let blurredThumbnailString = "blurred_thumbnail_string"
        
        public static let videoWidth = "video_width"
        public static let videoHeight = "video_height"
        
        public static let audioDuration = "audio_duration"
        public static let audioSamples = "audio_samples"
        
        public static let thumbnailMaxSize: CGFloat = 60
    }


    struct FeedHeaderView {
        static let textAttributes: [String: NSObject] = [
                NSFontAttributeName: UIFont.feedMessageTextView()
        ]
    }
    public struct FeedDetailCell {
        
        public static let categryButtonAttributies = [NSFontAttributeName: UIFont.feedCategoryButtonTitle()]
        
        public static let messageTextViewAttributies = [NSFontAttributeName: UIFont.feedMessageTextView()]
        
        public static let bottomLabelTextAttributies = [NSFontAttributeName: UIFont.feedBottomLabel()]
    }
    
    public struct FeedBiggerImageCell {
        public static let imageSize = CGSize(width: 160, height: 160)
    }
    
    public struct FeedAnyImagesCell {
        public static let maxImageCount = 4
        public static let width = CGFloat((UIScreen.main.bounds.width - 65 - 15 - 16) / 4)
        public static let imageSize = CGSize(width: width, height: width)
        public static let mediaCollectionViewSize = CGSize(width: UIScreen.main.bounds.width, height: width)
    }
    
    public struct NewFeedFullImage {
        public static let maxSize: CGFloat = 1024
    }
    
    public class func avatarMaxSize() -> CGSize {
        return CGSize(width: 414, height: 414)
    }
    
    public struct RotationControl {
        public static let controlMargin: CGFloat = 25 + 35 + 25 + 40
    }
    

}

extension Config {
    
    public static var timeAgoAction: ((Date) -> String)?
    public static var isAppActive: (() -> Bool)?
}






