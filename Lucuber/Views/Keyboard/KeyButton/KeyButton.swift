//
//  KeyButton.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class KeyButton: UIButton {
    
    var item: KeyButtonItem? {
        
        didSet {
            
            if let item = item {
                
                switch item.type {
                    
                case .defaultKey, .numberKey:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardDefault"), for: .normal)
                    setTitle(item.showTitle, for: .normal)
                    
                case .bracketKey:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardBrackets"), for: .normal)
                    setTitle(item.showTitle, for: .normal)
                    setTitleColor(UIColor.white, for: .normal)
                    
                case .deleteKey:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardDelete"), for: .normal)
                    
                case .shiftKey:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardShift"), for: .selected)
                    setBackgroundImage(UIImage(named: "FormulaKeyboardShiftSeleted"), for: .normal)
                    
                case .spaceKey:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardSpace"), for: .normal)
                    
                case .returnKey:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardReturn"), for: .normal)
                }
            }
        }
    }
    
    //切换大小写
    func changeKeyButtonTitle() {
        if let item = item {
            //修改按钮的大小写状态
            item.status = item.status == .captal ? .lower : .captal
            switch item.type {
            case .defaultKey:
                setTitle(item.showTitle, for: .normal)
            default:
                break
            }
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        setTitleColor(UIColor.customKeyboardKeyTitle(), for: .normal)
        setTitleColor(UIColor.white, for: .highlighted)
        titleLabel?.font = UIFont.customKeyboardKeyTitle()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
