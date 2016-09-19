//
//  Formula.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import AVOSCloud

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

/// FormulaViewController's collectionView Layout
public enum FormulaUserMode {
    
    case Normal
    case Card
}


public enum Type: String {
    /// 三阶
    case CROSS = "Cross"
    case F2L = "F2L"
    case PLL = "PLL"
    case OLL = "OLL"
    
    //之后要添加Type, 不仅仅要在 plist 文件中添加, 还要来这里添加
    //    case test1 = "111"
    //    case test2 = "222"
    //    case test3 = "333"
}

public class Formula: AVObject, AVSubclassing {
    
    public class func parseClassName() -> String {
        return "Formula"
    }
    
    @NSManaged var objectID: String
    
    /// 判断是否是系统公式库中的公式
    @NSManaged var isLibraryFormula: Bool
    
    /// 公式库公式ID, 1..2..3..4..5..6,排序用. 用户创建的公式不需要此属性
    @NSManaged var serialNumber: Int
    
    ///名字
    @NSManaged var name: String
    
    var nickName: String {
        return type.rawValue + "name"
    }
    
    var creatUserID: String = ""
    
    
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
                let stringArray = string.components(separatedBy: "--")
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
    
    /// 用户创建公式使用的
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
        self.objectID = NSUUID().uuidString
    }
    
    
    
    /// 系统公式库创建所使用的.
    init(name: String, contents: [FormulaContent], imageName: String, favorate: Bool, category: Category, type: Type, rating: Int, serialNumber: Int) {
        super.init()
        self.isLibraryFormula = false
        self.name = name
        self.contents = contents
        self.imageName = imageName
        self.favorate = favorate
        self.category = category
        self.type = type
        self.rating = rating
        self.serialNumber = serialNumber
        self.objectID = NSUUID().uuidString
    }
    
    class func creatNewDefaultFormula() -> Formula {
        return Formula(name: "", contents: [FormulaContent()], imageName: "cube_Placehold_image_1", favorate: false, category: .x3x3, type: .F2L, rating: 3)
    }
    
    override public var description: String {
        get {
            return "*********** \(self.name) ***********\n" + "catetory = \(category.rawValue)\n" + "content = \(contents) \n" + "imageName = \(imageName)\n" + "rating = \(rating)\n"  + "type = \(type)" + "-------------------------------"
        }
    }


}

public enum Rotation {
    
    /// 第一个参数是 imageName 第二个参数是 placeholder
    case FR (String, String)
    case FL (String, String)
    case BL (String, String)
    case BR (String, String)
    
    // private let FLrotation: Rotation = Rotation.FL("FL", "魔方整体顺时针旋转 90° 的状态")
}

class FormulaContent: CustomStringConvertible {
    
    var text: String?
    var rotation: Rotation = Config.BaseRotation.FRrotation
    
    var cellHeight: CGFloat {
        let height: CGFloat = 50
        
        let margin = Config.DetailFormula.screenMargin
        
        if let text = text, text.characters.count > 0 {
            
            let attributesText = text.setAttributesFitDetailLayout(style: .detail)
            let rect = attributesText.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - (margin * 2) - 25 - 15, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.init(rawValue: 1), context: nil)
            
            return rect.size.height + 30
        }
        
        return height
    }
    
    init() { }
    
    init(text: String, rotation: String) {
        self.text = text
        
        switch rotation {
            
        case "FR":
            self.rotation = Config.BaseRotation.FRrotation
            
        case "FL":
            self.rotation = Config.BaseRotation.FLrotation
            
        case "BL":
            self.rotation = Config.BaseRotation.BLrotation
            
        case "BR":
            self.rotation = Config.BaseRotation.BRrotation
            
        default:
            break
            
        }
    }
    
    var description: String {
        return "\(text) + \(rotation)"
    }
    
    
}

