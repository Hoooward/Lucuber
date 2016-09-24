//
//  FormulaInputViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit


class FormulaInputViewController: UIViewController {
    
    // MARK: - Properties
    
    private let keybuttonItemPackage = KeyButtonItemPackage.loadPackage()
    
    private var keyButtons: [KeyButton] = []
    
    private var keyButtonDidClicked: (KeyButton) -> ()
    
    
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

    
    // MARK: - Life Cycle
    
    init(keybuttonDidClicked: @escaping (KeyButton) -> ()) {
        self.keyButtonDidClicked = keybuttonDidClicked
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if topKeyboard.subviews.count == 0 || bottomKeyboard.subviews.count == 0 {
            makeTopKeyboardKeyButton()
            makeBottomKeyboardButton()
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
            button.item = keybuttonItemPackage.topKeyboardItems[index]
            button.addTarget(self, action: #selector(FormulaInputViewController.keyButtonDidClick(button:)), for: .touchUpInside)
            // TODO: - 添加删除按钮的持续点击
            if button.item!.type == .deleteKey {
                //                button.addTarget(self, action: #selector(FormulaInputViewController.keyButtonDidClick(_:)), forControlEvents: .TouchDown)
            }
            topKeyboard.addSubview(button)
            keyButtons.append(button)
        }
        
    }
    
    private func makeBottomKeyboardButton() {
        let buttonCount = 3
        let buttonWidth = topKeyboard.subviews.first!.frame.size.width
        let buttonHeight = bottomKeyHeight
        for index in 0..<buttonCount {
            let button = KeyButton()
            var frame = CGRect.zero
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
            button.item = keybuttonItemPackage.bottomKeyboardItems[index]
            button.addTarget(self, action: #selector(FormulaInputViewController.keyButtonDidClick(button:)), for: .touchUpInside)
            bottomKeyboard.addSubview(button)
            keyButtons.append(button)
        }
        
    }
    
    private func makeConstraints() {
        
        topKeyboard.translatesAutoresizingMaskIntoConstraints = false
        bottomKeyboard.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomKeyboardBottom = NSLayoutConstraint(item: bottomKeyboard, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        let bottomKeyboardBottomLeading = NSLayoutConstraint(item: bottomKeyboard, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let bottomKeyboardBottomTrailing = NSLayoutConstraint(item: bottomKeyboard, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomKeyboardHeight = NSLayoutConstraint(item: bottomKeyboard, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: bottomKeyHeight + bottomMargin)
        
        NSLayoutConstraint.activate([bottomKeyboardBottom, bottomKeyboardBottomLeading, bottomKeyboardBottomTrailing, bottomKeyboardHeight])
        
        let topKeyboardTop = NSLayoutConstraint(item: topKeyboard, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let topKeyboardLeading = NSLayoutConstraint(item: topKeyboard, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        let topKeyboardTrailing = NSLayoutConstraint(item: topKeyboard, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        let topKeyboardBottom = NSLayoutConstraint(item: topKeyboard, attribute: .bottom, relatedBy: .equal, toItem: bottomKeyboard, attribute: .top, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([topKeyboardTop, topKeyboardLeading, topKeyboardTrailing, topKeyboardBottom])
        
        
    }

    
    // MARK: - Action & Target 
    func keyButtonDidClick(button: KeyButton) {
        
        switch button.item!.type {
            
        case .shiftKey:
            button.isSelected = !button.isSelected
            keyButtons.forEach { $0.changeKeyButtonTitle() }
            
        default:
            keyButtonDidClicked(button)
        }
        
    }

    
    
    
    
}
