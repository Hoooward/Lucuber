//
//  UIFont+Cube.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

extension UIFont {
    
    class func topControlButtonTitle() -> UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    class func navigationBarTitle() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 17)
    }
    
    class func formulaNormalContent() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 12)!
    }
    
    class func formulaNormalBrackets() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 12)!
    }
    
    class func formulaDetailContent() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 18)!
    }
    
    class func formulaDetailBrackets() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 15)!
    }
    
    class func addFormulaPlaceholderText() -> UIFont {
        return UIFont.systemFont(ofSize: 12)
    }
    
    class func feedCategoryButtonTitle() -> UIFont {
        return UIFont.systemFont(ofSize: 12)
    }
    
    class func feedMessageTextView() -> UIFont {
        return UIFont.systemFont(ofSize: 17)
    }
    
    class func feedBottomLabel() -> UIFont {
        return UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
    }
    
    class func customKeyboardKeyTitle() -> UIFont {
        
        return UIFont(name: "Avenir Next", size: 18)!
    }
    
    public class func chatTextFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    public class func timerLabelFont() -> UIFont {
        return UIFont(name: "alarmclock", size: 90)!
    }
    
    public class func scoreLabelFont() -> UIFont {
       return UIFont(name: "alarmclock", size: 12)!
    }
    

}
