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

//public let realmQueue = dispatch_queue_create("com.Lucuber.realmQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0))

let realmQueue = DispatchQueue(label: "com.Lucuber.realmQueue", qos: DispatchQoS.utility, attributes: DispatchQueue.Attributes.concurrent)

public func realmConfig() -> Realm.Configuration {
    
    var config = Realm.Configuration()
    config.schemaVersion = 1
    config.migrationBlock = { migration, oldSchemaVersion in
    }
    
    return config
}

// MARK: - User

public func creatMeInRealm() -> RUser? {
    
    guard
        let realm = try? Realm() ,
        let currentUser = AVUser.current(),
        let currentUserlcObjectID = currentUser.objectId else {
        return nil
    }
    
    if let user = userWith(currentUserlcObjectID, inRealm: realm) {
        return user
        
    } else {
        let newUser = RUser()
        newUser.localObjectID = currentUser.localObjectID() ?? ""
        newUser.lcObjcetID = currentUserlcObjectID
        newUser.avatorImageURL = currentUser.avatorImageURL() ?? ""
        newUser.nickname = currentUser.nickname() ?? ""
        newUser.username = currentUser.username ?? ""
        newUser.introduction = currentUser.introduction() ?? ""
        
        try? realm.write {
            realm.add(newUser)
        }
        return newUser
    }
    
}

public func avatarWith(_ urlString: String, inRealm realm: Realm) -> Avatar? {
    let predicate = NSPredicate(format: "avatarUrlString = %@", urlString)
    return realm.objects(Avatar.self).filter(predicate).first
}


public func userWith(_ userID: String, inRealm realm: Realm) -> RUser? {
    let predicate = NSPredicate(format: "lcObjcetID = %@", userID)
    return realm.objects(RUser.self).filter(predicate).first
}

public func currentUser(in realm: Realm) -> RUser? {
    guard let avUser = AVUser.current(), let avUserObjectID = avUser.objectId else { return nil }
    return userWith(avUserObjectID, inRealm: realm)
}


public func masterWith(_ localObjectID: String, atRUser user: RUser, inRealm realm: Realm) -> FormulaMaster? {
    let predicate = NSPredicate(format: "formulaID = %@", localObjectID)
    let predicate2 = NSPredicate(format: "atRUser = %@", user)
    return realm.objects(FormulaMaster.self).filter(predicate).filter(predicate2).first
}

public func mastersWith(_ rUser: RUser, inRealm realm: Realm) -> Results<FormulaMaster> {
    let predicate = NSPredicate(format: "atRUser = %@", rUser)
    return realm.objects(FormulaMaster.self).filter(predicate)
}


public func deleteMaster(with formula: Formula, inRealm realm: Realm) {
    guard let currentUser = currentUser(in: realm) else { return }
    
    let localObjectID = formula.localObjectID
    if let master = masterWith(localObjectID, atRUser: currentUser, inRealm: realm) {
        realm.delete(master)
    }
}

public func appendMaster(with formula: Formula, inRealm realm: Realm) {
    guard let currentUser = currentUser(in: realm) else { return }
    
    let localObjectID = formula.localObjectID
    if let _ = masterWith(localObjectID, atRUser: currentUser, inRealm: realm) { return }
    let newMaster = FormulaMaster(value: [localObjectID, currentUser])
    realm.add(newMaster)
    
}

//public func updateMasterList(with currentUser: RUser, discoverUser: AVUser, inRealm realm: Realm) {
//    if let newMasterList = discoverUser.masterList() {
//        let oldMasterList = mastersWith(currentUser, inRealm: realm)
//        
//        try? realm.write { realm.delete(oldMasterList) }
//        
//        let masterList = newMasterList.map { FormulaMaster(value:[$0, currentUser]) }
//        try? realm.write { realm.add(masterList) }
//    }
//}


// MARK: - Formula

public func deleteByCreatorFormula(with currentUser: RUser, inRealm realm: Realm) -> Results<Formula> {
    
    let predicate = NSPredicate(format: "creator = %@", currentUser)
    let predicate2 = NSPredicate(format: "deletedByCreator = %@", true as CVarArg)
    
    return realm.objects(Formula.self).filter(predicate).filter(predicate2)
}

public func deleteByCreatorRContent(with currentUser: RUser, inRealm realm: Realm) -> Results<Content> {
    let predicate = NSPredicate(format: "creator = %@", currentUser)
    let predicate2 = NSPredicate(format: "deleteByCreator = %@", true as CVarArg)
    
    return realm.objects(Content.self).filter(predicate).filter(predicate2)
}

public func unPushedFormula(with currentUser: RUser, inRealm realm: Realm) -> Results<Formula> {
    
    let predicate = NSPredicate(format: "creator = %@", currentUser)
    let predicate2 = NSPredicate(format: "isPushed = %@", false as CVarArg)
    let predicate3 = NSPredicate(format: "deletedByCreator = %@", false as CVarArg)
    
    return realm.objects(Formula.self).filter(predicate).filter(predicate2).filter(predicate3)
}

public func categorysWith(_ uploadMode: UploadFormulaMode, inRealm realm: Realm) -> Results<RCategory> {
    
    let predicate = NSPredicate(format: "uploadMode = %@", uploadMode.rawValue)
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


func formulasCountWith(_ uploadMode: UploadFormulaMode, category: Category, inRealm realm: Realm) -> Int {
    return formulasWith(uploadMode, category: category, inRealm: realm).count
}

func formulaWith(objectID: String , inRealm realm: Realm) -> Formula? {
    let predicate = NSPredicate(format: "localObjectID = %@", objectID)
    return realm.objects(Formula.self).filter(predicate).first
}

func formulaCollectionWith(objectID: String, inRealm realm: Realm) -> Results<Formula> {
    let predicate = NSPredicate(format: "localObjectID = %@", objectID)
    return realm.objects(Formula.self).filter(predicate)
}

func formulasWith(_ uploadMode: UploadFormulaMode, category: Category, type: Type, inRealm realm: Realm) -> Results<Formula>{
    
//    var predicate = NSPredicate(format: "categoryString = %@ AND typeString = %@", category.rawValue, type.rawValue)
//    
//    if case .all = category {
//         predicate = NSPredicate(format: "typeString = %@", type.rawValue)
//    }
//    
//    if case .unKnow = type {
////        return realm.objects(Formula.self).filter("")
//    }
//
//
//    switch uploadMode {
//    case .my:
//        
//        guard let currentUser = currentUser(in: realm) else { fatalError() }
//        
//        let myPredicate = NSPredicate(format: "creator = %@", currentUser)
//        let myPredicate2 = NSPredicate(format: "deletedByCreator == %@", false as CVarArg)
//        return realm.objects(Formula.self).filter(myPredicate).filter(predicate).filter(myPredicate2).sorted(byProperty: "createdUnixTime", ascending: false)
//        
//    case .library:
//        
//        let libraryPredicate = NSPredicate(format: "isLibrary == true")
//        return realm.objects(Formula.self).filter(libraryPredicate).filter(predicate)
//        
//    }
    let predicate = NSPredicate(format: "typeString = %@", type.rawValue)
    
    return formulasWith(uploadMode, category: category, inRealm: realm).filter(predicate)
    
//    return formulasWith(uploadMode, category: category, inRealm: realm).filter(predicate)
}

func formulasWith(_ uploadMode: UploadFormulaMode, category: Category, inRealm realm: Realm) -> Results<Formula> {
    
    switch uploadMode {
        
    case .my:
        
        guard let currentUser = currentUser(in: realm) else { fatalError() }
        let predicate = NSPredicate(format: "creator = %@", currentUser)
        let predicate2 = NSPredicate(format: "categoryString == %@", category.rawValue)
        let predicate3 = NSPredicate(format: "deletedByCreator == %@", false as CVarArg)
        
        if case .all = category {
            return realm.objects(Formula.self).filter(predicate).filter(predicate3).sorted(byProperty: "createdUnixTime", ascending: false)
            
        } else {
            return realm.objects(Formula.self).filter(predicate).filter(predicate2).filter(predicate3).sorted(byProperty: "createdUnixTime", ascending: false)
        }
            
    case .library:
        
        let predicate = NSPredicate(format: "isLibrary == true")
        let predicate2 = NSPredicate(format: "categoryString == %@", category.rawValue)
        
        if case .all = category {
            return realm.objects(Formula.self).filter(predicate).sorted(byProperty: "createdUnixTime", ascending: true)
            
        } else {
            return realm.objects(Formula.self).filter(predicate).filter(predicate2).sorted(byProperty: "createdUnixTime", ascending: true)
        }
    }
    
}

public func createOrUpdateRCategory(with formula: Formula, uploadMode: UploadFormulaMode, inRealm realm: Realm) {
    let categorys = categorysWith(uploadMode, inRealm: realm)
    
    // TODO: /
    let categoryTexts = categorys.map { $0.name }
    if !categoryTexts.contains(formula.categoryString) {
        
        let newRCategory = RCategory(value: [formula.categoryString, uploadMode.rawValue])
        realm.add(newRCategory)
        
    } 
    
}

public func deleteEmptyRCategory(with uploadMode: UploadFormulaMode, inRealm realm: Realm) {
    
    let rCategorys = categorysWith(uploadMode, inRealm: realm)
    
    for rCategory in rCategorys {
        
        if let category = Category(rawValue: rCategory.name) {
            
            let formulasCount = formulasCountWith(uploadMode, category: category, inRealm: realm)
            
            if formulasCount <= 0 {
                
                try? realm.write {
                    realm.delete(rCategory)
                }
            }
        }
    }
}

// MARK: - Message


public func groupWith(_ groupID: String, inRealm realm: Realm) -> Group? {
    
    let predicate = NSPredicate(format: "groupID = %@" , groupID)
    return realm.objects(Group.self).filter(predicate).first
}

public func messagesWith(_ conversation: Conversation, inRealm realm: Realm) -> Results<Message> {
    
    let predicate = NSPredicate(format: "conversation = %@", conversation)
    let messages = realm.objects(Message.self).filter(predicate).sorted(byProperty: "createdUnixTime", ascending: true)
    return messages
    
}

public func messageWith(_ messageID: String, inRealm realm: Realm) -> Message? {
    
    if messageID.isEmpty {
        return nil
    }
    
    let predicate = NSPredicate(format: "messageID = %@", messageID)
    let message = realm.objects(Message.self).filter(predicate)
    return message.first
}

/// 在传入的 message 后面创建 DataSectionMessage
public func tryCreatDateSectionMessage(with conversation: Conversation, beforeMessage message: Message,  inRealm realm: Realm, completion: ((Message) -> Void)? ) {
    
    let messages = messagesWith(conversation, inRealm: realm)
    
    if messages.count > 1 {
        
        guard let index = messages.index(of: message) else {
            return
        }
        
        if let prevMessage = messages[safe: (index - 1)] {
            
            // TODO: - 两个消息时间相差多少秒, 创建 DataSection, 10 为测试值, 正常 180 秒
            if message.createdUnixTime - prevMessage.createdUnixTime > 10 {
                
                let sectionDateMessageCreatedUnixTime = message.createdUnixTime - 0.00005
                let sectionDateMessageID = "sectionDate-\(sectionDateMessageCreatedUnixTime)"
                
                if let _ = messageWith(sectionDateMessageID, inRealm: realm) {
                    
                } else {
                    
                    let newSectionDateMessage = Message()
                    newSectionDateMessage.localObjectID = sectionDateMessageID
                    
                    newSectionDateMessage.conversation = conversation
                    newSectionDateMessage.mediaType = MessageMediaType.sectionDate.rawValue
                    
                    newSectionDateMessage.createdUnixTime = sectionDateMessageCreatedUnixTime
                    newSectionDateMessage.arrivalUnixTime = sectionDateMessageCreatedUnixTime
                    
                    completion?(newSectionDateMessage)
                }
                
            }
        }
    }
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
















