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


public enum FeedCategory: String {
    
    case Formula = "公式"
    case Record = "成绩"
    case Topic = "话题"
    
    
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

class Feed: AVObject, AVSubclassing  {
    
    class func parseClassName() -> String {
        return "Feed"
    }
    
    
    
    /// 作者
    static let Feedkey_creator = "creator"
    @NSManaged var creator: AVUser?
    
    static let Feedkey_body = "contentBody"
    @NSManaged var contentBody: String?
    
    static let Feedkey_kind = "kindString"
    @NSManaged var kindString: String?
    
    static let Feedkey_category = "category"
    @NSManaged var category: String?
    
    static let FeedKey_imagesURL = "imagesUrl"
    @NSManaged var imagesUrl: [String]?
    
    static let FeedKey_comments = "comments"
    @NSManaged var comments: [String]?
    
    
    var kind: FeedKind {
        if let kindString = self.kindString,
            let kind = FeedKind.init(rawValue: kindString) {
            return kind
        }
        return .Text
    }
    
    enum Attachment: String {
        case BigImage = "bigImage"
        case MultiImages = "MultiImages"
        case Text = "text"
    }
    
//    static let FeedKey_attachment = "attachmentString"
//    @NSManaged var attachmentString: String?
    
    var attachment: Attachment {
        guard let imagesUrl = imagesUrl else {
            return .Text
        }
        if imagesUrl.count == 0 { return .Text }
        return imagesUrl.count > 1 ? .MultiImages : .BigImage
    }
    
    
    
}






















