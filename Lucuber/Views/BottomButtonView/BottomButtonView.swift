//
//  BottomButtonView.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/11.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit


final class BottomButtonView: UIView {

    @IBInspectable var topLineColor: UIColor = UIColor.cubeBorderColor()
    @IBInspectable var topLineWidth: CGFloat = 1 / UIScreen.main.scale
    @IBInspectable var title: String = ""  {
        didSet {
            actionButton.setTitle(title, for: .normal)
        }
        
    }
    
    lazy var actionButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(self.title, for: .normal)
        button.backgroundColor = UIColor.cubeTintColor()
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(BottomButtonView.tap), for: .touchUpInside)
        return button
    }()
    

    public var tapAction: (() -> Void)?
    
    func tap() {
        tapAction?()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        backgroundColor = UIColor.white
        
        addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        let actionButtonCenterXConstraint = NSLayoutConstraint(item: actionButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        
        let actionButtonCenterYConstraint = NSLayoutConstraint(item: actionButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        let actionButtonWidthConstraint = NSLayoutConstraint(item: actionButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 185)
        
        let actionButtonHeightConstraint = NSLayoutConstraint(item: actionButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
        
        let constraints: [NSLayoutConstraint] = [
            actionButtonCenterXConstraint,
            actionButtonCenterYConstraint,
            actionButtonWidthConstraint,
            actionButtonHeightConstraint,
            ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        topLineColor.setStroke()
        let context = UIGraphicsGetCurrentContext()
        
        context!.setLineWidth(topLineWidth)
        context!.move(to: CGPoint(x: 0, y: 0))
        context!.addLine(to: CGPoint(x: rect.width, y: 0))
        context!.strokePath()
    }
}
