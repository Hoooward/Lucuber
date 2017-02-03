//
//  ConversationFeed.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/19.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import Foundation
import RealmSwift
import AVOSCloud

enum ConversationFeed {
    
    case discoveredFeedType(DiscoverFeed)
    case feedType(Feed)
    
    var isMyFeed: Bool {
        switch self {
        case .discoveredFeedType(let discoverFeed):
            guard
                let feedCreator = discoverFeed.creator,
                let feedCreatorID = feedCreator.objectId,
                let me = AVUser.current(),
                let meID = me.objectId else {
                return false
            }
            return feedCreatorID == meID
            
        case .feedType(let feed):
            guard
                let feedCreator = feed.creator,
                let me = AVUser.current(),
                let meID = me.objectId else {
                return false
            }
            return feedCreator.lcObjcetID == meID
        }
    }
    
    var feedID: String? {
        switch self {
        case .discoveredFeedType(let discoverFeed):
            return discoverFeed.objectId
            
        case .feedType(let feed):
            guard !feed.isInvalidated else {
                return nil
            }
            return feed.lcObjectID
        }
    }
    
    var body: String {
        switch self {
        case .discoveredFeedType(let discovedFeed):
            return discovedFeed.body
            
        case .feedType(let feed):
            guard !feed.isInvalidated else {
                return ""
            }
            return feed.body
        }
    }
    
    var creator: RUser? {
        switch self {
        case .discoveredFeedType(let discoverFeed):
            guard let realm = try? Realm() else {
                return nil
            }
            realm.beginWrite()
            let user = getOrCreatRUserWith(discoverFeed.creator, inRealm: realm)
            try? realm.commitWrite()
            
            return user
            
        case .feedType(let feed):
            guard !feed.isInvalidated else {
                return nil
            }
            return feed.creator
        }
    }
    
    var category: FeedCategory? {
        
        switch self {
        case .discoveredFeedType(let discoveredFeed):
            return discoveredFeed.category
        case .feedType(let feed):
            guard !feed.isInvalidated else {
                return nil
            }
            return FeedCategory(rawValue: feed.categoryString)
        }
    }
    
    var hasAttachments: Bool {
        
        guard let category = category else {
            return false
        }
        return category != .text
    }
    
    var RFormula: Formula? {
        
        switch self {
        case .discoveredFeedType(let discoverFeed):
            if let attachment = discoverFeed.attachment {
                if case let .formula(formulaInfo) = attachment {
                    
                    guard let realm = try? Realm() else {
                        return nil
                    }
                    if let formula = formulaWith(objectID: formulaInfo.localObjectID, inRealm: realm) {
                        return formula
                    }
                    realm.beginWrite()
                    let formula = convertDiscoverFormulaToFormula(discoverFormula: formulaInfo, uploadMode: .library, withFeed: Feed(), inRealm: realm, completion: nil)
                    try? realm.commitWrite()
                    return formula
                }
            }
        case .feedType(let feed):
            guard !feed.isInvalidated else {
                return nil
            }
            if let formula = feed.withFormula {
                return formula
            }
        }
        return nil

    }
    
    var formulaInfo: DiscoverFormula? {
        switch self {
        case .discoveredFeedType(let discoverFeed):
            if let attachment = discoverFeed.attachment {
                if case let .formula(formulaInfo) = attachment {
                    return formulaInfo
                }
            }
        case .feedType(let feed):
            guard !feed.isInvalidated else {
                return nil
            }
            if let formula = feed.withFormula {
                let discoverFormula = parseFormulaToDisvocerModel(with: formula)
                return discoverFormula
            }
        }
        return nil
    }
    
    var openGraphInfo: OpenGraphInfoType? {
        
        switch self {
        case .discoveredFeedType(let discoverFeed):
            if let attachment = discoverFeed.attachment {
                if case let .URL(openGraphInfo) = attachment {
                    return openGraphInfo
                }
            }
        case .feedType(let feed):
            guard !feed.isInvalidated else {
                return nil
            }
            if let openGraphInfo = feed.openGraphInfo {
                let a = DiscoverFeed.OpenGraphInfo(URL: URL(string: openGraphInfo.URLString)!, siteName: openGraphInfo.siteName, title: openGraphInfo.title, infoDescription: openGraphInfo.infoDescription, thumbnailImageURLString: openGraphInfo.thumbnailImageURLString)
                return a
            }
        }
        
        return nil
    }

    var imageAttachments: [ImageAttachment] {
        switch self {
        case .discoveredFeedType(let discoverFeed):
            
            if let attachment = discoverFeed.attachment {
                if case let .images(attachments) = attachment {
                    return attachments
                }
            }
            
            return []
            
        case .feedType(let feed):
            guard !feed.isInvalidated else {
                return []
            }
            return feed.attachments.map {
                return ImageAttachment(metadata: $0.metadata, URLString: $0.URLString, image: nil)
            }
        }
    }
    
    var createdUnixTime: TimeInterval {
        switch self {
        case .discoveredFeedType(let discoverFeed):
            return discoverFeed.createdAt?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
        case .feedType(let feed):
            guard !feed.isInvalidated else {
                return Date().timeIntervalSince1970
            }
            return feed.createdUnixTime
        }
    }
    
    var timeString: String {
        switch self {
        case .discoveredFeedType(let discoverFeed):
            return discoverFeed.timeString
        case .feedType(let feed):
            guard !feed.isInvalidated else {
                return ""
            }
            let date = Date(timeIntervalSince1970: feed.createdUnixTime)
            let timeString = date.timeAgo
            return timeString
        }
    }
}
