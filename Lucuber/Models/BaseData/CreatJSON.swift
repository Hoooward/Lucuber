//
//  CreatJSON.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

func creatJSON() {
    
    var dict = [String: AnyObject]()
    
    dict["F2L"] = [[String : AnyObject]]()
    dict["OLL"] = [[String : AnyObject]]()
    dict["PLL"] = [[String : AnyObject]]()
    
    
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    func creatF2L() {
        var f2l =  dict["F2L"] as! [[String : AnyObject]]
        for (index, contentArray) in F2LFormulas.enumerate() {
            
            let ID = "\(index + 1)"
            let name = "F2L " + "\(index + 1)"
            let formulaString = contentArray
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
        for (index, contentArray) in OLLFormulas.enumerate() {
            
            let ID = "\(index + 1)"
            let name = "OLL " + "\(index + 1)"
            let formulaString = contentArray
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
        for (index, contentArray) in PLLFormulas.enumerate() {
            
            let ID = String(format: "%d", index + 1)
            let name =  "PLL " + "\(index + 1)"
            let formulaString = contentArray
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
    
    
    do {
        let data = try NSJSONSerialization.dataWithJSONObject(dict, options: .PrettyPrinted)
//        let jason = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        let result = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        
        
        print(result)
    } catch {
        
    }
}

