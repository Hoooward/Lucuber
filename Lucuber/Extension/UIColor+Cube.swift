//
//  UIColor+Lu.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func masterLabelText() -> UIColor {
        
        return UIColor.lightGray
    }
    
    class func topControlButtonNormalTitle() -> UIColor {
        return UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    }
    
    class func navgationBarTitle() -> UIColor {
        return UIColor(red: 0.247, green: 0.247, blue: 0.247, alpha: 1.0)
    }

    class func cubeTintColor() -> UIColor {
        return UIColor(red: 50/255.0, green: 167/255.0, blue: 255/255.0, alpha: 1.0)
    }
    class func cubeViewBackground() -> UIColor {
        return UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    }
    class func inputText() -> UIColor {
        return UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1.0)
    }
  
    class func formulaDetailText() -> UIColor {
        return UIColor.black
    }

    class func cubeBorderColor() -> UIColor {
        return UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
    }
    
    class func formulaDetailNumber() -> UIColor {
        return UIColor ( red: 0.8913, green: 0.3546, blue: 0.3997, alpha: 1.0 )
    }
    
    class func formulaDetailBrackets() -> UIColor {
        return UIColor ( red: 0.19, green: 0.3577, blue: 0.4382, alpha: 1.0 )
    }
    
    class func formulaNormalText() -> UIColor {
        return UIColor ( red: 0.5039, green: 0.5039, blue: 0.5039, alpha: 1.0 )
    }
    
    class func formulaNormalNumber() -> UIColor {
         return UIColor ( red: 0.8913, green: 0.3546, blue: 0.3997, alpha: 1.0 )
    }
    
    class func formulaNormalBrackets() -> UIColor {
         return UIColor ( red: 0.1473, green: 0.2855, blue: 0.3624, alpha: 0.5 )
    }
    
    class func addFormulaNotActive() -> UIColor {
//        return UIColor (red: 0.6667, green: 0.6667, blue: 0.6667, alpha: 1.0 )
        return UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1)
    }
    
    class func addFormulaActive() -> UIColor {
        return UIColor ( red: 0.7843, green: 0.1412, blue: 0.2275, alpha: 1.0 )
    }
    
    class func addFormulaPlaceholderText() -> UIColor {
        return UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    }
    
    class func cellSeparator() -> UIColor {
        return UIColor.lightGray.withAlphaComponent(0.3)
    }
    
    class func messageColor() -> UIColor {
        return UIColor(red: 64/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1.0)
    }
    
    class func cubeBackgroundColor() -> UIColor {
        return UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
    }
    
    class func inputAccessoryPlaceholderColor() -> UIColor {
        return UIColor(red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0)
    }
    
    class func customKeyboardKeyTitle() -> UIColor {
        return UIColor(red: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
    }
    
    class func cubeGrayColor() -> UIColor {
        return UIColor(red: 142.0/255.0, green: 142.0/255.0, blue: 147.0/255.0, alpha: 1.0)
    }
    
    class func leftBubbleTintColor() -> UIColor {
        return UIColor(white: 231 / 255.0, alpha: 1.0)
    }
    
    class func rightBubbleTintColor() -> UIColor {
        return UIColor.cubeTintColor()
    }
    
    class func messageToolbarSubViewBoderColor() -> UIColor {
        return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
    }
    
    class func messageToolbarColor() -> UIColor {
        return UIColor(red: 0.557, green: 0.557, blue: 0.556, alpha: 1)
    }
    
    class func timeControlViewIndicatorLabel() -> UIColor {
        return UIColor.white
    }
    
    // MARK: - ScoreGroup
    
    class func scoreGroupFastestLabelTextColor() -> UIColor {
        return UIColor(red: 241/255.0, green: 90/255.0, blue: 74/255.0, alpha: 1)
    }
    
    class func scoreGroupSlowliestLabelTextColor() -> UIColor {
        return UIColor(red: 22/255.0, green: 184/255.0, blue: 115/255.0, alpha: 1)
    }
    
    
    class func scoreGroupDNFLabelTextColor() -> UIColor {
        return UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
    }
    
    class func scoreGroupNormalLabelTextColor() -> UIColor {
        return timerLabelTextColor()
    }
    
    // MARK: - TimerLabel
    class func timerLabelTextColor() -> UIColor {
        return UIColor(red: 60/255.0, green: 77/255.0, blue: 95/255.0, alpha: 1)
    }
    
    
}

