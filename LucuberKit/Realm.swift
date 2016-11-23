//
//  Realm.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/23.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud

public func currentUser(in realm: Realm) -> RUser? {
    guard let avuserID = AVUser.current()?.objectId else { return nil }
    return userWith(avuserID, inRealm: realm)
}

public func masterWith(_ localObjectID: String, inRealm realm: Realm) -> FormulaMaster? {
    let predicate = NSPredicate(format: "localObjectID = %@", localObjectID)
    return realm.objects(FormulaMaster.self).filter(predicate).first
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

public func categorysWith(_ uploadMode: UploadFormulaMode, inRealm realm: Realm) -> Results<RCategory>? {
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
    let oldMasterList = currentUser.masterList
    
    if let master = masterWith(localObjectID, inRealm: realm) {
        if oldMasterList.contains(master) {
            let index = oldMasterList.index(of: master)!
            currentUser.masterList.remove(objectAtIndex: index)
            
            realm.delete(master)
        }
    }
}

public func appendMaster(with formula: Formula, inRealm realm: Realm) {
    
    guard let currentUser = currentUser(in: realm) else {
        return
    }
    
    let localObjectID = formula.localObjectID
    
    if let _ = masterWith(localObjectID, inRealm: realm) {
        return
    }
    
    let newMaster = FormulaMaster(value: [localObjectID, currentUser.lcObjcetID])
    currentUser.masterList.append(newMaster)
    
    realm.add(newMaster)
    
}

public func appendRCategory(with formula: Formula, uploadMode: UploadFormulaMode, inRealm realm: Realm) {
    
    let categorys = categorysWith(uploadMode, inRealm: realm)
    
    if let categorys = categorys {
        let categoryTexts = categorys.map { $0.name }
        if !categoryTexts.contains(formula.category.rawValue) {
            let newRCategory = RCategory()
            newRCategory.uploadMode = uploadMode.rawValue
            newRCategory.name = formula.category.rawValue
            realm.add(newRCategory)
        }
        
    } else {
        
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
                    
                   printLog("数据相等, 不需要更新")
                    
                } else {
                    
                    creator.masterList.removeAll()
                    realm.delete(oldFormulaMasterList)
                    
                    let newMasterList = newMasterList.map { FormulaMaster(value:[$0, discoverUserID]) }
                    creator.masterList.append(objectsIn: newMasterList)
                    realm.add(newMasterList)
                    
                    printLog("数据不相等, 需要更新")
                    
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









