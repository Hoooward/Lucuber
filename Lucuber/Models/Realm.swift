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

public func currentUser(in realm: Realm) -> RUser? {
    guard let avuserID = AVUser.current()?.objectId else { return nil }
    return userWith(avuserID, inRealm: realm)
}

public func masterWith(_ localObjectID: String, atRUser user: RUser, inRealm realm: Realm) -> FormulaMaster? {
    let predicate = NSPredicate(format: "localObjectID = %@", localObjectID)
    let predicate2 = NSPredicate(format: "atRuser = %@", user)
    return realm.objects(FormulaMaster.self).filter(predicate).filter(predicate2).first
}

public func mastersWith(_ creatorLcObjectID: String, inRealm realm: Realm) -> Results<FormulaMaster> {
    let predicate = NSPredicate(format: "creatorLcObjectID = %@", creatorLcObjectID)
    return realm.objects(FormulaMaster.self).filter(predicate)
}

public func formulasCountWith(_ category: Category, uploadMode: UploadFormulaMode, inRealm realm: Realm) -> Int {
    let predicate = NSPredicate(format: "categoryString = %@", category.rawValue)
    
    var predicate2 = NSPredicate()
    switch uploadMode {
    case .library:
        predicate2 = NSPredicate(format: "isLibrary = %@", true as CVarArg)
    case .my:
        predicate2 = NSPredicate(format: "isLibrary = %@", false as CVarArg)
    }
    return realm.objects(Formula.self).filter(predicate2).filter(predicate).count
}

public func categorysWith(_ uploadMode: UploadFormulaMode, inRealm realm: Realm) -> Results<RCategory> {
   
    let predicate = NSPredicate(format: "uploadMode = %@", uploadMode.rawValue)
    
    let categorys = realm.objects(RCategory.self).filter(predicate)
    
    if categorys.isEmpty {
        let newCategory = RCategory(value: ["x3x3", uploadMode.rawValue])
        realm.add(newCategory)
    }
    
    return realm.objects(RCategory.self).filter(predicate)
    
}

public func contentWith(_ objectID: String, inRealm realm: Realm) -> Content? {
    let predicate = NSPredicate(format: "localObjectID = %@", objectID)
    return realm.objects(Content.self).filter(predicate).first
}

public func contentsWith(_ atFormulaObjectID: String, inRealm realm: Realm) -> Results<Content>? {
    let predicate = NSPredicate(format: "atFormulaLocalObjectID = %@", atFormulaObjectID)
    return realm.objects(Content.self).filter(predicate)
}

public func formulaWith(_ objectID: String , inRealm realm: Realm) -> Formula? {
    let predicate = NSPredicate(format: "localObjectID = %@", objectID)
    return realm.objects(Formula.self).filter(predicate).first
}

public func userWith(_ userID: String, inRealm realm: Realm) -> RUser? {
    let predicate = NSPredicate(format: "lcObjcetID = %@", userID)
    return realm.objects(RUser.self).filter(predicate).first
}


public func deleteMaster(with formula: Formula, inRealm realm: Realm) {
    
    guard let currentUser = currentUser(in: realm) else {
        return
    }
    
    let localObjectID = formula.localObjectID
    
    if let master = masterWith(localObjectID, atRUser: currentUser, inRealm: realm) {
            realm.delete(master)
    }
}

public func appendMaster(with formula: Formula, inRealm realm: Realm) {
    
    guard let currentUser = currentUser(in: realm) else {
        return
    }
    
    let localObjectID = formula.localObjectID
    
    if let master = masterWith(localObjectID, atRUser: currentUser, inRealm: realm) {
        return
    }
    let newMaster = FormulaMaster(value: [localObjectID, currentUser.lcObjcetID])
    realm.add(newMaster)
    
}

public func appendRCategory(with formula: Formula, uploadMode: UploadFormulaMode, inRealm realm: Realm) {
    
    let categorys = categorysWith(uploadMode, inRealm: realm)
    
    let categoryTexts = categorys.map { $0.name }
    
    if !categoryTexts.contains(formula.category.rawValue) {
        
        let newRCategory = RCategory()
        newRCategory.uploadMode = uploadMode.rawValue
        newRCategory.name = formula.category.rawValue
        realm.add(newRCategory)
        
    }
    
}

public func appendRUser(with creatorID: String, discoverUser: AVUser, inRealm realm: Realm) -> RUser {
    
    if let creator = userWith(creatorID, inRealm: realm) {
        
        if
            let newMasterList = discoverUser.masterList(),
            let discoverUserID = discoverUser.objectId {
            
            if !newMasterList.isEmpty {
                
                let oldFormulaMasterList = creator.masterList
                let oldMasterList: [String] = oldFormulaMasterList.map {$0.formulaLocalObjectID }
                
                if  oldMasterList == newMasterList {
                    
                    return creator
                    
                } else {
                    
                    creator.masterList.removeAll()
                    realm.delete(oldFormulaMasterList)
                    
                    let newMasterList = newMasterList.map { FormulaMaster(value:[$0, discoverUserID]) }
                    creator.masterList.append(objectsIn: newMasterList)
                    realm.add(newMasterList)
                    
                    printLog("\(creator.username) 的 MasterList 有变化, 已完成本地数据刷新")
                    
                }
            }
        }
        
        return creator
        
    } else {
        
        let newUser = RUser()
        
        newUser.localObjectID = discoverUser.localObjectID() ?? ""
        newUser.lcObjcetID = discoverUser.objectId!
        newUser.avatorImageURL = discoverUser.avatorImageURL()
        newUser.username = discoverUser.username!
        newUser.nickname = discoverUser.nickname()
        newUser.introduction = discoverUser.introduction()
        
        
        if
            let discoverUserID = discoverUser.objectId,
            let masterList = discoverUser.masterList() {
            
            if !masterList.isEmpty {
                let newMasterList = masterList.map { FormulaMaster(value:[$0, discoverUserID]) }
                newUser.masterList.append(objectsIn: newMasterList)
                realm.add(newMasterList)
            }
            
        }
        
        realm.add(newUser)
        
        return newUser
    }
    
}

func formulasCountWith(_ uploadMode: UploadFormulaMode, category: Category, type: Type, inRealm realm: Realm) -> Int{
    let predicate = NSPredicate(format: "typeString = %@", type.rawValue)
    return formulasWith(uploadMode, category: category, inRealm: realm).filter(predicate).count
}

func formulaWith(objectID: String , inRealm realm: Realm) -> Formula? {
    let predicate = NSPredicate(format: "localObjectID = %@", objectID)
    return realm.objects(Formula.self).filter(predicate).first
}

func formulasWith(_ uploadMode: UploadFormulaMode, category: Category, type: Type, inRealm realm: Realm) -> Results<Formula>{
    let predicate = NSPredicate(format: "typeString = %@", type.rawValue)
    return formulasWith(uploadMode, category: category, inRealm: realm).filter(predicate)
}

func formulasWith(_ uploadMode: UploadFormulaMode, category: Category, inRealm realm: Realm) -> Results<Formula> {
    
    switch uploadMode {
        
    case .my:
        
        guard
            let userID = AVUser.current()?.objectId,
            let currentUser = userWithUserID(userID: userID, inRealm: realm) else { fatalError() }
        let predicate = NSPredicate(format: "creator = %@", currentUser)
        let predicate2 = NSPredicate(format: "categoryString == %@", category.rawValue)
        let result =  realm.objects(Formula.self).filter(predicate).filter(predicate2)
        return result
            
    case .library:
        
        let predicate = NSPredicate(format: "isLibrary == true")
        let predicate2 = NSPredicate(format: "categoryString == %@", category.rawValue)
        return realm.objects(Formula.self).filter(predicate).filter(predicate2)
    }
    
}

// Message

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
        
        let predicate = NSPredicate(format: "isLibrary == %@", true as Bool as CVarArg)
        let formulas = realm.objects(Formula.self).filter(predicate)
        
//        formulas.forEach {
        
           // $0.contentsString.forEach {_ in
//                realm.delete($0)
                
            //}
//        }
    }
    
}

public func deleteMyFormulasRContentAtRealm() {
    
    guard let realm = try? Realm() else {
        return
    }
    
    try? realm.write {
        
        let predicate = NSPredicate(format: "isLibrary == %@", false as Bool as CVarArg)
        let formulas = realm.objects(Formula.self).filter(predicate)
        
//        formulas.forEach {
            
           // $0.contentsString.forEach {_ in
//                realm.delete($0)
            //}
//        }
    }
}


/**
 After loaded formulas from LeanCloud, or user creat new Formula,
 update categoryMenusList
 
 - parameter categorys:    new categorys
 - parameter mode:         which userinterface : My or Library
 - parameter isNewFormula: its user creat new formula or not
 */

//public func saveCategoryMenusAtRealm(categorys: [Category], mode: UploadFormulaMode?, isNewFromula: Bool = false) {
//    
//    let realm = try! Realm()
//    
//    if !isNewFromula {
//        
//        try! realm.write {
//            
//            if let mode = mode {
//                
//                let predicate = NSPredicate(format: "mode == %@", mode.rawValue)
//                realm.delete(realm.objects(RCategory.self).filter(predicate))
//                
//                printLog("\(mode.rawValue) -> " + "重新从服务器获取公式后, 删除 Realm 中的所有 CategoryMenuList")
//                
//                // if Library categorys have changed, 必须将之前选中的公式类别更改为默认的三阶, 不然可能之前存储的选中类别已不存在.
//                UserDefaults.setSelected(category: .x3x3, mode: .library)
//                
//                var result = [RCategory]()
//                categorys.forEach {
//                    category in
//                    let r = category.convertToRCategory()
//                    r.mode = mode.rawValue
//                    result.append(r)
//                }
//                
//                realm.add(result)
//                
//                printLog("\(mode.rawValue) -> " + "新的 CategoryMenuList 写入 Realm")
//            }
//            
//        }
//        
//    } else {
//        
//         // if creat new Formula,  categorys are only have one object
//        let rNew = categorys.first!.convertToRCategory()
//        
//        let predicate = NSPredicate(format: "mode == %@", UploadFormulaMode.my.rawValue)
//        let predicate2 = NSPredicate(format: "categoryString == %@", rNew.categoryString)
//        
//        if realm.objects(RCategory.self).filter(predicate).filter(predicate2).isEmpty {
//            
//            try! realm.write {
//                
//                rNew.mode = UploadFormulaMode.my.rawValue
//                realm.add(rNew)
//            }
//            
//             printLog("\(UploadFormulaMode.my.rawValue) -> " + "CategoryMenuList 添加新类别成功")
//            
//        } else {
//           
//            printLog("\(UploadFormulaMode.my.rawValue) -> " + "此类别已经在数据库中了")
//            
//        }
//    }
//    
//}

/**
 Get formula's category from Realm
 
 - parameter mode: Which userinsterface need this
 
 - returns: [Category]
 */

//public func getCategoryMenusAtRealm(mode: UploadFormulaMode) -> [Category] {
//    
//    let realm = try! Realm()
//    let predicate = NSPredicate(format: "mode == %@", mode.rawValue)
//    return realm.objects(RCategory.self).filter(predicate).map { $0.convertToCategory() }.sorted { $0.sortIndex < $1.sortIndex }
//    
//}

/**
 After get Formuls from LeanCloud or User creat new Formula at local
 Update Data
 
 - parameter formulas:          [Formula] from LeanCloud
 - parameter mode:              My or Library
 - parameter isCreatNewFormula: its user creat new formula at local or note
 */

//public func saveUploadFormulasAtRealm(formulas: [Formula], mode: UploadFormulaMode?, isCreatNewFormula: Bool = false) {
//    
//    let realm = try! Realm()
//    
//    try! realm.write {
//        
//        realm.add(formulas.map { $0.convertRFormulaModel()}, update: true)
//    }
//    
//    /// get new category menu list
//    var categorys = Set<Category>()
//    
//    formulas.forEach {
//        if !categorys.contains($0.category) {
//            categorys.insert($0.category)
//        }
//    }
//    
//    saveCategoryMenusAtRealm(categorys: Array(categorys), mode: mode, isNewFromula: isCreatNewFormula)
//}

/**
 get formuls from Realm.
 
 - parameter mode:     .My or .Library
 - parameter category: formula's categoty, etc: .x3x3 .x5x5
 
 - returns: Change the RFormula to Formula's Objects
 */

 func getFormulsFormRealmWithMode(mode: UploadFormulaMode, category: Category) -> Results<Formula> {
    
    let realm = try! Realm()
    
    switch mode {
        
    case .my:
        
        
        let id = AVUser.current()!.objectId!
        let predicate = NSPredicate(format: "creatUserID = %@", id)
        let predicate2 = NSPredicate(format: "categoryString == %@", category.rawValue)
        let result =  realm.objects(Formula.self).filter(predicate).filter(predicate2)
        return result
        
        
    case .library:
        
        let predicate = NSPredicate(format: "isLibraryFormulas == true")
        let predicate2 = NSPredicate(format: "categoryString == %@", category.rawValue)
        return realm.objects(Formula.self).filter(predicate).filter(predicate2)
    }
}


//
//extension Category {
//    
//    func convertToRCategory() -> RCategory { switch self {
//        default:
//            let r = RCategory()
//            r.categoryString = self.rawValue
//            return r
//        }
//    }
//}


//extension FormulaContent {
//    
//    func convertRContent() -> RContent {
//        
//        let content = RContent()
//        
//        if let text = text {
//            content.text = text
//        }
//        
//        switch rotation {
//        case .BL(let rotation, _):
//            content.rotation = rotation
//        case .FL(let rotation, _):
//            content.rotation = rotation
//        case .FR(let rotation, _):
//            content.rotation = rotation
//        case .BR(let rotation, _):
//            content.rotation = rotation
//        }
//        return content
//    }
//}

//class RCategory: Object {
//    
//    dynamic var categoryString = ""
//    dynamic var mode = ""
//    
//    func convertToCategory() -> Category {
//        return Category(rawValue: categoryString)!
//    }
//}

//class RContent: Object {
//    
//    dynamic var text = ""
//    dynamic var rotation = ""
//    dynamic var cellHeight = 0
//    
//    //    let owners = LinkingObjects(fromType: RFormula.self, property: "contentsString")
//    
//    func convertToFormulaContent() -> FormulaContent {
//        return FormulaContent(text: text, rotation: rotation)
//    }
//}

//extension AVUser {
//    
//    func converRUserModel() -> RUser {
//        let rUser = RUser()
//        rUser.avatarImageUrl = self.getUserAvatarImageUrl()
//        rUser.userID = self.objectId!
//        rUser.nickName = self.getUserNickName()
//        return rUser
//    }
//}

public enum UserFriendState: Int {
    case Stranger       = 0   // 陌生人
    case IssuedRequest  = 1   // 已对其发出好友请求
    case Normal         = 2   // 正常状态的朋友
    case Blocked        = 3   // 被屏蔽
    case Me             = 4   // 自己
    case Yep            = 5   // Yep官方账号
}

//class RUser: Object {
//    
//    dynamic var userID: String = ""
//    dynamic var nickName: String?
//    dynamic var userName: String = ""
//    dynamic var avatarImageUrl: String?
//    
//    dynamic var introduction: String = ""
//    
//    public override static func indexedProperties() -> [String] {
//        return ["userID"]
//    }
//    
//    let messages = LinkingObjects(fromType: Message.self, property: "creatUser")
//    let conversations = LinkingObjects(fromType: Conversation.self, property: "withFriend")
//    
//    var conversation: Conversation? {
//        return conversations.first
//    }
//    
//    public let ownedGroups = LinkingObjects(fromType: Group.self, property: "owner")
//    public let belongsToGroups = LinkingObjects(fromType: Group.self, property: "members")
////    public let createdFeeds = LinkingObjects(fromType: Feed.self, property: "creator")
//    
//    dynamic var leanCloudObjectID: String = ""
//    
//    func convertToAVUser() -> AVUser {
//        
//        let user = AVUser()
//        user.set(userID: userID)
//        
//        if let nickName = nickName {
//            user.set(nikeName: nickName)
//        }
//        
//        if let url = avatarImageUrl {
//            user.setUserAvatar(imageUrl: url)
//        }
//        
//        
//        user.username = userName
//        
//        return user
//    }
//    
//    func isMe() -> Bool {
//        
//        guard let currentUser = AVUser.current(), let userID = currentUser.objectId else {
//            return false
//        }
//        
//        return userID == self.userID
//        
//    }
//}
















