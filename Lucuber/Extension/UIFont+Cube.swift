//
//  UIFont+Cube.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

extension UIFont {
    
    class func topControlButtonTitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    class func navigationBarTitleFont() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 17)
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
        return UIFont.systemFont(ofSize: 12)
    }
    
    class func feedCategoryButtonTitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 12)
    }
    
    class func feedMessageTextViewFont() -> UIFont {
        return UIFont.systemFont(ofSize: 17)
    }
    
    class func feedBottomLabelFont() -> UIFont {
        return UIFont.systemFont(ofSize: 14)
    }

}
