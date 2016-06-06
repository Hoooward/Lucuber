//
//  CubeUserDefaults.swift
//  Lucuber
//
//  Created by Howard on 6/6/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation

//
//public class User: Object {
//    public dynamic var userID: String = ""
//    public dynamic var username: String = ""
//    public dynamic var nickname: String = ""
//    public dynamic var introduction: String = ""
//    public dynamic var avatarURLString: String = ""
//    public dynamic var avatar: Avatar?
//    public dynamic var badge: String = ""
//    public dynamic var blogURLString: String = ""
//    public dynamic var blogTitle: String = ""
//}

public class User {
    var userID: String = ""
    var username: String = ""
}

private let v1AccessTokenKey = "v1AccessToken"

public class CubeConfig {
    public static let appGroupID: String = "Lucuber"
}

class CubeUserDefaults {
    static let defaults = NSUserDefaults(suiteName: CubeConfig.appGroupID)
    
//    public static var isLogined: Bool {
//        if let _ = CubeUserDefaults.va
//    }
}