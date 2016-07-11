//
//  CubeCategoryItemView.swift
//  Lucuber
//
//  Created by Howard on 16/7/7.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit
class CubeCategoryItemView: UIView {
    
    lazy var bubbleImageView: UIImageView = {
        return UIImageView(image: UIImage(named: "skill_bubble"))
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.sizeToFit()
        label.text = "3x3x3"
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

        NSLayoutConstraint.activateConstraints([nameLabelCenterY, nameLabelCenterX])
        
        let bubbleImageViewCenterY = NSLayoutConstraint(item: bubbleImageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let bubbleImageViewLeading = NSLayoutConstraint(item: bubbleImageView, attribute: .Leading, relatedBy: .Equal, toItem: nameLabel, attribute: .Leading, multiplier: 1, constant: -10)
        let bubbleImageViewTrailing = NSLayoutConstraint(item: bubbleImageView, attribute: .Trailing, relatedBy: .Equal, toItem: nameLabel, attribute: .Trailing, multiplier: 1, constant: 10)
        
        NSLayoutConstraint.activateConstraints([bubbleImageViewCenterY, bubbleImageViewLeading, bubbleImageViewTrailing])
    }
    

    func configureWithCategory(category: String) {
        nameLabel.text = category
    }
}
