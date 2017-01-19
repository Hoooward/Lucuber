//
//  MyFormulaVisitorController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/29.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Kingfisher

class MyFormulaVisitorView: UIView {
    
    private lazy var describeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.inputText()
        label.text = "点击右下角的 + 号按钮可以创建属于自己的复原公式，方便记忆与回顾。或者轻划进入 「公式库」，浏览 Lucuber 为你提供的复原公式。"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        return label
        
    }()
    
    private lazy var imageView: UIImageView = {
        var images: [UIImage] = []
        let imageView = UIImageView()
        imageView.image = UIImage(named: "lucuber_icon_solo")
        return imageView
        
    }()
    
    private lazy var indicatorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    private func imageViewAnimation() {
        imageView.alpha = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI() {
        
        addSubview(imageView)
        addSubview(describeLabel)
        addSubview(indicatorLabel)
        describeLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        indicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
//        let imageViewScale = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 1.1, constant: 0)
        
        let imageViewCenterX = NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        
        let imageViewCenterY = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -100)
        
//        let imageViewLeading = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 150)
        
//        let imageViewTrailing = NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -150)
        
        NSLayoutConstraint.activate([imageViewCenterX, imageViewCenterY])
        
        let indicatorLabelCenterX = NSLayoutConstraint(item: indicatorLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        
        let indicatorLabelTop = NSLayoutConstraint(item: indicatorLabel, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 20)
        
        NSLayoutConstraint.activate([indicatorLabelCenterX, indicatorLabelTop])
        
        
        let leading = NSLayoutConstraint.init(item: describeLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 40)
        
        let trailing = NSLayoutConstraint(item: describeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -40)
        
        let bottom = NSLayoutConstraint(item: describeLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -150)
        
        
        NSLayoutConstraint.activate([leading, trailing, bottom])
        
        
        imageView.startAnimating()
        
    }
    
    
    // MARK: - Action & Target
    
 
    
}











