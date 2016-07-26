//
//  FormulaTypeIndicaterView.swift
//  Lucuber
//
//  Created by Howard on 7/11/16.
//  Copyright © 2016 Howard. All rights reserved.
//  显示在cell中的公式类型View

import UIKit

class CategoryIndicaterView: UIButton {

    lazy var bubbleImageView: UIImageView = {
        return UIImageView(image: UIImage(named: "skill_bubble_small"))
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(10)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.sizeToFit()
        label.text = "三阶"
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    private func makeUI() {
        addSubview(bubbleImageView)
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabelCenterY = NSLayoutConstraint(item: nameLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let nameLabelCenterX = NSLayoutConstraint(item: nameLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        
        let nameLabelTrailing = NSLayoutConstraint(item: nameLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -10)
        let nameLabelLeading = NSLayoutConstraint(item: nameLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 10)
        NSLayoutConstraint.activateConstraints([nameLabelCenterY, nameLabelCenterX, nameLabelTrailing, nameLabelLeading])
        
        let bubbleImageViewCenterY = NSLayoutConstraint(item: bubbleImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let bubbleImageViewLeading = NSLayoutConstraint(item: bubbleImageView, attribute: .Leading, relatedBy: .Equal, toItem: nameLabel, attribute: .Leading, multiplier: 1, constant: -5)
        let bubbleImageViewTrailing = NSLayoutConstraint(item: bubbleImageView, attribute: .Trailing, relatedBy: .Equal, toItem: nameLabel, attribute: .Trailing, multiplier: 1, constant: 5)
        
        NSLayoutConstraint.activateConstraints([bubbleImageViewCenterY, bubbleImageViewLeading, bubbleImageViewTrailing])
        
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    func configureWithCategory(category: String) {
        nameLabel.text = category
        layoutIfNeeded()
    }

}
