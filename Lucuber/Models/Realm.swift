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
        let currentUserLcObjectID = currentUser.objectId else {
        return nil
    }
    
    if let user = userWith(currentUserLcObjectID, inRealm: realm) {
        return user
    } else {
        let newUser = RUser()
        newUser.localObjectID = currentUser.localObjectID() ?? ""
        newUser.lcObjcetID = currentUserLcObjectID
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

public func getOrCreatRUserWith(_ avUser: AVUser?, inRealm realm: Realm) -> RUser? {
    
    guard let avUser = avUser else { return nil }
    
    var user = userWith(avUser.objectId!, inRealm: realm)
    
    if user == nil {
        let newUser = RUser()
        newUser.lcObjcetID = avUser.objectId!
        
        // TODO: - 标记陌生人
        realm.add(newUser)
        user = newUser
    }
    
    if let user = user {
        
        user.localObjectID = avUser.localObjectID() ?? ""
        user.avatorImageURL = avUser.avatorImageURL()
        user.nickname = avUser.nickname() ?? ""
        user.username = avUser.username ?? ""
        user.introduction = avUser.introduction()
        
        let oldMasterList: [String] = user.masterList.map({ $0.formulaID })
        
        if let newMasterList = avUser.masterList() {
            
            if oldMasterList != newMasterList {
                
                realm.delete(user.masterList)
                
                let newRMasterList = newMasterList.map({ FormulaMaster(value: [$0, user]) })
                
                realm.add(newRMasterList)
            }
        }
    }
    return user
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
    
    let predicate = NSPredicate(format: "typeString = %@", type.rawValue)
    
    return formulasWith(uploadMode, category: category, inRealm: realm).filter(predicate)
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

public func imageMetaOfMessage(message: Message) -> (width: CGFloat, height: CGFloat)? {
    
    guard !message.isInvalidated else { return nil }
    
    if let mediaMetaData = message.mediaMetaData {
        
        if !mediaMetaData.data.isEmpty {
            
            guard let result = try? JSONSerialization.jsonObject(with: mediaMetaData.data , options: JSONSerialization.ReadingOptions.init(rawValue: 0)) else {
                return nil
            }
            if let metaDataInfo = result as? [String: Any] {
                
                if let
                    width = metaDataInfo[Config.MetaData.imageWidth] as? CGFloat,
                    let height = metaDataInfo[Config.MetaData.imageHeight] as? CGFloat {
                    return (width, height)
                }
            }
        }
    }

    return nil
}

public func blurThumbnailImageOfMessage(_ message: Message) -> UIImage? {

    guard !message.isInvalidated else {
        return nil
    }

    if let metaData = message.mediaMetaData {
        
        if !metaData.data.isEmpty {
            
            guard let result = try? JSONSerialization.jsonObject(with: metaData.data, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) else {
                return nil
            }
            
            if let metaDataInfo = result as? [String: Any] {
                if let imageString = metaDataInfo[Config.MetaData.blurredThumbnailString] as? String {
                    if let data = Data(base64Encoded: imageString) {
                        return UIImage(data: data)
                    }
                }
            }
        }
        
    }
    return nil
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
    
    let predicate = NSPredicate(format: "localObjectID = %@", messageID)
    let message = realm.objects(Message.self).filter(predicate)
    return message.first
}

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

// MARK: - Feed

public func feedWith(_ lcObjcetID: String, inRealm realm: Realm) -> Feed? {
    let predicate = NSPredicate(format: "lcObjectID = %@", lcObjcetID)
    return realm.objects(Feed.self).filter(predicate).first
}

// MARK: - Group
public func groupWith(_ groupID: String, inRealm realm: Realm) -> Group? {
    
    let predicate = NSPredicate(format: "groupID = %@" , groupID)
    
    return realm.objects(Group.self).filter(predicate).first
}

// MARK: - Conversation

public func titleName(of conversation: Conversation) -> String? {
    
    guard !conversation.isInvalidated else {
        return nil
    }
    
    if conversation.type == ConversationType.oneToOne.rawValue {
        if let withFriend = conversation.withFriend {
            return withFriend.nickname
        }
    }
    
    if conversation.type == ConversationType.group.rawValue {
        if let withGroup = conversation.withGroup {
            return withGroup.groupName
        }
    }
    return nil
}
























