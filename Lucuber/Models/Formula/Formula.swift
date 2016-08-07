//
//  Formulas.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation
import SwiftyJSON

class Formula: AVObject, AVSubclassing  {
    
    class func parseClassName() -> String {
        return "Formula"
    }
    
    @NSManaged var isLibraryFormula: Bool
    
    ///名字
    @NSManaged var name: String
    
    ///图片名字
    @NSManaged var imageName: String
    
    ///评级
    @NSManaged var rating: Int
    
    ///是否收藏
    @NSManaged var favorate: Bool
    
    ///创建者
    @NSManaged var creatUser: AVUser
    
    /// 公式内容的文本信息
    @NSManaged var contentsString: [String]
    
    var contents: [FormulaContent] {
        
        set {
            
            self.contentsString =  newValue.map {
                
                let text = $0.text ?? ""
                
                var contentString = ""
                switch $0.rotation {
                case let .FR(imageName, _):
                   contentString = imageName + "--" + text
                case let .FL(imageName, _):
                   contentString = imageName + "--" + text
                case let .BL(imageName, _):
                   contentString = imageName + "--" + text
                case let .BR(imageName, _):
                   contentString = imageName + "--" + text
                }
                
                return contentString
                
            }
        }
        
        get {
            
            var contents = [FormulaContent]()
            for string in contentsString {
                let stringArray = string.componentsSeparatedByString("--")
                if stringArray.count == 2 {
                    let rotation = stringArray[0]
                    let text = stringArray[1]
                    let content = FormulaContent(text: text, rotation: rotation)
                    contents.append(content)
                }
            }
            return contents
        }
    }
    
    @NSManaged var categoryString: String
    
    var category: Category {
        
        set {
            categoryString = newValue.rawValue
        }
        
        get {
            return Category(rawValue: categoryString)!
        }
    }
    
    @NSManaged var typeString: String
    
    var type: Type {
        
        set {
            typeString = newValue.rawValue
        }
        
        get {
            return Type(rawValue: typeString)!
        }
    }
    
    override init() {
        
        super.init()
    }
    
    init(name: String, contents: [FormulaContent], imageName: String, favorate: Bool, category: Category, type: Type, rating: Int)
    {
        super.init()
        self.isLibraryFormula = false
        self.name = name
        self.contents = contents
        self.imageName = imageName
        self.favorate = favorate
        self.category = category
        self.type = type
        self.rating = rating
    }
  
    class func creatNewDefaultFormula() -> Formula {
        return Formula(name: "", contents: [FormulaContent()], imageName: "cube_Placehold_image_1", favorate: false, category: .x3x3, type: .F2L, rating: 3)
    }

    override var description: String {
        get {
            return "*********** \(self.name) ***********\n" + "catetory = \(category.rawValue)\n" + "content = \(contents) \n" + "imageName = \(imageName)\n" + "rating = \(rating)\n" + "-------------------------------"
        }
    }
    
}

class Formulas:  CustomStringConvertible {
    
    ///名字
    var name: String = ""
    ///公式内容
    var contents = [FormulaContent]()
    var imageName: String = "cube_Placehold_image_1"
    var favorate = false
    var modifyDate = ""
    var category = Category.x3x3
    var type = Type.F2L
    
    var rating: Int = 3
    
    init () { }
    
    class func creatNewDefaultFormula() -> Formulas {
        return Formulas(name: "公式名称", contents: [FormulaContent()], imageName: "cube_Placehold_image_1",  favorate: false, modifyDate: "", category: .x3x3, type: .F2L, rating: 3)
    }
    
    init(name: String, contents: [FormulaContent], imageName: String, favorate: Bool, modifyDate: String, category: Category, type: Type, rating: Int)
    {
        self.name = name
        self.contents = contents
        self.imageName = imageName
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













