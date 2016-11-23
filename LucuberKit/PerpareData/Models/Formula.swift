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

open class RCategory: Object {
    
    dynamic var name = ""
    dynamic var uploadMode = ""
    
    func convertToCategory() -> Category {
        return Category(rawValue: name)!
    }
}

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
}

open class Formula: Object {
    
    override open static func primaryKey() -> String? {
        return "localObjectID"
    }
    
    /// 名字
    dynamic var name: String = ""
    /// 本地生成 ID
    dynamic var localObjectID: String = ""
    /// Leancloud 生成 ID
    dynamic var lcObjectID: String = ""
    
    /// 本地 imageName
    dynamic var imageName: String = ""
    /// 图片URL
    dynamic var imageURL: String = ""
    
    /// 喜欢
    dynamic var favorate: Bool = false
    
    /// 三阶..四阶. 名字
    dynamic var categoryString: String = ""
    /// F2L, Cross 名字
    dynamic var typeString: String = ""
    
    /// 创建者
    dynamic var creator: RUser?
    
    
    /// 是否被作者删除
    dynamic var deletedByCreator: Bool = false
    
    /// 星级
    dynamic var rating: Int = 0
    
    /// 是否是系统公式
    dynamic var isLibrary: Bool = false
    
    /// 最后更新时间
    dynamic var updateUnixTime: TimeInterval = Date().timeIntervalSince1970
    
    /// 关联的 content
    let contents = LinkingObjects(fromType: Content.self, property: "atFormula")
    
    var category: Category {
        set { categoryString = newValue.rawValue }
        get { return Category(rawValue: categoryString)! }
    }
    
    var type: Type {
        set { typeString = newValue.rawValue }
        get { return Type(rawValue: typeString)! }
    }
    
//    dynamic var atFeed: Feed?

}

public class DiscoverFormula: AVObject, AVSubclassing {
    
    public class func parseClassName() -> String {
        return "DiscoverFormula"
    }
    
    @NSManaged var localObjectID: String
    
    @NSManaged var isLibrary: Bool
    
    @NSManaged var serialNumber: Int
    
    @NSManaged var name: String
    
    @NSManaged var nickName: String
    
    @NSManaged var imageName: String
    
    @NSManaged var imageURL: String
    
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
    dynamic var localObjectID: String = ""
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







