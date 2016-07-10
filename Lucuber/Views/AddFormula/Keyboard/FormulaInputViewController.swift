//
//  FormulaInputViewController.swift
//  Lucuber
//
//  Created by Howard on 16/7/9.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit


class FormulaInputViewController: UIViewController {
    
    let keyButtonItemPackage = KeyButtonItemPackage.loadPackage()
    var KeyButtons: [KeyButton] = []
    
    var keyButtonDidClickedCallBack: (keybutton: KeyButton) -> ()
    
    init(keyButtonCallBack: (text: KeyButton) -> ()) {
        keyButtonDidClickedCallBack = keyButtonCallBack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topKeyboard)
        view.addSubview(bottomKeyboard)
        makeConstraints()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        makeTopKeyboardKeyButton()
        makeBottomKeyboardButton()
    }
    
    func keyButtonDidClick(button: KeyButton) {
        switch button.item!.type {
        case .Shift:
            button.selected = !button.selected
            KeyButtons.forEach { $0.changeKeyButtonTitle() }
        default:
            keyButtonDidClickedCallBack(keybutton: button)
        }
        
    }
    
    let buttonMargin: CGFloat = 10
    let screenMargin: CGFloat = 5
    private func makeTopKeyboardKeyButton() {
        let buttonCount = 21
        
        let colCount = 7
        let rowCount = 3
        var buttonX: CGFloat = 0
        var buttonY: CGFloat = 0
        
        let buttonWidth: CGFloat = ((topKeyboard.frame.size.width - screenMargin * 2) - (buttonMargin * CGFloat(colCount - 1))) / CGFloat(colCount)
        let buttonHeight: CGFloat = ((topKeyboard.frame.size.height - screenMargin * 2) - (buttonMargin * CGFloat(rowCount - 1))) / CGFloat(rowCount)
        
        for index in 0..<buttonCount {
            let button = KeyButton()
            let row = index / colCount
            let col = index % colCount
            buttonX = (buttonWidth + buttonMargin) * CGFloat(col) + screenMargin
            buttonY = (buttonHeight + buttonMargin) * CGFloat(row) + screenMargin
            let frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)
            button.frame = frame
            button.item = keyButtonItemPackage.topKeyboardItems[index]
            button.addTarget(self, action: #selector(FormulaInputViewController.keyButtonDidClick(_:)), forControlEvents: .TouchUpInside)
            // TODO: - 添加删除按钮的持续点击
            if button.item!.type == .Delete {
//                button.addTarget(self, action: #selector(FormulaInputViewController.keyButtonDidClick(_:)), forControlEvents: .TouchDown)
            }
            topKeyboard.addSubview(button)
            KeyButtons.append(button)
        }
        
    }
    
    private func makeBottomKeyboardButton() {
        let buttonCount = 3
        let buttonWidth = topKeyboard.subviews.first!.frame.size.width
        let buttonHeight = bottomKeyHeight
        for index in 0..<buttonCount {
            let button = KeyButton()
            var frame = CGRectZero
            if index == 0 {
                frame = CGRect(x: screenMargin , y: 2, width: buttonWidth * 2 + buttonMargin, height: buttonHeight)
            }
            if index == 1 {
                frame = CGRect(x: screenMargin + buttonWidth * 2 + buttonMargin * 2, y: 2, width: (buttonWidth * 3 + buttonMargin * 2) , height: buttonHeight)
            }
            if index == 2 {
                frame = CGRect(x: screenMargin + buttonWidth * 5 + buttonMargin * 5, y: 2, width: (buttonWidth * 2 + buttonMargin), height: buttonHeight)
            }
            button.frame = frame
            button.item = keyButtonItemPackage.bottomKeyboardItems[index]
            button.addTarget(self, action: #selector(FormulaInputViewController.keyButtonDidClick(_:)), forControlEvents: .TouchUpInside)
            bottomKeyboard.addSubview(button)
            KeyButtons.append(button)
        }
        
    }

    private func makeConstraints() {
    
        topKeyboard.translatesAutoresizingMaskIntoConstraints = false
        bottomKeyboard.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomKeyboardBottom = NSLayoutConstraint(item: bottomKeyboard, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        let bottomKeyboardBottomLeading = NSLayoutConstraint(item: bottomKeyboard, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
        let bottomKeyboardBottomTrailing = NSLayoutConstraint(item: bottomKeyboard, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
        let bottomKeyboardHeight = NSLayoutConstraint(item: bottomKeyboard, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: bottomKeyHeight + bottomMargin)

        NSLayoutConstraint.activateConstraints([bottomKeyboardBottom, bottomKeyboardBottomLeading, bottomKeyboardBottomTrailing, bottomKeyboardHeight])
        
        let topKeyboardTop = NSLayoutConstraint(item: topKeyboard, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let topKeyboardLeading = NSLayoutConstraint(item: topKeyboard, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        let topKeyboardTrailing = NSLayoutConstraint(item: topKeyboard, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0)
        let topKeyboardBottom = NSLayoutConstraint(item: topKeyboard, attribute: .Bottom, relatedBy: .Equal, toItem: bottomKeyboard, attribute: .Top, multiplier: 1, constant: 0)
        NSLayoutConstraint.activateConstraints([topKeyboardTop, topKeyboardLeading, topKeyboardTrailing, topKeyboardBottom])
        
  
    }
    
    private lazy var topKeyboard: UIView = {
        [unowned self] in
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        return backgroundView
        
    }()
    
    let bottomKeyHeight: CGFloat = 40.0
    let bottomMargin: CGFloat = 5
    private lazy var bottomKeyboard: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        return backgroundView
    }()


}


