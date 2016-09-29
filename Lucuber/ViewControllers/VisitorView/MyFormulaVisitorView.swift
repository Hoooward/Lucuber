//
//  MyFormulaVisitorController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/29.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class MyFormulaVisitorView: UIView {
    
    // MARK: - Properties
    
    private lazy var describeLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.inputText()
        label.text = "点击右下角的 + 号按钮可以创建属于自己的复原公式，方便记忆与回顾。或者轻划进入 「公式库」，浏览 Lucuber 为你提供的复原公式。"
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        return label
        
    }()
    
    
    
    
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI() {
        
        
        addSubview(describeLabel)
        describeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let leading = NSLayoutConstraint.init(item: describeLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 40)
        
        let trailing = NSLayoutConstraint(item: describeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -40)
        
        let bottom = NSLayoutConstraint(item: describeLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -150)
        
        
        NSLayoutConstraint.activate([leading, trailing, bottom])
        
    }
    
    
    // MARK: - Action & Target
    
    
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        
//        return nil
//    }
//    
    
    
    
    
    
    
    
    
    
    
}











