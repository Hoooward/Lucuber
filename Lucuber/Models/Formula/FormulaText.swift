//
//  FormulaText.swift
//  Lucuber
//
//  Created by Howard on 7/13/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaContent: CustomStringConvertible {
    
    enum Rotation {
        case FR
        case FL
        case BL
        case BR
    }
    
    var text: String?
    var rotation: Rotation = Rotation.FR
    
    var cellHeight: CGFloat {
        let height: CGFloat = 40
        
        if let text = text where text.characters.count > 0 {
            let attributes = [
                NSForegroundColorAttributeName: UIColor.cubeFormulaDefaultTextColor(),
                NSFontAttributeName: UIFont.cubeFormulaDefaultTextFont()]
            let rect =  (text as NSString).boundingRectWithSize(CGSize(width: screenWidth, height: screenHeight), options: NSStringDrawingOptions.init(rawValue: 0), attributes: attributes, context: nil)
            
            return rect.size.height + 20
        }
        
        return height
    }
    
    
    var description: String {
        return "\(text) + \(rotation)"
    }
    
    
}
