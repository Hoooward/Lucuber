//
//  FormulaDetailViewController+Perpare.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/17.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import Foundation
import RealmSwift

extension FormulaDetailViewController {
    
    func prepareFormulaFrom(_ feed: DiscoverFeed, inRealm realm: Realm) ->  Formula? {
        
         let groupID = feed.objectId!
        
        var group = groupWith(groupID, inRealm: realm)
        
        if group == nil {
            
            let newGroup = Group()
            newGroup.groupID = groupID
            newGroup.includeMe = false
            
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
        

        if let group = group {
            saveFeedWithDiscoverFeed(feed, group: group, inRealm: realm)
        }
        
        if let feed = feedWith(groupID, inRealm: realm) {
            
            if let formula = feed.withFormula {
                return formula
            }
        }
        
        return nil
    }
}


