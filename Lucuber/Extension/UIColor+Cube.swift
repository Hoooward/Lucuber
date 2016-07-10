//
//  UIColor+Lu.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func cubeTintColor() -> UIColor {
        return UIColor(red: 50/255.0, green: 167/255.0, blue: 255/255.0, alpha: 1.0)
    }
    class func cubeViewBackgroundColor() -> UIColor {
        return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    }
    class func cubeInputTextColor() -> UIColor {
        return UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1.0)
    }
    class func cubeFormulaBracketsColor() -> UIColor {
//        return UIColor ( red: 0.669, green: 0.7313, blue: 0.9489, alpha: 1.0 )
        return cubeTintColor()
    }
    class func cubeFormulaDefaultTextColor() -> UIColor {
//        return UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1.0)
        return UIColor.blackColor()
    }
    
    class func cubeFormulaNumberColor() -> UIColor {
        return UIColor ( red: 0.8913, green: 0.3546, blue: 0.3997, alpha: 1.0 )
    }
}
    
