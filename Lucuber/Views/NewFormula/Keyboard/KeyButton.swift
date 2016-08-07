//
//  KeyButton.swift
//  Lucuber
//
//  Created by Howard on 16/7/9.
//  Copyright © 2016年 Howard. All rights reserved.
//

import Foundation
class KeyButton: UIButton {
    var item: KeyButtonItem? {
        didSet {
            if let item = item {
                switch item.type {
                case .Default, .Number:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardDefault"), forState: .Normal)
                    setTitle(item.showTitle, forState: .Normal)
                case .Bracket:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardBrackets"), forState: .Normal)
                    setTitle(item.showTitle, forState: .Normal)
                    setTitleColor(UIColor.whiteColor(), forState: .Normal)
                case .Delete:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardDelete"), forState: .Normal)
                case .Shift:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardShift"), forState: .Selected)
                    setBackgroundImage(UIImage(named: "FormulaKeyboardShiftSeleted"), forState: .Normal)
                case .Space:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardSpace"), forState: .Normal)
                case .Return:
                    setBackgroundImage(UIImage(named: "FormulaKeyboardReturn"), forState: .Normal)
                }
            }
        }
    }
    
    //切换大小写
    func changeKeyButtonTitle() {
        if let item = item {
            //修改按钮的大小写状态
            item.status = item.status == .Captal ? .Lower : .Captal
            switch item.type {
            case .Default:
                setTitle(item.showTitle, forState: .Normal)
            default:
                break
            }
        }
    }
    
    init() {
        super.init(frame: CGRectZero)
        setTitleColor(UIColor(red: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1), forState: .Normal)
        setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        titleLabel?.font = UIFont(name: "Avenir Next", size: 18)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}