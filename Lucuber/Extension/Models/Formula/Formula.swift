//
//  Formulas.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation
import SwiftyJSON

class Formula : CustomStringConvertible {
    var name: String = ""
    var formulaText = [String]()
    var imageName: String = ""
    var level = 1
    var favorate = false
    var modifyDate = ""
    var category = Category.x3x3
    var type = Type.F2L
    
    init(name: String, formula: [String], imageName: String, level: Int, favorate: Bool, modifyDate: String, category: Category, type: Type)
    {
        self.name = name
        self.formulaText = formula
        self.imageName = imageName
        self.level = level
        self.favorate = favorate
        self.modifyDate = modifyDate
        self.category = category
        self.type = type
    }
    
    
    var description: String {
        get {
            return "name = \(self.name)"
        }
    }
    
}


enum Category: String {
    case x3x3 = "x3x3"
}

enum Type: String {
    case F2L = "F2L"
    case PLL = "PLL"
    case OLL = "OLL"
}

class FormulaManager {
    
    static let instance = FormulaManager()
    class func shardManager() -> FormulaManager {
        return instance
    }
    var OLLs = [Formula]()
    var F2Ls = [Formula]()
    var PLLs = [Formula]()
    var Alls = [[Formula]]()
    
    
    typealias Completion = ()->()
    func loadNewFormulas(completion: Completion) {
        let formulaFile = AVFile.init(URL: "http://ac-spfbe0ly.clouddn.com/Z4qcIcQinEQBBSHIuzqwLEE.json")
        
        func creatFormulas(jsonDict: [JSON], withType type: Type) -> [Formula] {
            var formulas = [Formula]()
            for item in jsonDict {
                let name = item["name"].stringValue
                
                let texts = item["formulaText"].arrayValue
                var formulaTexts = [String]()
                for text in texts {
                   formulaTexts.append(text.stringValue)
                
                    //测试
                   formulaTexts.append(text.stringValue)
                   formulaTexts.append(text.stringValue)
                }
                let formulaText = formulaTexts
                
                let level = item["level"].intValue
                let imageName = item["imageName"].stringValue
                let favorate = item["favorate"].boolValue
                let modifydate = item["modifydate"].stringValue
                
                let formula = Formula(name: name, formula: formulaText, imageName: imageName, level: level, favorate: favorate, modifyDate: modifydate, category: Category.x3x3, type: type)
                formulas.append(formula)
            }
            return formulas
        }
        
        formulaFile.getDataInBackgroundWithBlock { (data, error) in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                let jsonDict = JSON(json)
                
                if let olls = jsonDict["OLL"].array {
                    self.OLLs = creatFormulas(olls, withType: Type.OLL)
                    self.Alls.append(self.OLLs)
                }
                if let plls = jsonDict["PLL"].array {
                    self.PLLs = creatFormulas(plls, withType: Type.PLL)
                    self.Alls.append(self.PLLs)
                }
                if let f2ls = jsonDict["F2L"].array {
                    self.F2Ls = creatFormulas(f2ls, withType: Type.F2L)
                    self.Alls.append(self.F2Ls)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    completion()
                })
            }catch {
                print("解析JSON 失败")
            }
        }
    }
}











