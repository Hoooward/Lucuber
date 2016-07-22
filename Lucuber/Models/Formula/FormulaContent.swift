//
//  FormulaText.swift
//  Lucuber
//
//  Created by Howard on 7/13/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

enum Rotation {
    case FR (String, String)
    case FL (String, String)
    case BL (String, String)
    case BR (String, String)
    
}

let FRrotation: Rotation = Rotation.FR("FR", "魔方的左下角朝向你, 点击输入公式。")
let FLrotation: Rotation = Rotation.FL("FL", "魔方的右下角朝向你, 点击输入公式。")
let BLrotation: Rotation = Rotation.BL("BL", "魔方的左上角朝向你, 点击输入公式。")
let BRrotation: Rotation = Rotation.BR("BR", "魔方的右上角朝向你, 点击输入公式。")

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
    
    
    var description: String {
        return "\(text) + \(rotation)"
    }
    
    
}
