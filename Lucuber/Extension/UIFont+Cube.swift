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
    
    class func cubeFormulaNormalContentFont() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 12)!
    }
    
    class func cubeFormulaNormalBracketsFont() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 12)!
    }
    
    class func cubeFormulaDetailTextFont() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 14)!
    }
    
    class func cubeFormulaDetailBracketsFont() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 14)!
    }
    
    class func addFormulaPlaceholderTextFont() -> UIFont {
        return UIFont.systemFontOfSize(12)
    }
    
    class func feedCategoryButtonTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(12)
    }
    
    class func feedMessageTextViewFont() -> UIFont {
        return UIFont.systemFontOfSize(17)
    }
    
    class func feedBottomLabelFont() -> UIFont {
        return UIFont.systemFontOfSize(14)
    }

}