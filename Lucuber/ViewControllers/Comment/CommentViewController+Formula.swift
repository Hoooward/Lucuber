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
        
        // 用 Formula 的 objecID （自己生成的）
        let groupID = formula.localObjectID
        
        // 查找是否存在 group
        var group = groupWith(groupID, inRealm: realm)
        
        // 如果不存在就创建
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
        
        
        // 判断是否有 group 对应的 conversation, 没有就创建
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
            
            // 去查找本地 Realm 中的 RFormula
//            if let formula = formulaWith(objectID: groupID, inRealm: realm) {
//                formula.group = group
//                group.withFormula = formula
//            }
        }
        
        return formluaConversation
        
        
    }
}
