//
//  AVUser+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/20.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import AVOSCloud


fileprivate let userNickNameKey = "userNickName"
fileprivate let userAvatarImageUrlKey = "userAvatarImageUrl"
fileprivate let userID = "userID"
fileprivate let needUpdateLibraryKey = "needUpdateLibrary"
fileprivate let masterFormulasIDListKey = "masterFormulasIDList"
fileprivate let needUpdateMasterListKey = "needUpdateMsterList"

extension AVUser {
    
//    func setNeedUpdateMasterListToLeanCloud(need: Bool) {
//        setObject(need, forKey: needUpdateLibraryKey)
//    }
//    
//    func getNeedUpdateMsterListtoLeanCloud() -> Bool {
//        
//        return object(forKey: needUpdateLibraryKey) as! Bool
//    }
    
    func getMasterFormulasIDList() -> [String]? {
        let list = object(forKey: masterFormulasIDListKey) as? [String]
//        printLog(list)
        return list
    }
    
    func setMasterFormulasIDList(list: [String]) {
        
//        printLog(list)
        setObject(list, forKey: masterFormulasIDListKey)
    }
    
    
    func addNewMasterFormula(_ formula: Formula) {
       
        var newList = [String]()
        if let oldList = getMasterFormulasIDList() {
            
            newList = oldList
            newList.append(formula.objectID)
        
        } else {
            
            newList.append(formula.objectID)
        }
        
        setMasterFormulasIDList(list: newList)
    }
    
    func deleteMasterFormula(_ formula: Formula) {
        
        guard let oldList = getMasterFormulasIDList() else {
            return
        }
        
        var newList = [String]()
        newList = oldList
        
        if let index = newList.index(of: formula.objectID) {
            
            newList.remove(at: index)
        }
        
        setMasterFormulasIDList(list: newList)
    }
    
    
    func fetchCurrentUserInfoKeys() -> [String]  {
        
        return [masterFormulasIDListKey, needUpdateLibraryKey]
    }
}
    

extension AVUser {
    func getNeedUpdateLibrary() -> Bool {
        return object(forKey: needUpdateLibraryKey) as! Bool
    }
    
    func setNeedUpdateLibrary(need: Bool) {
        setObject(need, forKey: needUpdateLibraryKey)
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
