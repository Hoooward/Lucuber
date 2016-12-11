//
//  CommentViewController+Feed.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/10.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift

extension CommentViewController {
    
    func prepareConversation(for feed: DiscoverFeed, inRealm realm: Realm) -> Conversation? {
    
        let groupID = feed.objectId!
        
        var group = groupWith(groupID, inRealm: realm)
        
        if group == nil {
            
            let newGroup = Group()
            newGroup.groupID = groupID
            newGroup.incloudMe = false
            
            realm.add(newGroup)
            
            group = newGroup
        }
        
        guard let feedGroup = group else {
            return nil
        }
        
        feedGroup.groupType = GroupType.Public.rawValue
        
        if feedGroup.conversation == nil {
            
            let newConversation = Conversation()
            
            newConversation.type = ConversationType.group.rawValue
            newConversation.withGroup = feedGroup
            
            realm.add(newConversation)
        }
        
        guard let feedConversation = feedGroup.conversation else {
            return nil
        }
        
        if let group = group {
            saveFeedWithDiscoverFeed(feed, group: group, inRealm: realm)
        }
        
        return feedConversation
        
    }
    
}
