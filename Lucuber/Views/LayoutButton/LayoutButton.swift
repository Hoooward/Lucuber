//  LayoutButton.swift
//  Formula 界面左上角的切换布局按钮
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class LayoutButton: UIButton {
    
    var userMode: FormulaUserMode? {
        
        didSet {
        if let mode = userMode {
            
            switch mode {
                
            case .Normal:
                isSelected = false
                
            case .Card:
                isSelected = true
                
            }
        }
            
        }
    }
    
     init() {
        super.init(frame: CGRect.zero)
        setImage(UIImage(named: "icon_list"), for: .normal)
        setImage(UIImage(named: "icon_minicard"), for: .selected)
        sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
