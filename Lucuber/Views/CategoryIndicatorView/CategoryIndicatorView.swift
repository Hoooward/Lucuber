//
//  CategoryIndicatorView.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class CategoryIndicatorView: UIButton {
    
    // MARK: - Properties
    
    enum Style {
        case kongxin
        case shixin
    }
    
    
    public var style: Style = .shixin
    
    private lazy var bubbleImageView: UIImageView = {
        return UIImageView(image: UIImage(named: "skill_bubble_small"))
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "三阶"
        return label
    }()
    
    
    // MARK: - Life Cycle
    
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
        
        let nameLabelCenterY = NSLayoutConstraint(item: nameLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let nameLabelCenterX = NSLayoutConstraint(item: nameLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        
        let nameLabelTrailing = NSLayoutConstraint(item: nameLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10)
        let nameLabelLeading = NSLayoutConstraint(item: nameLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 10)
        NSLayoutConstraint.activate([nameLabelCenterY, nameLabelCenterX, nameLabelTrailing, nameLabelLeading])
        
        let bubbleImageViewCenterY = NSLayoutConstraint(item: bubbleImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let bubbleImageViewLeading = NSLayoutConstraint(item: bubbleImageView, attribute: .leading, relatedBy: .equal, toItem: nameLabel, attribute: .leading, multiplier: 1, constant: -5)
        let bubbleImageViewTrailing = NSLayoutConstraint(item: bubbleImageView, attribute: .trailing, relatedBy: .equal, toItem: nameLabel, attribute: .trailing, multiplier: 1, constant: 5)
        
        NSLayoutConstraint.activate([bubbleImageViewCenterY, bubbleImageViewLeading, bubbleImageViewTrailing])
        
        layoutIfNeeded()
    }
    
    // MARK: - Action & Target
    
    func configureWithCategory(category: String) {
        nameLabel.text = category
        layoutIfNeeded()
    }
    
}
