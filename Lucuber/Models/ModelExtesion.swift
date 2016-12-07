//
//  ModelExtesion.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/27.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import RealmSwift

protocol RandomID {
    static func randomLocalObjectID() -> String
}

extension RandomID where Self: Object {
    
}

extension Formula: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "Formula_" + String.random()
    }
}

extension Content: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "Content_" + String.random()
    }
}

extension RUser: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "RUser_" + String.random()
    }
}

extension Message: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "Message_" + String.random()
    }
}

extension Feed: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "Feed" + String.random()
    }
}

extension String {
    
    static func random(length: Int = 15) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
