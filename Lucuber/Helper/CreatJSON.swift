//
//  CreatJSON.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class Formula {
    var name: String = ""
    var formula = [String]()
    var imageName: String = ""
    var level = 1
    var favorate = false
    var modifyDate = ""
    
    
    init(name: String, formula: [String], imageName: String, level: Int, favorate: Bool, modifyDate: String)
    {
        self.name = name
        
        self.formula = formula
        self.imageName = imageName
        self.level = level
        self.favorate = favorate
        self.modifyDate = modifyDate
    }
}

func creatJSON() {
    
    
    
    var dict = [String: AnyObject]()
    
    dict["F2L"] = [[String : AnyObject]]()
    dict["OLL"] = [[String : AnyObject]]()
    dict["PLL"] = [[String : AnyObject]]()
    
    
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    func creatF2L() {
        var f2l =  dict["F2L"] as! [[String : AnyObject]]
        for (index, text) in F2LFormulas.enumerate() {
            
            let ID = "\(index + 1)"
            let name = "F2L " + "\(index + 1)"
            let formulaString = [text]
            let imageName = "F2L" + "\(index + 1)"
            let level = 3
            let favorate = false
            let modifyDate = formatter.stringFromDate(NSDate())
            
            var cache = [String: AnyObject]()
            cache["ID"] = ID
            cache["name"] = name
            cache["formulaText"] = formulaString
            cache["imageName"] = imageName
            cache["level"] = level
            cache["favorate"] = favorate
            cache["modifyDate"] = modifyDate
            f2l.append(cache)
        }
        dict["F2L"] = f2l
    }
    
    func creatOLL() {
        var oll =  dict["OLL"] as! [[String : AnyObject]]
        for (index, text) in F2LFormulas.enumerate() {
            
            let ID = "\(index + 1)"
            let name = "OLL " + "\(index + 1)"
            let formulaString = [text]
            let imageName = "OLL" + "\(index + 1)"
            let level = 3
            let favorate = false
            let modifyDate = formatter.stringFromDate(NSDate())
            
            var cache = [String: AnyObject]()
            cache["ID"] = ID
            cache["name"] = name
            cache["formulaText"] = formulaString
            cache["imageName"] = imageName
            cache["level"] = level
            cache["favorate"] = favorate
            cache["modifyDate"] = modifyDate
            oll.append(cache)
        }
        dict["OLL"] = oll
    }
    
    func creatPLL() {
        var pll =  dict["PLL"] as! [[String : AnyObject]]
        for (index, text) in F2LFormulas.enumerate() {
            
            let ID = String(format: "%d", index + 1)
            let name =  "PLL " + "\(index + 1)"
            let formulaString = [text]
            let imageName = "PLL" + "\(index + 1)"
            let level = 3
            let favorate = false
            let modifyDate = formatter.stringFromDate(NSDate())
            
            var cache = [String: AnyObject]()
            cache["ID"] = ID
            cache["name"] = name
            cache["formulaText"] = formulaString
            cache["imageName"] = imageName
            cache["level"] = level
            cache["favorate"] = favorate
            cache["modifyDate"] = modifyDate
            pll.append(cache)
        }
        dict["PLL"] = pll
 
    }
    
    
    creatF2L()
    creatOLL()
    creatPLL()
    
    
//    print(dict)
    
    
    do {
        let data = try NSJSONSerialization.dataWithJSONObject(dict, options: .PrettyPrinted)
//        let jason = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        let string = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        print(string)
    } catch {
        
        
    }
    
}
