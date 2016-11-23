//
//  String+Kit.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/23.
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
        return "Formula_" + String.random(length: 15)
    }
}

extension Content: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "Content_" + String.random(length: 15)
    }
}

extension RUser: RandomID {
    
    class func randomLocalObjectID() -> String {
        return "RUser_" + String.random(length: 15)
    }
}


extension String {
    
    static func random(length: Int) -> String {
        
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

    
