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



public enum Type: String {
    /// 三阶
    case CROSS = "Cross"
    case F2L = "F2L"
    case PLL = "PLL"
    case OLL = "OLL"
    
}


 class DiscoverFormula: AVObject, AVSubclassing {
    
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
    
    @NSManaged var contents: [String]
    
    @NSManaged var category: String
    
    @NSManaged var type: String
    
    @NSManaged var deletedByCreator: Bool
   

    
    
}







