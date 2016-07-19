//
//  CategoryCheckCell.swift
//  Lucuber
//
//  Created by Howard on 7/19/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class CategoryCheckCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var colorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
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
            let centerY = NSLayoutConstraint(item: colorTitleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
            let centerX = NSLayoutConstraint(item: colorTitleLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1, constant: 20)
            
            NSLayoutConstraint.activateConstraints([centerY, centerX])
        }
        
        do {
            let centerY = NSLayoutConstraint(item: checkImageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: checkImageView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activateConstraints([centerY, trailing])
        }
    }
}
