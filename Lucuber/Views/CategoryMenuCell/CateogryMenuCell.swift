//
//  CateogryMenuCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class CategoryMenuCell: UITableViewCell {
    
    // MARK: Properties
    
    lazy var colorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
        return label
    }()
    
    
    lazy var checkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_location_checkmark"))
        return imageView
    }()
    
    var colorTitleLabelTextColor: UIColor = UIColor.cubeTintColor() {
        willSet {
            colorTitleLabel.textColor = newValue
        }
    }
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    // MARK: - Life Cycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor ( red: 0.9082, green: 0.9264, blue: 0.9317, alpha: 1.0 )
        selectedBackgroundView = backgroundView
        contentView.addSubview(colorTitleLabel)
        contentView.addSubview(checkImageView)
        colorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        tintColor = UIColor.cubeTintColor()
        
        do {
            let centerY = NSLayoutConstraint(item: colorTitleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
            let centerX = NSLayoutConstraint(item: colorTitleLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 20)
            
            NSLayoutConstraint.activate([centerY, centerX])
        }
        
        do {
            let centerY = NSLayoutConstraint(item: checkImageView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: checkImageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activate([centerY, trailing])
        }
    }
}

