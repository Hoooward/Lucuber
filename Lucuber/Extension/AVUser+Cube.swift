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
