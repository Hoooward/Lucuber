//
//  Formulas.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation
import SwiftyJSON

class Formula:  CustomStringConvertible {
    
    var name: String = ""
    var contents = [FormulaContent]()
    var imageName: String = "cube_Placehold_image_1"
    var level = 1
    var favorate = false
    var modifyDate = ""
    var category = Category.x3x3
    var type = Type.F2L
    
    var rating: Int = 3
    
    init () { }
    
    class func creatNewDefaultFormula() -> Formula {
        return Formula(name: "公式名称", contents: [FormulaContent()], imageName: "cube_Placehold_image_1", level: 3, favorate: false, modifyDate: "", category: .x3x3, type: .F2L, rating: 3)
    }
    
    init(name: String, contents: [FormulaContent], imageName: String, level: Int, favorate: Bool, modifyDate: String, category: Category, type: Type, rating: Int)
    {
        self.name = name
        self.contents = contents
        self.imageName = imageName
        self.level = level
        self.favorate = favorate
        self.modifyDate = modifyDate
        self.category = category
        self.type = type
        self.rating = rating
    }
    
    var description: String {
        get {
            return "*********** \(self.name) ***********\n" + "catetory = \(category.rawValue)\n" + "content = \(contents) \n" + "imageName = \(imageName)\n" + "rating = \(rating)\n" + "-------------------------------"
        }
    }
    
}

public enum Category: String {
    
    case x2x2 = "二阶"
    case x3x3 = "三阶"
    case x4x4 = "四阶"
    case x5x5 = "五阶"
    case x6x6 = "六阶"
    case x7x7 = "七阶"
    case x8x8 = "八阶"
    case x9x9 = "九阶"
    case x10x10 = "十阶"
    case x11x11 = "十一阶"
    case Other = "其他"
    case SquareOne = "Square One"
    case Megaminx = "Megaminx"
    case Pyraminx = "Pyraminx"
    case RubiksClock = "魔表"
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
    
    
    // 将二维数组 Alls 转换为一维数组
    private func parseAllFormulas() -> [Formula] {
        var formulas: [Formula] = []
        let _ = Alls.map {
            $0.map {
                formulas.append($0) }
        }
        return formulas
    }
    
    
    /**
     整理字符串,去除空格
     参考: http://nshipster.cn/nscharacterset/
     */
    private func trimmingSearchText(text: String) -> String {
        return text.lowercaseString.trimming(String.TrimmingType.SquashingWhiteSpace)
    }
    
    func searchFormulasWithSearchText(searchText: String?) -> [Formula] {
        let formulas = parseAllFormulas()
        guard let text = searchText where text.characters.count > 0 else {
            return []
        }
       
        return formulas.filter {
            trimmingSearchText($0.name).containsString(trimmingSearchText(text))
        }
    }
    
    
    
    typealias Completion = ()->()
    func loadNewFormulas(completion: Completion) {
        let formulaFile = AVFile.init(URL: "http://ac-spfbe0ly.clouddn.com/Z4qcIcQinEQBBSHIuzqwLEE.json")
        
        func creatFormulas(jsonDict: [JSON], withType type: Type) -> [Formula] {
            var formulas = [Formula]()
            for item in jsonDict {
                let name = item["name"].stringValue
                
                let texts = item["formulaText"].arrayValue
                var formulaContent = [FormulaContent]()
                for text in texts {
                   let content = FormulaContent()
                    content.text = text.stringValue
                   formulaContent.append(content)
                
                    //测试
                   formulaContent.append(content)
                   formulaContent.append(content)
                }
                
                let level = item["level"].intValue
                let imageName = item["imageName"].stringValue
                let favorate = item["favorate"].boolValue
                let modifydate = item["modifydate"].stringValue
                
                let formula = Formula(name: name, contents: formulaContent, imageName: imageName, level: level, favorate: favorate, modifyDate: modifydate, category: Category.x3x3, type: type, rating: 3)
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











