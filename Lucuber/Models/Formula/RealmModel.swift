//
//  Realm.swift
//  Lucuber
//
//  Created by Howard on 8/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import RealmSwift

class RCategory: Object {
    
    dynamic var categoryString = ""
    dynamic var mode = ""
    
    func convertToCategory() -> Category {
       return Category(rawValue: categoryString)!
    }
}


internal func saveCategoryMenusInRealm(categorys: [Category], mode: UploadFormulaMode) {
    
    let realm = try! Realm()
    
    
    try! realm.write {
        realm.delete(realm.objects(RCategory))
    }
    
    
    var modeString: String = ""
    
    switch mode {
        
    case .My:
        modeString = "My"
    case .Library:
        
        modeString = "Library"
    }
    
    try! realm.write {
        var result = [RCategory]()
        for category in categorys {
            let r = category.convertToRCategory()
            r.mode = modeString
            result.append(r)
        }
        realm.add(result)
    }
    
}

internal func getCategoryMenusInRealm(mode: UploadFormulaMode) -> [Category] {
    
    let realm = try! Realm()
    let predicate = NSPredicate(format: "mode == %@", mode.rawValue)
    return realm.objects(RCategory).filter(predicate).map { $0.convertToCategory() }
}

internal func saveUploadFormulasInRealm(formulas: [Formula]) {
    
    let realm = try! Realm()
    
    try! realm.write {
        realm.add(formulas.map { $0.convertRFormulaModel()}, update: true)
    }
}

internal func getFormulsFormRealmWithMode(mode: UploadFormulaMode, category: Category) -> [Formula] {
  
    let realm = try! Realm()
    
    switch mode {
        
    case .My:
        
        let id = AVUser.currentUser().objectId
        let predicate = NSPredicate(format: "creatUserID = %@", id)
        let predicate2 = NSPredicate(format: "categoryString == %@", category.rawValue)
        return realm.objects(RFormula).filter(predicate).filter(predicate2).map { $0.convertToFromula() }
        
    case .Library:
        
        let predicate = NSPredicate(format: "isLibraryFormulas == true")
        let predicate2 = NSPredicate(format: "categoryString == %@", category.rawValue)
        return realm.objects(RFormula).filter(predicate).filter(predicate2).map { $0.convertToFromula() }
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

class RContent: Object {
    
    dynamic var text = ""
    dynamic var rotation = ""
    dynamic var cellHeight = 0
    
    func convertToFormulaContent() -> FormulaContent {
        return FormulaContent(text: text, rotation: rotation)
    }
}

extension AVUser {
    
    func converRUserModel() -> RUser {
        let rUser = RUser()
        rUser.avatarImageUrl = self.getUserAvatarImageUrl()
        rUser.userID = self.objectId
        rUser.userName = self.username
        rUser.nickName = self.getUserNickName()
        return rUser
    }
}

class RUser: Object {
    
    dynamic var userID: String = ""
    dynamic var nickName: String = ""
    dynamic var userName: String = ""
    dynamic var avatarImageUrl: String?
    
    func convertToAVUser() -> AVUser {
        
        let user = AVUser()
        user.setUserID(userID)
        user.setUserNickName(nickName)
        
        if let url = avatarImageUrl {
            user.setUserAvatarImageUrl(url)
        }
        
        user.username = userName
        return user
    }
}

extension Formula {
    
    func convertRFormulaModel() -> RFormula {
        
        let formula = RFormula()
        formula.objectID = objectId
        formula.name = name
        formula.imageName = imageName
        formula.favorate = favorate
        if let id = creatUser.objectId {
            formula.creatUserID = id
        }
        formula.creatUser = creatUser.converRUserModel()
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
    dynamic var creatUser: RUser?
    
    var contentsString = List<RContent>()
    
    dynamic var creatUserID: String = ""
    dynamic var categoryString = ""
    dynamic var typeString  = ""
    dynamic var rating = 0
    dynamic var isLibraryFormulas = false
    
    
    func convertToFromula() -> Formula {
        let formula = Formula()
        formula.name = name
        formula.imageName = imageName
        formula.favorate = favorate
        formula.categoryString = categoryString
        formula.typeString = typeString
        formula.rating = rating
        formula.contents = contentsString.map { $0.convertToFormulaContent()}
        
        if let user = creatUser {
            formula.creatUser = user.convertToAVUser()
        }
        
        return formula
    }
    
}