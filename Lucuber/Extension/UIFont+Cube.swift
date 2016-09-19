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
        return UIFont(name: "Menlo-Regular", size: 14)!
    }
    
    class func formulaDetailBrackets() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 14)!
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
        return UIFont.systemFont(ofSize: 14)
    }

}
