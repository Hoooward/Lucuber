//
//  FormulaText.swift
//  Lucuber
//
//  Created by Howard on 7/13/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

/// 第一个参数是 imageName 第二个参数是 placeholder
enum Rotation {
    
    case FR (String, String)
    case FL (String, String)
    case BL (String, String)
    case BR (String, String)
    
}
//魔方整体顺时针旋转 90° 的状态
//魔方整体顺时针旋转 180° 的状态
//魔方整体顺时针旋转 270° 的状态



let FRrotation: Rotation = Rotation.FR("FR", "图例的状态")
let FLrotation: Rotation = Rotation.FL("FL", "魔方整体顺时针旋转 90° 的状态")
let BLrotation: Rotation = Rotation.BL("BL", "魔方整体顺时针旋转 180° 的状态")
let BRrotation: Rotation = Rotation.BR("BR", "魔方整体顺时针旋转 270° 的状态")

let defaultRotations = [FRrotation, FLrotation, BLrotation, BRrotation]

class FormulaContent: CustomStringConvertible {
    
    
    var text: String?
    var rotation: Rotation = FRrotation
    
    var cellHeight: CGFloat {
        let height: CGFloat = 40
        
        let margin = CubeConfig.DetailFormula.screenMargin
        if let text = text where text.characters.count > 0 {
             let attributsStr = text.setAttributesFitDetailLayout(ContentStyle.Detail)
            let rect =  attributsStr.boundingRectWithSize(CGSizeMake(screenWidth - margin - margin - 25 - 15, CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.init(rawValue: 1),  context: nil)
            
//            print("formula.cellHeight = ", rect.size.height + 30)
            return rect.size.height + 30
        }
        
        return height
    }
    
    init() {
        
    }
    
    init(text: String, rotation: String) {
        self.text = text
        
        switch rotation {
            
        case "FR":
            self.rotation = FRrotation
            
        case "FL":
            self.rotation = FLrotation
            
        case "BL":
            self.rotation = BLrotation
            
        case "BR":
            self.rotation = BRrotation
            
        default:
            break
            
        }
    }
    
    var description: String {
        return "\(text) + \(rotation)"
    }
    
    
}
