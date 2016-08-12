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

public class UserDefaults {
    
    class func setNeedUpdateLibrary(need: Bool) {
       defaults.setBool(need, forKey: needUpdateLibraryKey)
    }
    
    class func needUpdateLibrary() -> Bool {
        return defaults.boolForKey(needUpdateLibraryKey)
    }
}


private let MySelectedCategoryKey = "MySelectedCategory"
private let LibrarySelectedCategoryKey = "LibrarySelectedCategoryKey"

extension UserDefaults {
    
    
    class func setSelectedCategory(category: Category, mode: UploadFormulaMode) {
        
        switch mode {
            
        case .My:
            setMySelectedCategory(category)
            
        case .Library:
            setLibrarySelectedCategory(category)
        }
    }
    
    class func getSeletedCategory(mode: UploadFormulaMode) -> Category {
        
        switch mode {
            
        case .My:
            return mySelectedCategory()
            
        default:
            return librarySelectedCategory()
        }
    }
    
    class func setMySelectedCategory(category: Category) {
        defaults.setObject(category.rawValue, forKey: MySelectedCategoryKey)
    }
    
    class func mySelectedCategory() -> Category {
        
        if let categoryString = defaults.objectForKey(MySelectedCategoryKey) as? String {
            
            return Category(rawValue: categoryString)!
            
        } else {
            
            return Category.x3x3
        }
    }
    
    class func setLibrarySelectedCategory(category: Category) {
        defaults.setObject(category.rawValue, forKey: LibrarySelectedCategoryKey)
    }
    
    class func librarySelectedCategory() -> Category {
        
        if let categoryString = defaults.objectForKey(LibrarySelectedCategoryKey) as? String {
            
            return Category(rawValue: categoryString)!
            
        } else {
            
            return Category.x3x3
        }
    }
    
}