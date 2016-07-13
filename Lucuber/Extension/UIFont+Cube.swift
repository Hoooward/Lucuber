//
//  UIFont+Cube.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import Foundation

extension UIFont {
    
    class func navigationBarTitleFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(17)
    }
    
    class func formulaLabelFont() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 12)!
    }
    
    class func cubeFormulaDefaultTextFont() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 12)!
    }
    
    class func cubeFormulaBracketsFont() -> UIFont {
        //Thonburi
        //Verdana
        return UIFont(name: "Menlo-Regular", size: 12)!
    }
    
    class func addFormulaPlaceholderTextFont() -> UIFont {
        return UIFont.systemFontOfSize(12)
    }
}
