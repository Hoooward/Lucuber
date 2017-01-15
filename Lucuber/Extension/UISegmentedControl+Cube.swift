//
//  UISegmentedControl+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/15.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit


extension UISegmentedControl {
    
    func setTitleFont(_ font: UIFont, withPadding padding: CGFloat) {
        
        let attributes = [NSFontAttributeName: font]
        
        setTitleTextAttributes(attributes, for: .normal)
        
        var maxWidth: CGFloat = 0
        
        for i in 0..<numberOfSegments {
            if let title = titleForSegment(at: i) {
                let width = (title as NSString).size(attributes: attributes).width + (padding * 2)
                maxWidth = max(maxWidth, width)
            }
        }
        
        for i in 0..<numberOfSegments {
            setWidth(maxWidth, forSegmentAt: i)
        }
    }
}
