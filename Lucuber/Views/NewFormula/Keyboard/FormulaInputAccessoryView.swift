//
//  FormulaInputAccessoryView.swift
//  Lucuber
//
//  Created by Howard on 8/8/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit



private let buttonWidth: CGFloat = 35
private let buttonHeight: CGFloat = 25

class FormulaInputAccessoryView: UIView {


    private var rotationButtons: [RotationButton] = []
    
    var contentDidChanged: ((FormulaContent) -> Void)?
    
    var seletedContent: FormulaContent? {
        
        didSet {
            if let rotation = seletedContent?.rotation {
                
                updatePlaceholderLabel(rotation)
                
                switch rotation {
              
                    
                case .FR:
                    FRButton.selected = true
                    rotationButtons.filter {$0 != FRButton}.forEach { $0.selected = false }
                case .FL:
                    FLButton.selected = true
                    rotationButtons.filter {$0 != FLButton}.forEach { $0.selected = false }
                case .BL:
                    BLButton.selected = true
                    rotationButtons.filter {$0 != BLButton}.forEach { $0.selected = false }
                case .BR:
                    BRButton.selected = true
                    rotationButtons.filter {$0 != BRButton}.forEach { $0.selected = false }
                }
            }
        }
    }
    
    func updatePlaceholderLabel(rotation: Rotation) {
        
        
        switch rotation {
        case .FR(_, let text):
            placeholderLaabel.text = text
        case .FL(_, let text):
            placeholderLaabel.text = text
        case .BL(_, let text):
            placeholderLaabel.text = text
        case .BR(_, let text):
            placeholderLaabel.text = text
        }
        
    }
    
    // MARK: - Target&Notification
    func rotationButtonClicked(button: RotationButton) {
        
        
        if button.selected == true {
            return
        }
        
        button.selected = !button.selected
        
        rotationButtons.filter {$0 != button}.forEach { $0.selected = false }
        
        
        if let content = seletedContent, let rotation = button.rotation {
            updatePlaceholderLabel(rotation)
            
            content.rotation = rotation
            
            contentDidChanged?(content)
        }
        
    }
    
    func clearButtonClicked(button: UIButton) {
        
        printLog(#function)
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        placeholderLaabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(FRButton)
        addSubview(FLButton)
        addSubview(BLButton)
        addSubview(BRButton)
        addSubview(clearButton)
        addSubview(placeholderLaabel)
        
        let viewDictionary: [String: AnyObject] = [
            "FR": FRButton,
            "FL": FLButton,
            "BL": BLButton,
            "BR": BRButton,
            "clear": clearButton
        ]
        
        let rotationButtonConstraintH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[FR]-8-[FL]-8-[BL]-8-[BR]", options: [], metrics: nil, views: viewDictionary)
        
        let FRConstraintV = NSLayoutConstraint(item: FRButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -5)
        let FLConstraintV = NSLayoutConstraint(item: FLButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -5)
        let BLConstraintV = NSLayoutConstraint(item: BLButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -5)
        let BRConstraintV = NSLayoutConstraint(item: BRButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -5)
        
        NSLayoutConstraint.activateConstraints([FRConstraintV, FLConstraintV, BLConstraintV, BRConstraintV])
        NSLayoutConstraint.activateConstraints(rotationButtonConstraintH)
        
        
        let FRWidth = NSLayoutConstraint(item: FRButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        let FRHeight = NSLayoutConstraint(item: FRButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonHeight)
        
        let FLWidth = NSLayoutConstraint(item: FLButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        let FLHeight = NSLayoutConstraint(item: FLButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonHeight)
        
        let BLWidth = NSLayoutConstraint(item: BLButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        let BLHeight = NSLayoutConstraint(item: BLButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonHeight)
        
        let BRWidth = NSLayoutConstraint(item: BRButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonWidth)
        let BRHeight = NSLayoutConstraint(item: BRButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: buttonHeight)
       
        NSLayoutConstraint.activateConstraints([FRWidth, FRHeight, FLWidth, FLHeight, BLWidth, BLHeight, BRWidth, BRHeight])
        
      
        
        let clearButtonConstraintH = NSLayoutConstraint(item: clearButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -5)
        
         let clearButtonConstraintV = NSLayoutConstraint(item: clearButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        
        
        NSLayoutConstraint.activateConstraints([clearButtonConstraintH, clearButtonConstraintV])
        
        
        let labelCenterY = NSLayoutConstraint(item: placeholderLaabel, attribute: .CenterY, relatedBy: .Equal, toItem: BRButton, attribute: .CenterY, multiplier: 1, constant: 0)
        
        let labelLeft = NSLayoutConstraint(item: placeholderLaabel, attribute: .Left, relatedBy: .Equal, toItem: BRButton, attribute: .Right, multiplier: 1, constant: 10)

         NSLayoutConstraint.activateConstraints([labelCenterY, labelLeft])
    }
    
    
    lazy var placeholderLaabel: UILabel = {
        let label = UILabel()
        
        label.textColor = UIColor ( red: 0.6889, green: 0.7137, blue: 0.7345, alpha: 1.0 )
        label.textAlignment = .Left
        label.font = UIFont.systemFontOfSize(10)
        return label
        
        
    }()

 
    lazy var clearButton: UIButton = {
        let button = UIButton()
//        button.setTitle("清空", forState: .Normal)
//        button.setTitleColor(UIColor( red: 0.8504, green: 0.2182, blue: 0.1592, alpha: 1.0 )
//            , forState: .Normal)
        
//        button.setBackgroundImage(UIImage(named: "ketbutton_clear"), forState: .Normal)
//        button.setBackgroundImage(UIImage(named: "keybutton_clear_groy"), forState: .Selected)
//        button.sizeToFit()
        button.addTarget(self, action: #selector(FormulaInputAccessoryView.clearButtonClicked(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var FRButton: RotationButton = {
        let button = RotationButton(style: RotationButton.Style.Square, rotation: FRrotation)
        button.addTarget(self, action: #selector(FormulaInputAccessoryView.rotationButtonClicked(_:)), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var FLButton: RotationButton = {
        let button = RotationButton(style: RotationButton.Style.Square, rotation: FLrotation)
        button.addTarget(self, action: #selector(FormulaInputAccessoryView.rotationButtonClicked(_:)), forControlEvents: .TouchUpInside)
        return button

    }()
    
    lazy var BLButton: RotationButton = {
        let button = RotationButton(style: RotationButton.Style.Square, rotation: BLrotation)
        button.addTarget(self, action: #selector(FormulaInputAccessoryView.rotationButtonClicked(_:)), forControlEvents: .TouchUpInside)
        return button

    }()
    
    lazy var BRButton: RotationButton = {
        let button = RotationButton(style: RotationButton.Style.Square, rotation: BRrotation)
        button.addTarget(self, action: #selector(FormulaInputAccessoryView.rotationButtonClicked(_:)), forControlEvents: .TouchUpInside)
        return button
    }()

}
