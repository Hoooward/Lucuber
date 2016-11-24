//
//  Formula.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import AVOSCloud
import RealmSwift

extension Array {
   
    func pareseTwoDimensionalToOne(_ catchArray: [[Formula]]) -> [Formula] {
        
        var resultArray: [Formula] = []
 
        _ = catchArray.map {
            $0.map {
                resultArray.append($0)
            }
        }
        
        return resultArray
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
    
    var sortIndex: Int {
        
        switch self {
        case .x2x2:
            return 1
        case .x3x3:
            return 2
        case .x4x4:
            return 3
        case .x5x5:
            return 4
        case .x6x6:
            return 5
        case .x7x7:
            return 6
        case .x8x8:
            return 7
        case .x9x9:
            return 8
        case .x10x10:
            return 9
        case .x11x11:
            return 10
        case .SquareOne:
            return 11
        case .Megaminx:
            return 12
        case .Pyraminx:
            return 13
        case .RubiksClock:
            return 14
        case .Other:
            return 15
        }
    }
    
}

/// FormulaViewController's collectionView Layout
public enum FormulaUserMode {
    
    case normal
    case card
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
    
    var sortIndex: Int {
        
        switch self {
        case .CROSS:
            return 1
        case .F2L:
            return 2
        case .PLL:
            return 3
        case .OLL:
            return 4
        }
    }
}

open class Formula: Object {
    
    override open static func primaryKey() -> String? {
        return "localObjectID"
    }
    
    dynamic var localObjectID: String = ""
    
    dynamic var lcObjectID: String?
    
    dynamic var name: String = ""
    
    dynamic var imageName: String = ""
    
    dynamic var imageURL: String?
    
    dynamic var favorate: Bool = false
    
    dynamic var categoryString: String = ""
    
    dynamic var typeString: String = ""
    
    dynamic var creator: RUser?
    
    dynamic var deletedByCreator: Bool = false
    
    dynamic var rating: Int = 0
    
    dynamic var isLibrary: Bool = false
    
    dynamic var updateUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    
    let contents = LinkingObjects(fromType: Content.self, property: "atFormula")
    
    
    var image = UIImage()
    
    var category: Category {
        set { categoryString = newValue.rawValue }
        get { return Category(rawValue: categoryString)! }
    }
    
    var type: Type {
        set { typeString = newValue.rawValue }
        get { return Type(rawValue: typeString)! }
    }
    
    override open static func ignoredProperties() -> [String] {
        return ["image", "category", "type"]
    }
    class func creatNewDefaultFormula() -> Formula {
        
        let newFormula = Formula()
        newFormula.imageName = "cube_Placehold_image_1"
        newFormula.favorate = false
        newFormula.category = .x3x3
        newFormula.type = .F2L
        newFormula.rating = 5
        return newFormula
    }
    
    /// 判断信息是否都正确填写
    func isReadyforPushToLeanCloud() -> Bool {
        var contentIsReady = false
        // 如果contents的第一个text有值, 就可以
        if let content = self.contents.first {
            contentIsReady = !content.text.isDirty
        }
        
        if name.isDirty || imageName.isDirty || typeString.isDirty || categoryString.isDirty  || !contentIsReady {
            
            return false
        }
        
        return true
    }
    
//    func prepareForPushToLeanCloud() {
//        //准备保存前, 将空白的 content 内容删除掉
//        
//        self.contents.forEach {
//            
//            if $0.text.isDirty {
//                
//                if let content = contentWith($0.localObjectID, inRealm: realm) {
//                    
//                }
//            }
//        }
//        
//        var catchContents = self.contents
//        // 如果某一个创建的content其中的text isDirty, 是删除掉这个content
//        for (index, content) in catchContents.enumerated() {
//            if content.text.isDirty ?? true {
//                catchContents.remove(at: index)
//            }
//        }
//        self.contents = catchContents
//    }
    
    var contentLabelMaxHeight: CGFloat {
        
        var height: CGFloat = 0
        
        self.contents.forEach { content in
            
            let attributesText = content.text.setAttributesFitDetailLayout(style: .center)
            
            let rect = attributesText.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 38 - 38 , height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            
            if rect.height > height {
                height = rect.height
                
            }
        }
        
        return height
    }
    
    var formulaContentCellHeight: CGFloat {
        return contentLabelMaxHeight + 25 + 35 + 25 + 40
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





public class DiscoverFormula: AVObject, AVSubclassing {
    
    public class func parseClassName() -> String {
        return "DiscoverFormula"
    }
    
    @NSManaged var localObjectID: String
    
    @NSManaged var name: String
    
    @NSManaged var nickName: String
    
    @NSManaged var imageName: String
    
    @NSManaged var imageURL: String
    
    @NSManaged var isLibrary: Bool
    
    @NSManaged var serialNumber: Int
    
    @NSManaged var rating: Int
    
    @NSManaged var favorate: Bool
    
    @NSManaged var creator: AVUser?
    
    @NSManaged var contents: [DiscoverContent]
    
    @NSManaged var category: String
    
    @NSManaged var type: String
    
    @NSManaged var deletedByCreator: Bool
    
}


open class Content: Object {
    
    override open static func primaryKey() -> String? {
        return "localObjectID"
    }
    
    dynamic var localObjectID: String = ""
    dynamic var lcObjectID: String = ""
    
    dynamic var text: String = ""
    dynamic var rotation: String = ""
    dynamic var indicatorImageName: String = ""
    dynamic var cellHeight: CGFloat = 0
    dynamic var atFormula: Formula?
    dynamic var atFomurlaLocalObjectID: String = ""
    
    dynamic var creator: RUser?
    
    dynamic var deleteByCreator: Bool = false
    
}

open class DiscoverContent: AVObject, AVSubclassing {
    public class func parseClassName() -> String {
        return "DiscoverContent"
    }
    
    @NSManaged var localObjectID: String
    @NSManaged var text: String
    @NSManaged var rotation: String
    @NSManaged var indicatorImageName: String
    @NSManaged var atFormulaLocalObjectID: String
    @NSManaged var deletedByCreator: Bool
    
    @NSManaged var creator: AVUser
    
}

open class RUser: Object {
    
    dynamic var lcObjcetID: String = ""
    dynamic var localObjectID: String = ""
    dynamic var nickname: String?
    dynamic var username: String = ""
    dynamic var avatorImageURL: String?
    dynamic var introduction: String?
    
    let masterList = List<FormulaMaster>()
    
    
    
    open override static func indexedProperties() -> [String] {
        return ["userID"]
    }
    
    dynamic var leanCloudObjectID: String = ""
    
    func isMe() -> Bool {
        
        guard let currentUser = AVUser.current(), let userID = currentUser.objectId else {
            return false
        }
        
        return userID == self.lcObjcetID
        
    }
    
    
}

open class FormulaMaster: Object {
    /// 公式的本地ID
    dynamic var formulaLocalObjectID: String = ""
    /// 所属用户的 leancloudID
    dynamic var creatorLcObjectID: String = ""
}

public class DiscoverPreferences: AVObject, AVSubclassing {
    public class func parseClassName() -> String {
        return "DiscoverPreferences"
    }
    @NSManaged var version: String
}


open class Preferences: Object {
    // 未登录用户在登录成功时, 将其设置为 0.9
    dynamic var dateVersion: String = ""
}


open class RCategory: Object {
    
    dynamic var name = ""
    dynamic var uploadMode = ""
    
    func convertToCategory() -> Category {
        return Category(rawValue: name)!
    }
}

//class FormulaContent: CustomStringConvertible {
//    
//    var text: String?
//    var rotation: Rotation = Config.BaseRotation.FR
//    
//    var cellHeight: CGFloat {
//        
//        let height: CGFloat = 50
//        
//        if let text = text, text.characters.count > 0 {
//            
//            let attributesText = text.setAttributesFitDetailLayout(style: .center)
//            let rect = attributesText.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 60 - 20 , height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
//            
//            return rect.size.height + 30
//        }
//        
//        return height
//    }
//    
//    
//    
//    init() { }
//    
//    init(text: String, rotation: String) {
//        self.text = text
//        
//        switch rotation {
//            
//        case "FR":
//            self.rotation = Config.BaseRotation.FR
//            
//        case "FL":
//            self.rotation = Config.BaseRotation.FL
//            
//        case "BL":
//            self.rotation = Config.BaseRotation.BL
//            
//        case "BR":
//            self.rotation = Config.BaseRotation.BR
//            
//        default:
//            break
//            
//        }
//    }
//    
//    var description: String {
//        return "\(text) + \(rotation)"
//    }
//    
//    
//}


//public class Formula1: AVObject, AVSubclassing {
//
//    public class func parseClassName() -> String {
//        return "Formula"
//    }
//
//    @NSManaged var objectID: String
//
//    /// 判断是否是系统公式库中的公式
//    @NSManaged var isLibraryFormula: Bool
//
//    /// 公式库公式ID, 1..2..3..4..5..6,排序用. 用户创建的公式不需要此属性
//    @NSManaged var serialNumber: Int
//
//    ///名字
//    @NSManaged var name: String
//
//    var nickName: String {
//        return type.rawValue + "name"
//    }
//
//    var creatUserID: String = ""
//
//
//    ///图片名字
//    @NSManaged var imageName: String
//
//    ///评级
//    @NSManaged var rating: Int
//
//    ///是否收藏
//    @NSManaged var favorate: Bool
//
//    ///创建者
//    @NSManaged var creatUser: AVUser
//
//    /// 公式内容的文本信息
//    @NSManaged var contentsString: [String]
//
//
//    var contents: [FormulaContent] {
//
//        set {
//
//            self.contentsString =  newValue.map {
//
//                let text = $0.text ?? ""
//
//                var contentString = ""
//                switch $0.rotation {
//                case let .FR(imageName, _):
//                    contentString = imageName + "--" + text
//                case let .FL(imageName, _):
//                    contentString = imageName + "--" + text
//                case let .BL(imageName, _):
//                    contentString = imageName + "--" + text
//                case let .BR(imageName, _):
//                    contentString = imageName + "--" + text
//                }
//
//                return contentString
//
//            }
//        }
//
//        get {
//
//            var contents = [FormulaContent]()
//            for string in contentsString {
//                let stringArray = string.components(separatedBy: "--")
//                if stringArray.count == 2 {
//                    let rotation = stringArray[0]
//                    let text = stringArray[1]
//                    let content = FormulaContent(text: text, rotation: rotation)
//                    contents.append(content)
//                }
//            }
//            return contents
//        }
//    }
//
//
//    @NSManaged var categoryString: String
//
//    var category: Category {
//
//        set {
//            categoryString = newValue.rawValue
//        }
//
//        get {
//            return Category(rawValue: categoryString)!
//        }
//    }
//
//    @NSManaged var typeString: String
//
//    var type: Type {
//
//        set {
//            typeString = newValue.rawValue
//        }
//
//        get {
//            return Type(rawValue: typeString)!
//        }
//    }
//
//    override init() {
//
//        super.init()
//    }
//
//    /// 用户创建公式使用的
//    init(name: String, contents: [FormulaContent], imageName: String, favorate: Bool, category: Category, type: Type, rating: Int)
//    {
//        super.init()
//        self.isLibraryFormula = false
//        self.name = name
//        self.contents = contents
//        self.imageName = imageName
//        self.favorate = favorate
//        self.category = category
//        self.type = type
//        self.rating = rating
//        self.objectID = NSUUID().uuidString
//    }
//
//
//
//    /// 系统公式库创建所使用的.
//    init(name: String, contents: [FormulaContent], imageName: String, favorate: Bool, category: Category, type: Type, rating: Int, serialNumber: Int) {
//        super.init()
//        self.isLibraryFormula = false
//        self.name = name
//        self.contents = contents
//        self.imageName = imageName
//        self.favorate = favorate
//        self.category = category
//        self.type = type
//        self.rating = rating
//        self.serialNumber = serialNumber
//        self.objectID = NSUUID().uuidString
//    }
//
////    class func creatNewDefaultFormula() -> Formula {
////        return Formula(name: "", contents: [FormulaContent()], imageName: "cube_Placehold_image_1", favorate: false, category: .x3x3, type: .F2L, rating: 3)
////    }
//
//    override public var description: String {
//        get {
//            return "*********** \(self.name) ***********\n" + "catetory = \(category.rawValue)\n" + "content = \(contents) \n" + "imageName = \(imageName)\n" + "rating = \(rating)\n"  + "type = \(type)" + "-------------------------------"
//        }
//    }
//
//    /// 判断信息是否都正确填写
//    func isReadyforPushToLeanCloud() -> Bool {
//
//        var contentIsReady = false
//
//
//        // 如果contents的第一个text有值, 就可以
//        if let content = self.contents.first , let text = content.text {
//            contentIsReady = !text.isDirty
//        }
//
//        if name.isDirty || imageName.isDirty || typeString.isDirty || categoryString.isDirty  || !contentIsReady {
//
//            return false
//        }
//
//        return true
//    }
//
//    func prepareForPushToLeanCloud() {
//        //准备保存前, 将空白的 content 内容删除掉
//
//        var catchContents = self.contents
//
//        // 如果某一个创建的content其中的text isDirty, 是删除掉这个content
//        for (index, content) in catchContents.enumerated() {
//            if content.text?.isDirty ?? true {
//                catchContents.remove(at: index)
//            }
//        }
//
//        self.contents = catchContents
//    }
//
//
//    var contentLabelMaxHeight: CGFloat {
//
//        var height: CGFloat = 0
//
//        for (_, content) in contents.enumerated() {
//
//            if let text = content.text {
//
//                let attributesText = text.setAttributesFitDetailLayout(style: .center)
//                let rect = attributesText.boundingRect(with: CGSize(width: UIScreen.main.bounds.width - 38 - 38 , height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
//
//                if rect.height > height {
//                    height = rect.height
//                }
//
//            }
//        }
//
//        return height
//    }
//
//    var formulaContentCellHeight: CGFloat {
//
//        return contentLabelMaxHeight + 25 + 35 + 25 + 40
//    }
//
//
////    func copy(with zone: NSZone? = nil) -> Any {
////        let copy = Formula(name: name, contents: contents, imageName: imageName, favorate: favorate, category: category, type: type, rating: rating)
////        return copy
////    }
//
//}
//


