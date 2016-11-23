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

public func formulasCountWith(_ category: Category, uploadMode: UploadFormulaMode, inRealm realm: Realm) -> Int {
    let predicate = NSPredicate(format: "categoryString = %@", category.rawValue)
    
    var predicate2 = NSPredicate()
    switch uploadMode {
    case .library:
        predicate2 = NSPredicate(format: "isLibrary = %@", true as CVarArg)
    case .my:
        predicate2 = NSPredicate(format: "isLibrary= %@", false as CVarArg)
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
    let predicate = NSPredicate(format: "userID = %@", userID)
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
    
    let newMaster = FormulaMaster(value: [localObjectID])
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
