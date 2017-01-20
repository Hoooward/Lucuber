//
//  TopControl.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class TopControl: UIView {
    
    // MARK: - Properties
    var seletedButton: UIButton?
    
    var buttonCount: Int = 0
    var buttonWidth: CGFloat = 0
    
    var buttonClickedUpdateIndicaterPoztion: ((Int) -> Void)?
    var updateNewFormulaButtonPoztion: (() -> Void)?
    
    private lazy var indicaterView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.cubeTintColor()
        view.height = Config.TopControl.indicaterHeight
        view.y = Config.TopControl.height - Config.TopControl.indicaterHeight
        view.tag = -1
        return view
        
    }()
    
    private lazy var backgroundView: UIImageView = UIImageView()

    
    // MARK: - Lift Cycle
    
    init(childViewControllers: [UIViewController]) {
        
        super.init(frame: CGRect.zero)
        
        buttonCount = childViewControllers.count
        buttonWidth = UIScreen.main.bounds.width / CGFloat(childViewControllers.count)
        
        makeUI(childViewControllers)
    }
    
    private func makeUI(_ childViewControllers: [UIViewController]) {
        
        backgroundView.backgroundColor = UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1)
        let buttonHeight: CGFloat = Config.TopControl.height
        var buttonX: CGFloat = 0
        
        for index in 0..<childViewControllers.count {
            
            let button = UIButton(type: .custom)
            button.tag = index + Config.TopControl.buttonTagBaseValue
            button.setTitle(childViewControllers[index].title, for: .normal)
            button.titleLabel?.font = UIFont.topControlButtonTitle()
            button.setTitleColor(UIColor.topControlButtonNormalTitle(), for: .normal)
            button.setTitleColor(UIColor.cubeTintColor(), for: .disabled)
            buttonX = buttonWidth * CGFloat(index)
            button.frame = CGRect(x: buttonX, y: 0, width: buttonWidth, height: buttonHeight)
            button.addTarget(self, action: #selector(TopControl.buttonClicked(button:)), for: .touchUpInside)
            self.addSubview(button)
            
            if index == 0 {
                
                seletedButton = button
                button.isEnabled = false
                button.layoutIfNeeded()
                indicaterView.x = button.width * 0.3
                indicaterView.width = button.width * 0.4
            }
        }
        
//        backgroundView.image = UIImage(named: "navigationbarBackgroundWhite")
        backgroundView.backgroundColor = UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1)
        
        self.insertSubview(backgroundView, at: 0)
        self.addSubview(indicaterView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Target & Action
    
    func updateIndicaterPozition(scrollerViewOffsetX: CGFloat) {
        
        let scale = (CGFloat(buttonCount - 1) * UIScreen.main.bounds.width) / (UIScreen.main.bounds.width - buttonWidth)
        indicaterView.center.x = scrollerViewOffsetX / scale + (buttonWidth * 0.5)
        
        updateNewFormulaButtonPoztion?()

    }
    
    func updateButtonStatus(scrollerViewOffsetX: CGFloat) {
        
        let index = Int(scrollerViewOffsetX / UIScreen.main.bounds.width)
        
        if let button = viewWithTag(index + Config.TopControl.buttonTagBaseValue) as? UIButton {
            buttonClicked(button: button)
        }
        
    }
    
    @objc private func buttonClicked(button: UIButton) {
        
        seletedButton?.isEnabled = true
        button.isEnabled = false
        seletedButton = button
        
        buttonClickedUpdateIndicaterPoztion?(button.tag)
        
    }
    
    
    
}
