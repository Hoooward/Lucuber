//
//  CanScrollsToTop.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/14.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import Foundation

protocol CanScrollsToTop: class {
    
    var scrollView: UIScrollView? { get }
    
    func scrollsToTopIfNeed(otherwise: (() -> Void)?)
}

extension CanScrollsToTop {
    
    func scrollsToTopIfNeed(otherwise: (() -> Void)? = nil) {
        
        guard let scrollView = scrollView else { return }
        
        if !scrollView.isAtTop {
            scrollView.customScrollsToTop()
            
        } else {
            otherwise?()
        }
    }
}
