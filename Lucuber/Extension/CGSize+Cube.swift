//
//  CGSize+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/8.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

extension CGSize {
    
    func ensureMinWidthOrHeight(_ value: CGFloat) -> CGSize {
        
        if width > height {
            
            if height < value {
                
                let ratio = height / value
                return CGSize(width: floor(width / ratio), height: value)
            }
        } else {
            
            if width < value {
                
                let ratio = width / value
                return CGSize(width: value, height: floor(height / ratio))
            }
            
        }
        
        return self
    }
    
}

