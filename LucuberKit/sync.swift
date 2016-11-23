//
//  sync.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/23.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud

public enum UploadFormulaMode: String {
    case my = "My"
    case library = "Library"
}

public func syncPreferences() {
    
    let query = AVQuery(className: "DiscoverPreferences")
    
    
    query.getFirstObjectInBackground { (references, error) in
        
        if error != nil {
            printLog("获取用户偏好设置失败. 无法正确判断是否需要更新公式数据")
            return
        }
        
        if let references = references as? DiscoverPreferences {
            
            let version = references.version
            
            printLog(version)
        }
    }
}



public func syncFormula(with uploadMode: UploadFormulaMode, categoty: Category, completion: (([Formula]) -> Void)?, failureHandler:((Error?) -> Void)?) {
    
    
    
    let query = AVQuery(className: DiscoverFormula.parseClassName())
    query.includeKey("creator")
    query.includeKey("contents")
    query.limit = 20
    
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
            
            failureHandler?(error)
            
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
            
            newDiscoverFormulas.forEach {
                
                convertDiscoverFormulaToFormula(discoverFormula: $0, uploadMode: uploadMode, inRealm: realm, completion: { formulas in
                    //                        printLog(formulas.contents)
                    
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
    var formula = formulaWith(discoverFormula.localObjectID, inRealm: realm)
    
    let deleted = discoverFormula.deletedByCreator
    
    if deleted {
        if
            let discoverFormulaCreatorID = discoverFormula.creator?.objectId,
            let myID = AVUser.current()?.objectId {
            
            if discoverFormulaCreatorID == myID {
                
                if let formula = formula {
                    realm.delete(formula)
                }
            }
        }
    }
    
    if formula == nil {
        
        let newFormula = Formula()
        newFormula.lcObjectID = discoverFormula.objectId!
        newFormula.localObjectID = discoverFormula.localObjectID
        realm.add(newFormula)
        formula = newFormula
        
    }
    
    if let formula = formula {
        
        if  let discoverFormulaCreator = discoverFormula.creator,
            let creatorID = discoverFormula.creator?.objectId {
            
            var creator = userWith(creatorID, inRealm: realm)
            
            if creator == nil {
                
                let newUser = RUser()
                
                newUser.localObjectID = discoverFormulaCreator.localObjectID() ?? ""
                newUser.lcObjcetID = discoverFormulaCreator.objectId!
                newUser.avatorImageURL = discoverFormulaCreator.avatorImageURL()
                newUser.username = discoverFormulaCreator.username!
                newUser.nickname = discoverFormulaCreator.nickname()
                newUser.introduction = discoverFormulaCreator.introduction()
                
                if let masterList = discoverFormulaCreator.masterList() {
                    
                    if !masterList.isEmpty {
                        let newMasterList = masterList.map { FormulaMaster(value:[$0]) }
                        newUser.masterList.append(objectsIn: newMasterList)
                        realm.add(newMasterList)
                    }
                }
                
                realm.add(newUser)
                creator = newUser
                
            }
            
            if let creator = creator {
                formula.creator = creator
            }
        }
        
        formula.isLibrary = discoverFormula.isLibrary
        formula.name = discoverFormula.name
        formula.imageName = discoverFormula.imageName
        formula.imageURL = discoverFormula.imageURL
        formula.categoryString = discoverFormula.category
        formula.typeString = discoverFormula.type
        formula.updateUnixTime = discoverFormula.updatedAt!.timeIntervalSince1970
        
        // 如果 discoverFormula 有 imageURL , 用户自己上传了 Image
        if discoverFormula.imageURL != "" {
            
            formula.imageURL = discoverFormula.imageURL
        }
        
        discoverFormula.contents.forEach {
            
            var content = contentWith($0.localObjectID, inRealm: realm)
            
            if $0.deletedByCreator {
                
                if
                    let currentUserID = AVUser.current()?.objectId ,
                    let discoverContentCreaterID = $0.creator.objectId {
                    
                    if currentUserID == discoverContentCreaterID {
                        
                        if let content = content {
                            realm.delete(content)
                        }
                    }
                }
                
                if discoverFormula.isLibrary {
                    if let content = content {
                        realm.delete(content)
                    }
                }
            }
            
            if content == nil {
                
                let newContent = Content()
                newContent.localObjectID = $0.localObjectID
                newContent.lcObjectID = $0.objectId!
                realm.add(newContent)
                content = newContent
            }
            
            if let content = content {
                
                content.creator = formula.creator
                content.atFormula = formula
                content.atFomurlaLocalObjectID = $0.atFormulaLocalObjectID
                
                content.rotation = $0.rotation
                content.text = $0.text
                content.indicatorImageName = $0.indicatorImageName
                
            }
        }
        
        // 目前只考虑到保存, 未考虑到删除
        
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
        
        
        completion?(formula)
        
    }
    
}
