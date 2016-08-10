//
//  KeyButtonItem.swift
//  Lucuber
//
//  Created by Howard on 16/7/9.
//  Copyright © 2016年 Howard. All rights reserved.
//

import Foundation

class KeyButtonItem {
    
    enum KeyButtonType: String {
        case Default = "Default"
        case Bracket = "Bracket"
        case Delete = "Delete"
        case Shift = "Shift"
        case Space = "Space"
        case Return = "Return"
        case Number = "Number"
    }
    
    enum TitleStatus {
        case Lower
        case Captal
    }
    
    ///显示在按钮上的Title
    var showTitle: String {
        switch status {
        case .Lower:
            return lower
        case .Captal:
            return capital
        }
    }
    ///大写字母
    var capital = ""
    ///小写字母
    var lower = ""
    ///按钮的类型
    var type: KeyButtonType = .Default
    ///标记大小写
    var status: TitleStatus = .Captal
    
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
        let path = NSBundle.mainBundle().pathForResource("FormulaKeyboard", ofType: ".plist")!
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