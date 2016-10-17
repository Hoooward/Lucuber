//
//  Realm.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/20.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud

// MARK: - Formula

func formulaWithFormulaID(formulaID: String , inRealm realm: Realm) -> RFormula? {
    
    let predicate = NSPredicate(format: "objectID = %@", formulaID)
    
    #if DEBUG
//        let feeds = realm.objects(Feed).filter(predicate)
//        if feeds.count > 1 {
//            println("Warning: same feedID: \(feeds.count), \(feedID)")
//        }
    #endif
    
    return realm.objects(RFormula.self).filter(predicate).first
    
}

// MEssage

func userWithUserID(userID: String, inRealm realm: Realm) -> RUser? {
    
    let predicate = NSPredicate(format: "userID = %@", userID)
    
    return realm.objects(RUser.self).filter(predicate).first
}


func groupWithGroupID(groupID: String, inRealm realm: Realm) -> Group? {
    
    let predicate = NSPredicate(format: "groupID = %@" , groupID)
    return realm.objects(Group.self).filter(predicate).first
}


func messagesOfConversation(conversation: Conversation, inRealm realm: Realm) -> Results<Message> {
    
    let predicate = NSPredicate(format: "conversation = %@", conversation)
    let messages = realm.objects(Message.self).filter(predicate).sorted(byProperty: "createdUnixTime", ascending: true)
    return messages
    
}

func messageWithMessageID(messageID: String, inRealm realm: Realm) -> Message? {
    
    if messageID.isEmpty {
        return nil
    }
    
    let predicate = NSPredicate(format: "messageID = %@", messageID)
    let message = realm.objects(Message.self).filter(predicate)
    return message.first
}


/**
 After loaded Libray formulas form LeanCloud. need delete old formulas content
 and rewrite new content
 if dont do this,  the old conents still exist
 */

public func deleteLibraryFormalsRContentAtRealm() {
    
    let realm = try! Realm()
    
    try! realm.write {
        
        let predicate = NSPredicate(format: "isLibraryFormulas == %@", true as Bool as CVarArg)
        let formulas = realm.objects(RFormula.self).filter(predicate)
        
        formulas.forEach {
            
            $0.contentsString.forEach {
                realm.delete($0)
                
            }
        }
    }
    
}

public func deleteMyFormulasRContentAtRealm() {
    
    guard let realm = try? Realm() else {
        return
    }
    
    try? realm.write {
        
        let predicate = NSPredicate(format: "isLibraryFormulas == %@", false as Bool as CVarArg)
        let formulas = realm.objects(RFormula.self).filter(predicate)
        
        formulas.forEach {
            
            $0.contentsString.forEach {
                realm.delete($0)
            }
        }
    }
}


/**
 After loaded formulas from LeanCloud, or user creat new Formula,
 update categoryMenusList
 
 - parameter categorys:    new categorys
 - parameter mode:         which userinterface : My or Library
 - parameter isNewFormula: its user creat new formula or not
 */

public func saveCategoryMenusAtRealm(categorys: [Category], mode: UploadFormulaMode?, isNewFromula: Bool = false) {
    
    let realm = try! Realm()
    
    if !isNewFromula {
        
        try! realm.write {
            
            if let mode = mode {
                
                let predicate = NSPredicate(format: "mode == %@", mode.rawValue)
                realm.delete(realm.objects(RCategory.self).filter(predicate))
                
                printLog("\(mode.rawValue) -> " + "重新从服务器获取公式后, 删除 Realm 中的所有 CategoryMenuList")
                
                // if Library categorys have changed, 必须将之前选中的公式类别更改为默认的三阶, 不然可能之前存储的选中类别已不存在.
                UserDefaults.setSelected(category: .x3x3, mode: .library)
                
                var result = [RCategory]()
                categorys.forEach {
                    category in
                    let r = category.convertToRCategory()
                    r.mode = mode.rawValue
                    result.append(r)
                }
                
                realm.add(result)
                
                printLog("\(mode.rawValue) -> " + "新的 CategoryMenuList 写入 Realm")
            }
            
        }
        
    } else {
        
         // if creat new Formula,  categorys are only have one object
        let rNew = categorys.first!.convertToRCategory()
        
        let predicate = NSPredicate(format: "mode == %@", UploadFormulaMode.my.rawValue)
        let predicate2 = NSPredicate(format: "categoryString == %@", rNew.categoryString)
        
        if realm.objects(RCategory.self).filter(predicate).filter(predicate2).isEmpty {
            
            try! realm.write {
                
                rNew.mode = UploadFormulaMode.my.rawValue
                realm.add(rNew)
            }
            
             printLog("\(UploadFormulaMode.my.rawValue) -> " + "CategoryMenuList 添加新类别成功")
            
        } else {
           
            printLog("\(UploadFormulaMode.my.rawValue) -> " + "此类别已经在数据库中了")
            
        }
    }
    
}

/**
 Get formula's category from Realm
 
 - parameter mode: Which userinsterface need this
 
 - returns: [Category]
 */

public func getCategoryMenusAtRealm(mode: UploadFormulaMode) -> [Category] {
    
    let realm = try! Realm()
    let predicate = NSPredicate(format: "mode == %@", mode.rawValue)
    return realm.objects(RCategory.self).filter(predicate).map { $0.convertToCategory() }.sorted { $0.sortIndex < $1.sortIndex }
    
}

/**
 After get Formuls from LeanCloud or User creat new Formula at local
 Update Data
 
 - parameter formulas:          [Formula] from LeanCloud
 - parameter mode:              My or Library
 - parameter isCreatNewFormula: its user creat new formula at local or note
 */

public func saveUploadFormulasAtRealm(formulas: [Formula], mode: UploadFormulaMode?, isCreatNewFormula: Bool = false) {
    
    let realm = try! Realm()
    
    try! realm.write {
        
        realm.add(formulas.map { $0.convertRFormulaModel()}, update: true)
    }
    
    /// get new category menu list
    var categorys = Set<Category>()
    
    formulas.forEach {
        if !categorys.contains($0.category) {
            categorys.insert($0.category)
        }
    }
    
    saveCategoryMenusAtRealm(categorys: Array(categorys), mode: mode, isNewFromula: isCreatNewFormula)
}

/**
 get formuls from Realm.
 
 - parameter mode:     .My or .Library
 - parameter category: formula's categoty, etc: .x3x3 .x5x5
 
 - returns: Change the RFormula to Formula's Objects
 */

public func getFormulsFormRealmWithMode(mode: UploadFormulaMode, category: Category) -> [Formula] {
    
    let realm = try! Realm()
    
    switch mode {
        
    case .my:
        
        if let currentUser = AVUser.current() {
            
            let id = currentUser.objectId!
            let predicate = NSPredicate(format: "creatUserID = %@", id)
            let predicate2 = NSPredicate(format: "categoryString == %@", category.rawValue)
            let result =  realm.objects(RFormula.self).filter(predicate).filter(predicate2)
            return result.map{ $0.convertToFromula() }
        }
        
        return [Formula]()
        
    case .library:
        
        let predicate = NSPredicate(format: "isLibraryFormulas == true")
        let predicate2 = NSPredicate(format: "categoryString == %@", category.rawValue)
        return realm.objects(RFormula.self).filter(predicate).filter(predicate2).map { $0.convertToFromula() }
    }
}



extension Category {
    
    func convertToRCategory() -> RCategory {
        switch self {
        default:
            let r = RCategory()
            r.categoryString = self.rawValue
            return r
        }
    }
}


extension FormulaContent {
    
    func convertRContent() -> RContent {
        
        let content = RContent()
        
        if let text = text {
            content.text = text
        }
        
        switch rotation {
        case .BL(let rotation, _):
            content.rotation = rotation
        case .FL(let rotation, _):
            content.rotation = rotation
        case .FR(let rotation, _):
            content.rotation = rotation
        case .BR(let rotation, _):
            content.rotation = rotation
        }
        return content
    }
}

class RCategory: Object {
    
    dynamic var categoryString = ""
    dynamic var mode = ""
    
    func convertToCategory() -> Category {
        return Category(rawValue: categoryString)!
    }
}

class RContent: Object {
    
    dynamic var text = ""
    dynamic var rotation = ""
    dynamic var cellHeight = 0
    
    //    let owners = LinkingObjects(fromType: RFormula.self, property: "contentsString")
    
    func convertToFormulaContent() -> FormulaContent {
        return FormulaContent(text: text, rotation: rotation)
    }
}

extension AVUser {
    
    func converRUserModel() -> RUser {
        let rUser = RUser()
        rUser.avatarImageUrl = self.getUserAvatarImageUrl()
        rUser.userID = self.objectId
        rUser.nickName = self.getUserNickName()
        return rUser
    }
}

public enum UserFriendState: Int {
    case Stranger       = 0   // 陌生人
    case IssuedRequest  = 1   // 已对其发出好友请求
    case Normal         = 2   // 正常状态的朋友
    case Blocked        = 3   // 被屏蔽
    case Me             = 4   // 自己
    case Yep            = 5   // Yep官方账号
}

class RUser: Object {
    
    dynamic var userID: String = ""
    dynamic var nickName: String?
    dynamic var userName: String = ""
    dynamic var avatarImageUrl: String?
    
    dynamic var introduction: String = ""
    
    public override static func indexedProperties() -> [String] {
        return ["userID"]
    }
    
    let messages = LinkingObjects(fromType: Message.self, property: "creatUser")
    let conversations = LinkingObjects(fromType: Conversation.self, property: "withFriend")
    
    var conversation: Conversation? {
        return conversations.first
    }
    
    public let ownedGroups = LinkingObjects(fromType: Group.self, property: "owner")
    public let belongsToGroups = LinkingObjects(fromType: Group.self, property: "members")
//    public let createdFeeds = LinkingObjects(fromType: Feed.self, property: "creator")
    
    dynamic var leanCloudObjectID: String = ""
    
    func convertToAVUser() -> AVUser {
        
        let user = AVUser()
        user.set(userID: userID)
        
        if let nickName = nickName {
            user.set(nikeName: nickName)
        }
        
        if let url = avatarImageUrl {
            user.setUserAvatar(imageUrl: url)
        }
        
        
        user.username = userName
        
        return user
    }
    
    func isMe() -> Bool {
        
        guard let currentUser = AVUser.current(), let userID = currentUser.objectId else {
            return false
        }
        
        return userID == self.userID
        
    }
}


extension Formula {
    
    func convertRFormulaModel() -> RFormula {
        
        let formula = RFormula()
        formula.objectID = objectID
        formula.name = name
        
        formula.imageName = imageName
        formula.favorate = favorate
        formula.creatUserID = creatUser.objectId
        formula.categoryString = categoryString
        formula.typeString = typeString
        formula.rating = rating
        
        contents.map { $0.convertRContent() }.forEach {
            formula.contentsString.append($0)
        }
        
        formula.isLibraryFormulas = isLibraryFormula
        return formula
        
    }
}

class RFormula: Object {
    
    override static func primaryKey() -> String? {
        return "objectID"
    }
    
    dynamic var objectID = ""
    dynamic var name = ""
    dynamic var imageName = ""
    dynamic var favorate: Bool = false
    dynamic var creatUserID: String = ""
    dynamic var categoryString = ""
    dynamic var typeString  = ""
    dynamic var rating = 0
    dynamic var isLibraryFormulas = false
    
    
    dynamic var group: Group?
    
    
    var contentsString = List<RContent>()
    
    func convertToFromula() -> Formula {
        
        let formula = Formula()
        
        formula.objectID = objectID
        formula.name = name
        formula.imageName = imageName
        formula.favorate = favorate
        formula.categoryString = categoryString
        formula.typeString = typeString
        formula.rating = rating
        formula.contents = contentsString.map { $0.convertToFormulaContent()}
        formula.creatUserID = creatUserID
        
        
        
        return formula
    }
    
}
















