//
//  ActionSheetView.swift
//  Lucuber
//
//  Created by Howard on 7/15/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

// MARK: - ActionSheetDefaultCell

final private class ActionSheetDefailtCell: UITableViewCell {
    
    class var reuseIdentifier: String? {
        return "\(self)"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var colorTitlelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        return label
    }()
    
    var colorTitleLabeltextColor: UIColor = UIColor.cubeTintColor() {
        willSet {
            colorTitlelabel.textColor = newValue
        }
    }
    
    func makeUI() {
        
        contentView.addSubview(colorTitlelabel)
        colorTitlelabel.translatesAutoresizingMaskIntoConstraints = false
        
        let centerY = NSLayoutConstraint(item: colorTitlelabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: colorTitlelabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([centerX, centerY])
    }
}

// MARK: - ACtionSheetDetailCell

final private class ActionSheetDetailCell: UITableViewCell {
    
    class var reuseIdentifier: String? {
        return "\(self)"
    }
   
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .DisclosureIndicator
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        textLabel?.textColor = UIColor.darkGrayColor()
        textLabel?.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ActionSheetSwitchCell 

final private class ActionSheetSwitchCell: UITableViewCell {
    
    class var reuseIdentifier: String? {
        return "\(self)"
    }
    
    var action: (Bool -> Bool)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        textLabel?.textColor = UIColor.darkGrayColor()
        textLabel?.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var checkedSwitch: UISwitch = {
        let s = UISwitch()
        s.addTarget(self, action: #selector(ActionSheetSwitchCell.toggleSwitch(_:)), forControlEvents: .ValueChanged)
        return s
    }()
    
    @objc func toggleSwitch(sender: UISwitch) {
        action?(sender.on)
    }
    
    func makeUI() {
        contentView.addSubview(checkedSwitch)
        checkedSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let centerY = NSLayoutConstraint(item: checkedSwitch, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: checkedSwitch, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -20)
        
        NSLayoutConstraint.activateConstraints([centerY, trailing])
    }
    
}


final private class ActionSheetSubtitleSwitchCell: UITableViewCell {
    
    class var reuseIdentifier: String? {
        return "\(self)"
    }
    
    var action: (Bool -> Bool)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        makeUI()
            
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(19, weight: UIFontWeightLight)
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(10, weight: UIFontWeightLight)
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
    
    
    lazy var checkedSwitch: UISwitch = {
        let s = UISwitch()
        s.addTarget(self, action: #selector(ActionSheetSubtitleSwitchCell.toggleSwitch(_:)), forControlEvents: .ValueChanged)
        return s
    }()
    
    @objc private func toggleSwitch(sender: UISwitch) {
        action?(sender.on)
    }
    
    func makeUI() {
        
        contentView.addSubview(checkedSwitch)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkedSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        
        titleStackView.axis = .Vertical
        titleStackView.distribution = .Fill
        titleStackView.alignment = .Fill
        titleStackView.spacing = 2
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleStackView)
        
        do {
            let centerY = NSLayoutConstraint(item: titleStackView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView
                , attribute: .CenterY, multiplier: 1, constant: 0)
            let leading = NSLayoutConstraint(item: titleStackView, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1, constant: 20)
            
            NSLayoutConstraint.activateConstraints([centerY, leading])
        }
        
        do {
            let centerY = NSLayoutConstraint(item: checkedSwitch, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: checkedSwitch, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activateConstraints([centerY, trailing])
        }
        
        let gap = NSLayoutConstraint(item: checkedSwitch, attribute: .Leading, relatedBy: .Equal, toItem: titleStackView, attribute: .Trailing, multiplier: 1, constant: 10)
        
        NSLayoutConstraint.activateConstraints([gap])
    }
}

final private class ActionSheetCheckCell: UITableViewCell {
    
    class var reuseIdentifier: String? {
        return "\(self)"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func makeUI() {
        
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
    
    var 
   
    
    
}






































