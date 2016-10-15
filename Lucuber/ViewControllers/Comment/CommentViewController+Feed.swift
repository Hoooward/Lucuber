//
//  CommentViewController+Feed.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/15.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift


extension CommentViewController {
    
    func prepareConversation(withFromula formula: Formula, inRealm realm: Realm) -> Conversation? {
        
        let groupID = formula.objectID
        
        var group = groupWithGroupID(groupID: groupID, inRealm: realm)
        
        if group == nil {
            
            let newGroup = Group()
            newGroup.incloudMe = false
            newGroup.groupID = groupID
            
            realm.add(newGroup)
            
            group = newGroup
        }
        
        guard let formulaGroup = group else {
            return nil
        }
        
        
        formulaGroup.groupType = GroupType.Public.rawValue
        
        if formulaGroup.conversation == nil {
            
            let newConversation = Conversation()
            
            newConversation.type = ConversationType.group.rawValue
            newConversation.withGroup = formulaGroup
            
            realm.add(newConversation)
        }
        
        guard let formluaConversation = formulaGroup.conversation else {
            return nil
        }
        
        if let group = group {
            
            if let rformula = formulaWithFormulaID(formulaID: groupID, inRealm: realm) {
                rformula.group = group
                group.withFormula = rformula
            }
        }
        
        return formluaConversation
        
        
    }
}
