//
//  AVUser+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/20.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import AVOSCloud


fileprivate let nicknameKey = "nickname"
fileprivate let avatorImageURLKey = "avatorImageURL"
fileprivate let localObjectIDKey = "localObjectID"
fileprivate let masterListKey = "masterList"
fileprivate let introdctionKey = "introduction"
fileprivate let cubeCategoryMasterListKey = "cubeCategoryMasterList"
fileprivate let subscribesListKey = "subscribesList"
fileprivate let cubeScoresListKey = "cubeScoresList"

extension AVUser {
    
    func setIntroduction(_ string: String) {
        setObject(string, forKey: introdctionKey)
    }
    
    func introduction() -> String? {
        return object(forKey: introdctionKey) as? String
    }
    
    func localObjectID() -> String? {
        return object(forKey: localObjectIDKey) as? String
    }
    
    func setLocalObjcetID(_ userID: String) {
        setObject(userID, forKey: localObjectIDKey)
    }
    
    func nickname() -> String? {
        return object(forKey: nicknameKey) as? String
    }
    
    func avatorImageURL() -> String? {
        return object(forKey: avatorImageURLKey) as? String
    }
    
    func setNickname(_ nikeName: String) {
        setObject(nikeName, forKey: nicknameKey)
    }
    
    func setAvatorImageURL(_ imageUrl: String) {
        setObject(imageUrl, forKey: avatorImageURLKey)
    }
    
    func masterList() -> [String]? {
        return object(forKey: masterListKey) as? [String]
    }
    
    func setMasterList(_ list: [String]) {
        setObject(list, forKey: masterListKey)
    }
    
    func cubeCategoryMasterList() -> [String]? {
        return object(forKey: cubeCategoryMasterListKey) as? [String]
    }
    
    func setCubeCategoryMasterList(_ list: [String]) {
        setObject(list, forKey: cubeCategoryMasterListKey)
    }
    
    func setSubscribeList(_ list: [String]) {
        setObject(list, forKey: subscribesListKey)
    }
    
    func subscribeList() -> [String]? {
        return object(forKey: subscribesListKey) as? [String]
    }
    
    func setCubeScoresList(_ list: [String: String]) {
        setObject(list, forKey: cubeScoresListKey)
    }
    
    func cubeScoresList() -> [String: String]? {
        return object(forKey: cubeScoresListKey) as? [String: String]
    }
    
    public static var isLogin: Bool {
        if let _ = self.current() {
            return true
        }
        return false
    }
    
}
    


