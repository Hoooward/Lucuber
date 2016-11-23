//
//  ViewController.swift
//  LucuberKit
//
//  Created by Tychooo on 16/11/22.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud

fileprivate let userNickNameKey = "userNickName"
fileprivate let userAvatarImageUrlKey = "userAvatarImageUrl"
fileprivate let userID = "userID"
fileprivate let needUpdateLibraryKey = "needUpdateLibrary"
fileprivate let masterFormulasIDListKey = "masterFormulasIDList"
fileprivate let needUpdateMasterListKey = "needUpdateMsterList"

func printLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
    
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)]:\(message)")
    #endif
}

public enum UploadFormulaMode: String {
    case my = "My"
    case library = "Library"
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        AVUser.loginAdministrator()
        syncPreferences()
        syncFormula(with: .library, categoty: .x3x3, completion: {
            
            newFormulas in
            
            test(formulas: newFormulas)
            
        }, failureHandler: nil)
        
    }

}

func appendMasterID (localObjectID: String, inRealm realm: Realm) {
    
    if let _ = formulaMaskerWith(localObjectID, inRealm: realm) {
        return
    }
    
    let newMaster = FormulaMaster(value: [localObjectID])
    realm.add(newMaster)
}

func test(formulas: [Formula]) {
    
    guard let realm = try? Realm() else {
        return
    }
    
    
    let currentUserID = AVUser.current()?.objectId
    
    var masterList = [String]()
    
    let currentUser = userWith(currentUserID!, inRealm: realm)
    
    
    realm.beginWrite()
    for index in 0..<20 {
        let localObjectID = formulas[index].localObjectID
        masterList.append(localObjectID)
    }
    currentUser?.masterList = masterList
    try? realm.commitWrite()
    
    printLog(currentUser?.masterList)
}


func syncPreferences() {

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

func syncFormula(with uploadMode: UploadFormulaMode, categoty: Category, completion: (([Formula]) -> Void)?, failureHandler:((Error?) -> Void)?) {
    
 
        
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

func convertDiscoverFormulaToFormula(discoverFormula: DiscoverFormula, uploadMode: UploadFormulaMode, inRealm realm: Realm, completion: ((Formula) -> Void)?) {
    
    
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
                
                newUser.avatarImageUrl = discoverFormulaCreator.getUserAvatarImageUrl()
                newUser.userID = discoverFormulaCreator.objectId!
                newUser.userName = discoverFormulaCreator.username!
                newUser.nickName = discoverFormulaCreator.getUserNickName()
                newUser.introduction = discoverFormulaCreator.getIntroduction()
                
                // 没有保存已经掌握的 [String] 列表.
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
                
                /// 如果当前用户是 content 的创建者, 删除.
                if
                    let currentUserID = AVUser.current()?.objectId ,
                    let discoverContentCreaterID = $0.creator.objectId {
                    
                    if currentUserID == discoverContentCreaterID {
                        
                        if let content = content {
                            realm.delete(content)
                        }
                    }
                }
                
                /// 如果是系统公式, 无论是不是当前登录用户, 直接删除
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

func currentUser(in realm: Realm) -> RUser? {
    guard let avuserID = AVUser.current()?.objectId else {
            printLog("没有登录")
            return nil
    }
    return userWith(avuserID, inRealm: realm)
}

func deleteMaster(with formula: Formula, inRealm realm: Realm) {
    
    guard let oldList = currentUser(in: realm)?.masterList else {
        return
    }
   
    let newLocalObjectID = formula.localObjectID
    
    if !oldList.contains(newLocalObjectID) {
        
        let newMaster = 
        
        realm.add(FormulaMaster(value: [newLocalObjectID]))
    }
    
    
}

func appendMaster(with formula: Formula) {
    
    
    
}


func formulaMaskerWith(_ localObjectID: String, inRealm realm: Realm) -> FormulaMaster? {
    let predicate = NSPredicate(format: "localObjectID = %@", localObjectID)
    return realm.objects(FormulaMaster.self).filter(predicate).first
}

func formulasCountWith(_ category: Category, uploadMode: UploadFormulaMode, inRealm realm: Realm) -> Int {
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

func categorysWith(_ uploadMode: UploadFormulaMode, inRealm realm: Realm) -> Results<RCategory>? {
    let predicate = NSPredicate(format: "uploadMode = %@", uploadMode.rawValue)
    return realm.objects(RCategory.self).filter(predicate)
    
}

func contentWith(_ objectID: String, inRealm realm: Realm) -> Content? {
    let predicate = NSPredicate(format: "localObjectID = %@", objectID)
    return realm.objects(Content.self).filter(predicate).first
}

func contentsWith(_ atFormulaObjectID: String, inRealm realm: Realm) -> Results<Content>? {
    let predicate = NSPredicate(format: "atFormulaLocalObjectID = %@", atFormulaObjectID)
    return realm.objects(Content.self).filter(predicate)
}

func formulaWith(_ objectID: String , inRealm realm: Realm) -> Formula? {
    let predicate = NSPredicate(format: "localObjectID = %@", objectID)
    return realm.objects(Formula.self).filter(predicate).first
}

func userWith(_ userID: String, inRealm realm: Realm) -> RUser? {
    let predicate = NSPredicate(format: "userID = %@", userID)
    return realm.objects(RUser.self).filter(predicate).first
}


extension AVQuery {
    
    enum DefaultKey: String {
        case updatedTime = "updatedAt"
        case creatTime = "createdAt"
    }
    
    class func getFormula(mode: UploadFormulaMode) -> AVQuery {
        
        switch mode {
            
        case .my:
            
            let query = AVQuery(className: DiscoverFormula.parseClassName())
            query.addAscendingOrder("name")
            query.whereKey("creator", equalTo: AVUser.init(objectId: "57a58cb5a633bd006043f0d7"))
            query.includeKey("creator")
            query.includeKey("contents")
            query.limit = 200
            return query
            
        case .library:
            
            let query = AVQuery(className: DiscoverFormula.parseClassName())
            query.whereKey("isLibrary", equalTo: NSNumber(booleanLiteral: true))
            query.addAscendingOrder("serialNumber")
            query.limit = 1000
            return query
            
        }
    }
    
    
    
}

extension AVUser {
    
    func setIntroduction(string: String) {
        setObject(string, forKey: "introducation")
    }
    
    func getIntroduction() -> String? {
        return object(forKey: "introducation") as? String
    }
    
    func setNeedUpdateLibrary(need: Bool) {
        setObject(need, forKey: needUpdateLibraryKey)
    }
    
    func getNeedUpdateLibrary() -> Bool {
        return object(forKey: needUpdateLibraryKey) as! Bool
    }
    
    func getUserID() -> String {
        return object(forKey: userID) as! String
    }
    
    func set(userID: String) {
        setObject(userID, forKey: userID)
    }
    
    func getUserNickName() -> String? {
        return object(forKey: userNickNameKey) as? String
    }
    
    func getUserAvatarImageUrl() -> String? {
        return object(forKey: userAvatarImageUrlKey) as? String
    }
    
    func set(nikeName: String) {
        setObject(nikeName, forKey: userNickNameKey)
    }
    
    func setUserAvatar(imageUrl: String) {
        setObject(imageUrl, forKey: userAvatarImageUrlKey)
    }
}
