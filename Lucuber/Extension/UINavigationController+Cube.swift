//
//  UINavigationController+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/17.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    /// Find navigationBar's bottom line
    public var navigationBarLine: UIImageView {

        return navigationBarLine(view: self.navigationBar) as! UIImageView
    }
    
    public func navigationBarLine(view: UIView) -> UIView? {
        
        if view.isKind(of: UIImageView.classForCoder()) && view.bounds.size.height <= 1.0 {
            return view
        }
        
        for view in view.subviews {
            
            if let imageView = navigationBarLine(view: view) {
                return imageView
            }
        }
        
        return nil
    }
 
}
