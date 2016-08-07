//
//  AVUser+Cube.swift
//  Lucuber
//
//  Created by Howard on 7/25/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation


extension AVUser {
    
   
    
    private static let userNickNameKey = "userNickNameKey"
    private static let userAvatarImageUrlkey = "userAvatarImageUrlkey"
    
    func getUserNickName() -> String {
        return objectForKey(AVUser.userNickNameKey) as? String ?? "无"
    }
    
    func getUserAvatarImageUrl() -> String? {
        return objectForKey(AVUser.userAvatarImageUrlkey) as? String
    }
    
    func setUserNickName(name: String) {
        setObject(name, forKey: AVUser.userNickNameKey)
    }
    
    func setUserAvatarImageUrl(url: String) {
        setObject(url, forKey: AVUser.userAvatarImageUrlkey)
    }
    
}