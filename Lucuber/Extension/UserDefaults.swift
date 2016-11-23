//
//  UserDefaults.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/20.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

fileprivate let needUpdateLibraryKey = "needUpdateLibraryKey"
fileprivate let newUserNickNameKey = "newUserNickName"
fileprivate let newUserAvatarURLKey = "newUserAvatarURL"


extension UserDefaults {
    
    class func setNewUser(avatarURL: String) {
        
        standard.set(avatarURL, forKey: newUserAvatarURLKey)
    }
    
    class func getNewUserAvatarURL() -> String? {
        
        return standard.object(forKey: newUserAvatarURLKey) as? String
    }
    
    class func setNewUser(userName: String) {
        
        standard.set(userName, forKey: newUserNickNameKey)
    }
    
    class func getNewUserNickName() -> String? {
        
        return standard.object(forKey: newUserNickNameKey) as? String
    }
    
    class func setNeedUpdateLibrary(need: Bool) {
        
        standard.set(need, forKey: needUpdateLibraryKey)
    }
    
    class func isNeedUpdateLibrary() -> Bool {
        
        return standard.bool(forKey: needUpdateLibraryKey)
    }
    
}

fileprivate let dataVersionKey = "dateVersioKey"

extension UserDefaults {
    
    class func setDataVersion(_ version: String) {
        standard.set(version, forKey: dataVersionKey)
    }
    
    class func dataVersion() -> String {
        return standard.string(forKey: dataVersionKey) ?? "0.9"
    }
}




fileprivate let myFormulaSeletedCategoryKey = "mySeletedCategoryKey"
fileprivate let libraryFormulaSeletedCategoryKey = "librarySeletedCategoryKey"

extension UserDefaults {
    
    class func setSelected(category: Category, mode: UploadFormulaMode) {
        
        switch mode {
            
        case .my:
            setMySeleted(category: category)
            
        case .library:
            setLibrarySeleted(category: category)
        }
    }
    
    class func getSeletedCategory(mode: UploadFormulaMode) -> Category {
        
        switch mode {
            
        case .my:
            return mySeletedCategory()
            
        case .library:
            return librarySeletedCategory()
        }
    }
    
    class func setMySeleted(category: Category) {
    
        standard.set(category.rawValue, forKey: myFormulaSeletedCategoryKey)
    }
    
    class func setLibrarySeleted(category: Category) {
        
        standard.set(category.rawValue, forKey: libraryFormulaSeletedCategoryKey)
    }
    
    class func mySeletedCategory() -> Category {
        
        if let categorString = standard.object(forKey: myFormulaSeletedCategoryKey) as? String {
            
            return Category(rawValue: categorString)!
            
        } else {
            
           return Category.x3x3
        }
    }
    
    class func librarySeletedCategory() -> Category {
        
        if let categorString = standard.object(forKey: libraryFormulaSeletedCategoryKey) as? String {
            
            return Category(rawValue: categorString)!
            
        } else {
            
           return Category.x3x3
        }
    }
    
    
    
}
















