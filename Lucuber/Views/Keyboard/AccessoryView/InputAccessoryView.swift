//
//  InputAccessoryView.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit


class InputAccessoryView: UIView {
    
    private let buttonWidth = Config.InputAccessory.buttonWidth
    private let buttonHeight = Config.InputAccessory.buttonHeight
    
    // MARK: - Properties
    
    lazy var placeholderLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.inputAccessoryPlaceholderColor()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 10)
        
        return label
    }()
    
    lazy var clearButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(InputAccessoryView.clearButtonClicked(button:)), for: .touchUpInside)
        return button
    }()
    
    lazy var FRButton: RotationButton = {
        let button = RotationButton(style: RotationButton.Style.square, rotation: Config.BaseRotation.FR)
        button.addTarget(self, action: #selector(InputAccessoryView.rotationButtonClicked(button:)), for: .touchUpInside)
        return button
    }()
    
    lazy var FLButton: RotationButton = {
        let button = RotationButton(style: RotationButton.Style.square, rotation: Config.BaseRotation.FL)
        button.addTarget(self, action: #selector(InputAccessoryView.rotationButtonClicked(button:)), for: .touchUpInside)
        return button
        
    }()
    
    lazy var BLButton: RotationButton = {
        let button = RotationButton(style: RotationButton.Style.square, rotation: Config.BaseRotation.BL)
        button.addTarget(self, action: #selector(InputAccessoryView.rotationButtonClicked(button:)), for: .touchUpInside)
        return button
    }()
    
    lazy var BRButton: RotationButton = {
        let button = RotationButton(style: RotationButton.Style.square, rotation: Config.BaseRotation.BR)
        button.addTarget(self, action: #selector(InputAccessoryView.rotationButtonClicked(button:)), for: .touchUpInside)
        return button        
    }()
    
    private var rotationButtons : [RotationButton] = []
    
    var contentDidChanged: ((FormulaContent) -> Void)?
    
    var selectedContent: FormulaContent? {
        
        didSet {
            
            if let rotation = selectedContent?.rotation {
                
                updatePlaceholderLabel(rotation: rotation)
                
                switch rotation {
                case .FR:
                    FRButton.isSelected = true
                    rotationButtons.filter {$0 != FRButton}.forEach { $0.isSelected = false }
                case .FL:
                    FLButton.isSelected = true
                    rotationButtons.filter {$0 != FLButton}.forEach { $0.isSelected = false }
                case .BL:
                    BLButton.isSelected = true
                    rotationButtons.filter {$0 != BLButton}.forEach { $0.isSelected = false }
                case .BR:
                    BRButton.isSelected = true
                    rotationButtons.filter {$0 != BRButton}.forEach { $0.isSelected = false }
                }
            }
        }
    }
    
    // MARK: - Life Cycle
    
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
        
        self.backgroundColor = UIColor.white
        self.alpha = 1
        
        FRButton.translatesAutoresizingMaskIntoConstraints = false
        FLButton.translatesAutoresizingMaskIntoConstraints = false
        BLButton.translatesAutoresizingMaskIntoConstraints = false
        BRButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(FRButton)
        addSubview(FLButton)
        addSubview(BLButton)
        addSubview(BRButton)
        addSubview(clearButton)
        addSubview(placeholderLabel)
        
        let viewDictionary: [String: AnyObject] = [
            "FR": FRButton,
            "FL": FLButton,
            "BL": BLButton,
            "BR": BRButton,
            "clear": clearButton
        ]
        
        let rotationButtonConstraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[FR]-8-[FL]-8-[BL]-8-[BR]", options: [], metrics: nil, views: viewDictionary)
        
        let FRConstraintV = NSLayoutConstraint(item: FRButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -5)
        let FLConstraintV = NSLayoutConstraint(item: FLButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -5)
        let BLConstraintV = NSLayoutConstraint(item: BLButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -5)
        let BRConstraintV = NSLayoutConstraint(item: BRButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -5)
        
        NSLayoutConstraint.activate([FRConstraintV, FLConstraintV, BLConstraintV, BRConstraintV])
        NSLayoutConstraint.activate(rotationButtonConstraintH)
        
        
        let FRWidth = NSLayoutConstraint(item: FRButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonWidth)
        let FRHeight = NSLayoutConstraint(item: FRButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight)
        
        let FLWidth = NSLayoutConstraint(item: FLButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonWidth)
        let FLHeight = NSLayoutConstraint(item: FLButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight)
        
        let BLWidth = NSLayoutConstraint(item: BLButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonWidth)
        let BLHeight = NSLayoutConstraint(item: BLButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight)
        
        let BRWidth = NSLayoutConstraint(item: BRButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonWidth)
        let BRHeight = NSLayoutConstraint(item: BRButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight)
        
        NSLayoutConstraint.activate([FRWidth, FRHeight, FLWidth, FLHeight, BLWidth, BLHeight, BRWidth, BRHeight])
        
        
        
        let clearButtonConstraintH = NSLayoutConstraint(item: clearButton, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -5)
        
        let clearButtonConstraintV = NSLayoutConstraint(item: clearButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        
        NSLayoutConstraint.activate([clearButtonConstraintH, clearButtonConstraintV])
        
        
        let labelCenterY = NSLayoutConstraint(item: placeholderLabel, attribute: .centerY, relatedBy: .equal, toItem: BRButton, attribute: .centerY, multiplier: 1, constant: 0)
        
        let labelLeft = NSLayoutConstraint(item: placeholderLabel, attribute: .left, relatedBy: .equal, toItem: BRButton, attribute: .right, multiplier: 1, constant: 10)
        
        NSLayoutConstraint.activate([labelCenterY, labelLeft])
        
    }
    
    // MARK: - Action & Target & Notification
    func rotationButtonClicked(button: RotationButton) {
        
        if button.isSelected == true {
            return
        }
        
        button.isSelected = !button.isSelected
        
        rotationButtons.filter {$0 != button}.forEach { $0.isSelected = false }
        
        if let content = selectedContent, let rotation = button.rotation {
            updatePlaceholderLabel(rotation: rotation)
            
            content.rotation = rotation
            
            contentDidChanged?(content)
        }
        
    }
    
    
    func clearButtonClicked(button: UIButton) {
        
        printLog(#function)
    }
    
    private func updatePlaceholderLabel(rotation: Rotation) {
        
        switch rotation {
        case .FR(_, let text):
            placeholderLabel.text = text
        case .FL(_, let text):
            placeholderLabel.text = text
        case .BL(_, let text):
            placeholderLabel.text = text
        case .BR(_, let text):
            placeholderLabel.text = text
        }
        
    }
    
}
