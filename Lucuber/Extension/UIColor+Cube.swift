//
//  UIColor+Lu.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func cubeTopControlButtonNormalTitleColor() -> UIColor {
        return UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    }
    
    class func cubeNavgationBarTitleColor() -> UIColor {
        return UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha: 1.0)
    }

    class func cubeTintColor() -> UIColor {
        return UIColor(red: 50/255.0, green: 167/255.0, blue: 255/255.0, alpha: 1.0)
    }
    class func cubeViewBackgroundColor() -> UIColor {
        return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    }
    class func cubeInputTextColor() -> UIColor {
        return UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1.0)
    }
  
    class func cubeFormulaDetailTextColor() -> UIColor {
        
        return UIColor.black
    }
    
    class func cubeFormulaDetailNumberColor() -> UIColor {
        return UIColor ( red: 0.8913, green: 0.3546, blue: 0.3997, alpha: 1.0 )
    }
    
    class func cubeFormulaDetailBracketsColor() -> UIColor {
        return UIColor ( red: 0.19, green: 0.3577, blue: 0.4382, alpha: 1.0 )
    }
    
    class func cubeFormulaNormalTextColor() -> UIColor {
        return UIColor ( red: 0.5039, green: 0.5039, blue: 0.5039, alpha: 1.0 )
    }
    
    class func cubeFormulaNormalNumberColor() -> UIColor {
         return UIColor ( red: 0.8913, green: 0.3546, blue: 0.3997, alpha: 1.0 )
    }
    
    class func cubeFormulaNormalBracketsColor() -> UIColor {
         return UIColor ( red: 0.1473, green: 0.2855, blue: 0.3624, alpha: 0.5 )
    }
    
    class func addFormulaNotActiveColor() -> UIColor {
        return UIColor ( red: 0.6667, green: 0.6667, blue: 0.6667, alpha: 1.0 )
    }
    
    class func addFormulaActiveColor() -> UIColor {
        return UIColor ( red: 0.7843, green: 0.1412, blue: 0.2275, alpha: 1.0 )
    }
    
    class func addFormulaPlaceholderTextColor() -> UIColor {
        return UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    }
    
    class func cubeCellSeparatorColor() -> UIColor {
        return UIColor.lightGray.withAlphaComponent(0.3)
    }
    
    class func cubeMessageColor() -> UIColor {
        return UIColor(red: 64/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1.0)
    }
    
    class func cubeBackgroundColor() -> UIColor {
        return UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
    }
}

