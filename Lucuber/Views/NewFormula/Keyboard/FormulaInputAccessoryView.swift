//
//  FormulaInputAccessoryView.swift
//  Lucuber
//
//  Created by Howard on 8/8/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit



private let buttonWidth: CGFloat = 30

class FormulaInputAccessoryView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private var rotationButtons: [RotationButton] = []
    
    func rotationButtonClicked(button: RotationButton) {
        button.selected = !button.selected
        
        rotationButtons.forEach {
            
            if $0 !== button {
               $0.selected = false
            }
        }
        
    }
    
    func clearButtonClicked(button: UIButton) {
        
    }
    
    private func makeUI() {
        
        rotationButtons.append(FRButton)
        rotationButtons.append(FLButton)
        rotationButtons.append(BLButton)
        rotationButtons.append(BRButton)
        
        self.backgroundColor = UIColor.whiteColor()
        self.alpha = 1
        
        FRButton.translatesAutoresizingMaskIntoConstraints = false
        FLButton.translatesAutoresizingMaskIntoConstraints = false
        BLButton.translatesAutoresizingMaskIntoConstraints = false
        BRButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(FRButton)
        addSubview(FLButton)
        addSubview(BLButton)
        addSubview(BRButton)
        addSubview(clearButton)
        
        let viewDictionary: [String: AnyObject] = [
            "FR": FRButton,
            "FL": FLButton,
            "BL": BLButton,
            "BR": BRButton,
            "clear": clearButton
        ]
        
        let rotationButtonConstraintH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[FR]-10-[FL]-10-[BL]-10-[BR]", options: [], metrics: nil, views: viewDictionary)
        
        let FRConstraintV = NSLayoutConstraint(item: FRButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let FLConstraintV = NSLayoutConstraint(item: FLButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let BLConstraintV = NSLayoutConstraint(item: BLButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let BRConstraintV = NSLayoutConstraint(item: BRButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([FRConstraintV, FLConstraintV, BLConstraintV, BRConstraintV])
        NSLayoutConstraint.activateConstraints(rotationButtonConstraintH)
        
        
        let FRWidth = NSLayoutConstraint(item: FRButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        let FRHeight = NSLayoutConstraint(item: FRButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        
        let FLWidth = NSLayoutConstraint(item: FLButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        let FLHeight = NSLayoutConstraint(item: FLButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        
        let BLWidth = NSLayoutConstraint(item: BLButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        let BLHeight = NSLayoutConstraint(item: BLButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        
        let BRWidth = NSLayoutConstraint(item: BRButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        let BRHeight = NSLayoutConstraint(item: BRButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
       
        NSLayoutConstraint.activateConstraints([FRWidth, FRHeight, FLWidth, FLHeight, BLWidth, BLHeight, BRWidth, BRHeight])
        
        let clearButtonConstraintH = NSLayoutConstraint(item: clearButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -15)
        
         let clearButtonConstraintV = NSLayoutConstraint(item: clearButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        
//        let clearButtonWidth = NSLayoutConstraint(item: clearButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
//        let clearButtonHeight = NSLayoutConstraint(item: clearButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        
        NSLayoutConstraint.activateConstraints([clearButtonConstraintH, clearButtonConstraintV])
        
        print(clearButton.frame)
        print(self.subviews)
        
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        clearButton.frame = CGRect(x: self.bounds.width - clearButton.width - 10, y: (self.bounds.height - clearButton.height) / 2, width: 20, height: 20)
        print(clearButton.frame)
    }
 
    lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("清空", forState: .Normal)
        button.setTitleColor(UIColor( red: 0.8504, green: 0.2182, blue: 0.1592, alpha: 1.0 )
            , forState: .Normal)
//        button.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
        
        button.sizeToFit()
        button.addTarget(self, action: #selector(FormulaInputAccessoryView.clearButtonClicked(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var FRButton: RotationButton = {
        let button = RotationButton(rotation: FRrotation)
        button.addTarget(self, action: #selector(FormulaInputAccessoryView.rotationButtonClicked(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var FLButton: RotationButton = {
        let button = RotationButton(rotation: FLrotation)
        button.addTarget(self, action: #selector(FormulaInputAccessoryView.rotationButtonClicked(_:)), forControlEvents: .TouchUpInside)
        return button

    }()
    
    lazy var BLButton: RotationButton = {
        let button = RotationButton(rotation: BLrotation)
        button.addTarget(self, action: #selector(FormulaInputAccessoryView.rotationButtonClicked(_:)), forControlEvents: .TouchUpInside)
        return button

    }()
    
    lazy var BRButton: RotationButton = {
        let button = RotationButton(rotation: BRrotation)
        button.addTarget(self, action: #selector(FormulaInputAccessoryView.rotationButtonClicked(_:)), forControlEvents: .TouchUpInside)
        return button
    }()

}
