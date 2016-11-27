//
//  Feed.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud


//public struct DiscoveredFeed: AVObject, AVSubclassing {
//    
//    
//
//}





//class Feed1: AVObject, AVSubclassing  {
//    
//    class func parseClassName() -> String {
//        return "Feed"
//    }
//    
//    static let Feedkey_creator = "creator"
//    static let Feedkey_body = "contentBody"
//    static let Feedkey_kind = "kindString"
//    static let Feedkey_category = "category"
//    static let FeedKey_imagesURL = "imagesUrl"
//    static let FeedKey_comments = "comments"
//    
//    
//    ///作者
//    @NSManaged var creator: AVUser?
//    
//    ///内容
//    @NSManaged var contentBody: String?
//    
//    ///种类, FeedCategory -> 公式, 成绩, 话题
//    @NSManaged var category: String
//    
//    ///图片附件URL
//    @NSManaged var imagesUrl: [String]?
//    
//    ///评论
//    @NSManaged var comments: [String]?
//    
//    
//    ///附件的种类
//    enum Attachment  {
//        case Image([ImageAttachment])
//        case Text
//        case Formula
//        
//    }
//    
//    ///通过 ImageURL 的数量来判断 附件的种类
//    var attachment: Attachment {
//        
//        guard let imagesUrl = imagesUrl else {
//            return .Text
//        }
//        
//        if imagesUrl.isEmpty {
//            return .Text
//        }
//        
//        if imagesUrl.isEmpty && FeedCategory(rawValue: self.category) == .Formula {
//            return .Formula
//            
//        }
//        
//        return .Image(imagesUrl.map {ImageAttachment(metadata: nil, URLString: $0, image: nil)})
//    }
//    
//    
//}




