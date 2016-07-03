//
//  LayoutButton.swift
//  Lucuber
//
//  Created by Howard on 16/7/2.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class LayoutButton: UIButton {

    var userMode: FormulaUserMode? {
        didSet {
            if let userMode = userMode {
                switch userMode {
                case .Normal:
                    selected = false
                case .Card:
                    selected = true
                }
//                UIView.animateWithDuration(1.0) {
//                    self.selected = userMode == .Normal ? false : true
//                }
            }
            
        }
    }
    
    
    init() {
        super.init(frame: CGRectZero)
        setImage(UIImage(named: "icon_list"), forState: .Normal)
        setImage(UIImage(named: "icon_minicard"), forState: .Selected)
        sizeToFit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
