//
//  Keyboard.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation


class KeyButtonItem {
    
    enum KeyButtonType: String {
        
        case defaultKey = "Default"
        case bracketKey = "Bracket"
        case deleteKey = "Delete"
        case shiftKey = "Shift"
        case spaceKey = "Space"
        case returnKey = "Return"
        case numberKey = "Number"
    }
    
    enum TitleStatus {
        case lower
        case captal
    }
    
    ///显示在按钮上的Title
    var showTitle: String {
        switch status {
        case .lower:
            return lower
        case .captal:
            return capital
        }
    }
    
    ///大写字母
    var capital = ""
    ///小写字母
    var lower = ""
    ///按钮的类型
    var type: KeyButtonType = .defaultKey
    ///标记大小写
    var status: TitleStatus = .captal
    
    init(dict: [String: AnyObject]) {
        
        let type = dict["type"] as! String
        let lower = dict["lower"] as! String
        let capital = dict["capital"] as! String
        
        self.type = KeyButtonType(rawValue: type)!
        self.lower = lower
        self.capital = capital
    }
}

class KeyButtonItemPackage: NSObject {
    
    var topKeyboardItems = [KeyButtonItem]()
    var bottomKeyboardItems = [KeyButtonItem]()
    
    class func loadPackage() -> KeyButtonItemPackage {
        
        let path = Bundle.main.path(forResource: "FormulaKeyboard", ofType: ".plist")!
        let dict = NSDictionary(contentsOfFile: path)!
        
        let keyButtonItemPackage = KeyButtonItemPackage()
        
        if let items = dict["TopKeyboard"] as? [[String: AnyObject]] {
            for item in items {
                keyButtonItemPackage.topKeyboardItems.append(KeyButtonItem(dict: item))
            }
        }
        
        if let items = dict["BottomKeyboard"] as? [[String: AnyObject]] {
            for item in items {
                
                keyButtonItemPackage.bottomKeyboardItems.append(KeyButtonItem(dict: item))
            }
        }
        
        return keyButtonItemPackage
    }
}

