//
//  Feed.swift
//  Lucuber
//
//  Created by Howard on 7/22/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

public class DiscoveredUser: Hashable {
    
    public struct SocialAccountProvider {
        public let name: String
        public let enabled: Bool
    }
    
    public let id: String = ""
    public let username: String? = nil
    public let nickname: String = ""
    public let introduction: String? = nil
    public let avatarURLString: String = ""
    public let badge: String? = ""
    public let blogURLString: String? = ""
    public let blogTitle: String? = ""
    
    public let createdUnixTime: NSTimeInterval = 0
    public let lastSignInUnixTime: NSTimeInterval = 0
    
    public var hashValue: Int {
        return id.hashValue
    }
}

public func ==(lhs: DiscoveredUser, rhs: DiscoveredUser) -> Bool {
    return lhs.id == rhs.id
}





public enum FeedKind: String {
    case Text = "text"
    case URL = "web_page"
    case Image = "image"
    case Video = "video"
    case Audio = "audio"
    case Location = "location"
    
    case AppleMusic = "apple_music"
    case AppleMovie = "apple_movie"
    case AppleEBook = "apple_ebook"
    
    
    public var needBackgroundUpload: Bool {
        switch self {
        case .Image:
            return true
        case .Audio:
            return true
        default:
            return false
        }
    }
    
    public var needParseOpenGraph: Bool {
        switch self {
        case .Text:
            return true
        default:
            return false
        }
    }
}

public struct DiscoveredFeed: Hashable {
    
    public var hashValue: Int {
        return id.hashValue
    }
    
    public let id: String = ""
    public let allowComment: Bool = true
    public let kind: FeedKind = .Text
    
    public let createdUnixTime: NSTimeInterval = 0
    public let updatedUnixTime: NSTimeInterval = 0
    
    public let creator: DiscoveredUser
    
    public let body: String
    public let highlightedKeywordsBody: String?

}

public func ==(lhs: DiscoveredFeed, rhs: DiscoveredFeed) -> Bool {
    return lhs.id == rhs.id
}


public enum FeedCategory: String {
    
    case All = "所有"
    case Formula = "公式"
    case Record = "成绩"
    case Topic = "话题"

    
}

class Feed: AVObject, AVSubclassing  {
    
    class func parseClassName() -> String {
        return "Feed"
    }
    
    static let Feedkey_creator = "creator"
    static let Feedkey_body = "contentBody"
    static let Feedkey_kind = "kindString"
    static let Feedkey_category = "category"
    static let FeedKey_imagesURL = "imagesUrl"
    static let FeedKey_comments = "comments"
    
    
    ///作者
    @NSManaged var creator: AVUser?
    
    ///内容
    @NSManaged var contentBody: String?
    
    ///种类, FeedCategory -> 公式, 成绩, 话题
    @NSManaged var category: String?
    
    ///图片附件URL
    @NSManaged var imagesUrl: [String]?
    
    ///评论
    @NSManaged var comments: [String]?
    
    
    ///附件的种类
    enum Attachment: String {
        
        case BigImage = "bigImage"
        case MultiImages = "MultiImages"
        case Text = "text"
        case Formula = "Formula"
        
    }
    
    
    ///通过 ImageURL 的数量来判断 附件的种类
    var attachment: Attachment {
        
        guard let imagesUrl = imagesUrl else {
            return .Text
        }
        
        if imagesUrl.count == 0 { return .Text }
        
        return imagesUrl.count > 1 ? .MultiImages : .BigImage
    }
    
    
    
    //    var kind: FeedKind {
    //        if let kindString = self.kindString,
    //            let kind = FeedKind.init(rawValue: kindString) {
    //            return kind
    //        }
    //        return .Text
    //    }
}






















