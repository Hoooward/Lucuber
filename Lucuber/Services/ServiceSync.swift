//
//  ServiceSync.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud
import PKHUD

public enum UploadFormulaMode: String {
    case my = "My"
    case library = "Library"
}


public func updateLibraryDate(failureHandeler: @escaping FailureHandler, completion: (() -> Void)?) {
    
    HUD.show(.label("更新公式库..."))
    
    fetchDiscoverFormula(with: UploadFormulaMode.library, categoty: nil, failureHandler: { reason, errorMessage in
        
        HUD.flash(.label("更新失败，似乎已断开与互联网的连接。"), delay: 1.5)
        failureHandeler(reason, errorMessage)
        
    }, completion: { _ in
        
        HUD.flash(.label("更新成功"), delay: 1.5)
        completion?()
        
    })
}

public func fetchPreferences(failureHandler: @escaping FailureHandler, completion:@escaping ((String) -> Void)){
    
    let query = AVQuery(className: DiscoverPreferences.parseClassName())
    query.getFirstObjectInBackground { (references, error) in
        
        if error != nil { failureHandler(Reason.network(error), "同步数据库版本号失败") }
        
        if let references = references as? DiscoverPreferences {
            completion(references.version)
        }
    }
}

public func fetchDiscoverFormula(with uploadMode: UploadFormulaMode, categoty: Category?, failureHandler: @escaping FailureHandler, completion: (([Formula]) -> Void)?) {
    
    
    let query = AVQuery(className: DiscoverFormula.parseClassName())
    query.includeKey("creator")
    query.includeKey("contents")
    query.limit = 1000
    
    switch uploadMode {
        
    case .my:
        
        guard let currentUser = AVUser.current() else {
            printLog("当前没有登录用户, 获取我的公式失败")
            return
        }
        query.whereKey("creator", equalTo: currentUser)
        query.addAscendingOrder("name")
        
    case .library:
        query.whereKey("isLibrary", equalTo: NSNumber(booleanLiteral: true))
        query.addAscendingOrder("serialNumber")
    }
    
    printLog( "开始从LeanCloud中获取我的公式")
    query.findObjectsInBackground {
        newDiscoverFormulas, error in
        
        if error != nil {
            
            failureHandler(Reason.network(error), "syncFormula 请求失败")
            
        }
        
        if let newDiscoverFormulas = newDiscoverFormulas as? [DiscoverFormula] {
            
            guard let realm = try? Realm() else {
                return
            }
            
            realm.beginWrite()
            if !newDiscoverFormulas.isEmpty {
                printLog("共下载到\(newDiscoverFormulas.count)个公式 " )
                printLog("开始将 DiscoverFormula 转换成 Formula 并存入本地 Realm")
            }
            
            var newFormulas: [Formula] = []
            
            for discoverFormula in newDiscoverFormulas {
                
                convertDiscoverFormulaToFormula(discoverFormula: discoverFormula, uploadMode: uploadMode, inRealm: realm, completion: { formulas in
                    
                    newFormulas.append(formulas)
                })
            }
            
            
            if !newDiscoverFormulas.isEmpty { printLog("DiscoverFormula 转换 Formula 完成") }
            
            try? realm.commitWrite()
            
            completion?(newFormulas)
            
        }
        
    }
    
}


public func convertDiscoverFormulaToFormula(discoverFormula: DiscoverFormula, uploadMode: UploadFormulaMode, inRealm realm: Realm, completion: ((Formula) -> Void)?) {
    
    // 尝试从数据库中查找是否已经有存在的 Formula
    var formula = formulaWith(objectID: discoverFormula.localObjectID, inRealm: realm)
    
    let deleted = discoverFormula.deletedByCreator
    
    if deleted {
        if
            let discoverFormulaCreatorID = discoverFormula.creator?.objectId,
            let myID = AVUser.current()?.objectId {
            
            if discoverFormulaCreatorID == myID {
                
                if let formula = formula {
                    realm.delete(formula)
                }
                return
            }
            
        }
    }
    
    if formula == nil {
        
        let newFormula = Formula()
        newFormula.lcObjectID = discoverFormula.objectId!
        newFormula.localObjectID = discoverFormula.localObjectID
        newFormula.updateUnixTime = discoverFormula.updatedAt!.timeIntervalSince1970
        newFormula.isNewVersion = true
        realm.add(newFormula)
        formula = newFormula
        
    }
    
    if let formula = formula {
        
        if let discoverFormulaCreator = discoverFormula.creator {
            
            var user = userWith(discoverFormulaCreator.objectId!, inRealm: realm)
            
            if user == nil {
                let newUser = RUser()
                newUser.lcObjcetID = discoverFormulaCreator.objectId!
                
                realm.add(newUser)
                user = newUser
            }
            
            if let user = user {
                
                user.localObjectID = discoverFormulaCreator.localObjectID() ?? ""
                user.avatorImageURL = discoverFormulaCreator.avatorImageURL()
                user.nickname = discoverFormulaCreator.nickname() ?? ""
                user.username = discoverFormulaCreator.username ?? ""
                
                let oldMasterList: [String] = user.masterList.map({ $0.formulaID })
                
                if let newMasterList = discoverFormulaCreator.masterList() {
                    
                    if oldMasterList != newMasterList {
                       
                        realm.delete(user.masterList)
                        
                        let newRMasterList = newMasterList.map({ FormulaMaster(value: [$0, user]) })
                        
                        realm.add(newRMasterList)
                        
                    }
                }
                
                formula.creator = user
            }
        }
        
        formula.isPushed = true
        formula.isLibrary = discoverFormula.isLibrary
        formula.name = discoverFormula.name
        formula.imageName = discoverFormula.imageName
        formula.imageURL = discoverFormula.imageURL
        formula.categoryString = discoverFormula.category
        formula.typeString = discoverFormula.type
        formula.rating = discoverFormula.rating
        
        if formula.updateUnixTime != discoverFormula.updatedAt!.timeIntervalSince1970 {
            formula.isNewVersion = true
        }
        
        formula.updateUnixTime = discoverFormula.updatedAt!.timeIntervalSince1970
        formula.createdUnixTime = discoverFormula.createdAt!.timeIntervalSince1970
        
        // 如果 discoverFormula 有 imageURL , 用户自己上传了 Image
        
        formula.imageURL = discoverFormula.imageURL
        
        
        for discoverContent in discoverFormula.contents {
            
            var content = contentWith(discoverContent.localObjectID, inRealm: realm)
            
            if discoverContent.deletedByCreator {
                
//                if
//                    let currentUserID = AVUser.current()?.objectId ,
//                    let discoverContentCreaterID = discoverContent.creator.objectId {
//                    
//                    if currentUserID == discoverContentCreaterID {
//                        
//                        if let content = content {
//                            realm.delete(content)
//                        }
//                    }
//                }
//                
//                if discoverFormula.isLibrary {
//                    if let content = content {
//                        realm.delete(content)
//                        content = nil
//                    }
//                }
                
                if let content = content {
                    realm.delete(content)
                }
                
                continue
            }
            
            if content == nil {
                
                let newContent = Content()
                newContent.localObjectID = discoverContent.localObjectID
                newContent.lcObjectID = discoverContent.objectId!
                realm.add(newContent)
                content = newContent
            }
            
            if let content = content {
                
                content.creator = formula.creator
                content.atFormula = formula
                content.atFomurlaLocalObjectID = discoverContent.atFormulaLocalObjectID
                
                content.rotation = discoverContent.rotation
                content.text = discoverContent.text
                content.indicatorImageName = discoverContent.indicatorImageName
                
            }
            
        }
        
        createOrUpdateRCategory(with: formula, uploadMode: uploadMode, inRealm: realm)
        
        completion?(formula)
    }
    
}

internal func fetchDiscoverFeed( uploadingFeedMode: UploadFeedMode, lastFeedCreatDate: NSDate, completion: (([Feed]) -> Void)?, failureHandler: ((NSError) -> Void)? ) {
    
    let query = AVQuery(className: DiscoverFeed.parseClassName())
    
//    query.addDescendingOrder(AVQuery.DefaultKey.updatedTime.rawValue)
    query.limit = 20
    
    switch category {
        
    case .All:
        // Do Noting
        break
        
    case .Topic:
        // Do Noting
        break
        
    case .Formula:
        query.whereKey(Feed.Feedkey_category, equalTo: FeedCategory.Formula.rawValue)
        
    case .Record:
        query.whereKey(Feed.Feedkey_category, equalTo: FeedCategory.Record.rawValue)
        
    }
    
    switch uploadingFeedMode {
        
    case .top:
        // Do Noting
        break
        
    case .loadMore:
        query.whereKey(AVQuery.DefaultKey.creatTime.rawValue, lessThan: lastFeedCreatDate)
    }
    
    query.findObjectsInBackground { newFeeds, error in
        
        if error != nil {
            
            failureHandler?(error as! NSError)
            
        } else {
            
            if let newFeeds = newFeeds as? [Feed] {
                
                //                printLog("newFeeds.count = \(newFeeds.count)")
                completion?(newFeeds)
            }
        }
    }
    
}


//public func convertDiscoverMessageToMessage(discoverMessage: DiscoverMessage, messageAge: MessageAge, inRealm realm: Realm, completion: (([String]) -> Void)?) {
//    
//    // 暂时使用同一线程的 Realm, 因为 Message 的 lcObjcetID 来自远端, 所以可能需要使用一个独立的线程
//    
//    guard let messageID = discoverMessage.objectId else {
//        return
//    }
//    
//    var message = messageWith(messageID, inRealm: realm)
//    
//    let deleted = discoverMessage.deletedByCreator
//    
//    if deleted {
//        if
//            let discoverMessageCreatorID = discoverMessage.creator.objectId,
//            let currentUserID = AVUser.current()?.objectId {
//            
//            if discoverMessageCreatorID == currentUserID {
//                
//                if let message = message {
//                    realm.delete(message)
//                }
//            }
//            
//        }
//    }
//    
//    if message == nil {
//        
//        let newMessage = Message()
//        newMessage.lcObjectID = discoverMessage.objectId!
//        newMessage.localObjectID = discoverMessage.localObjectID
//        
//        newMessage.textContent = discoverMessage.textContent
//        newMessage.mediaTypeInt = discoverMessage.mediaTypeInt
//        
//        newMessage.sendStateInt = MessageSendState.read.rawValue
//        
//        newMessage.createdUnixTime = (discoverMessage.createdAt?.timeIntervalSince1970)!
//        
//        if case .new = messageAge {
//           
//            if let latestMessage = realm.objects(Message.self).sorted(byProperty: "createdUnixTime", ascending: true).last {
//                if newMessage.createdUnixTime < latestMessage.createdUnixTime {
//                    // 只考虑最近的消息，过了可能混乱的时机就不再考虑
//                    if abs(newMessage.createdUnixTime - latestMessage.createdUnixTime) < 60 {
//                        printLog("xbefore newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
//                        newMessage.createdUnixTime = latestMessage.createdUnixTime + 0.00005
//                        printLog("xadjust newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
//                    }
//                }
//            }
//        }
//        
//        realm.add(newMessage)
//        message = newMessage
//    }
//    
//    if let message = message {
//        
//        let sender = appendRUser(with: discoverMessage.creator, inRealm: realm)
//        
//        
//        message.creator = sender
//        message.recipientID = discoverMessage.recipientID
//        message.recipientType = discoverMessage.recipientType
//        
//        var senderFormGroup: Group? = nil
//        
//        if discoverMessage.recipientType == "group" {
//            
//            senderFormGroup = groupWith(discoverMessage.recipientID, inRealm: realm)
//            
//            if senderFormGroup == nil {
//                
//                let newGroup = Group()
//                newGroup.groupID = discoverMessage.recipientID
//                newGroup.incloudMe = true
//                
//                realm.add(newGroup)
//                
//                senderFormGroup = newGroup
//            }
//        }
//        
//        var conversation: Conversation?
//        
//        var conversationWithUser: RUser?
//        
//        if let senderFormGroup = senderFormGroup {
//            
//            conversation = senderFormGroup.conversation
//            
//        } else {
//           
//            
//        }
//        
//        
//    }
//}























