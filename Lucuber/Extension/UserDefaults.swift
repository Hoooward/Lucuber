//
//  CubeUserDefaults.swift
//  Lucuber
//
//  Created by Howard on 8/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation


private let needUpdateLibraryKey = "needUpdateLibraryKey"
private let defaults = NSUserDefaults.standardUserDefaults()

class UserDefaults {
    
    class func setNeedUpdateLibrary(need: Bool) {
       defaults.setBool(need, forKey: needUpdateLibraryKey)
    }
    
    class func needUpdateLibrary() -> Bool {
        return defaults.boolForKey(needUpdateLibraryKey)
    }
}