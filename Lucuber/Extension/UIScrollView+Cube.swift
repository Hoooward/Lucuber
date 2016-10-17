//
//  UIScrollView+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/16.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    var isAtTop: Bool {
        
        return contentOffset.y == -contentInset.top
    }
    
    func customScrollsToTop() {
        
        let topPoint = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topPoint, animated: true)
    }
}
