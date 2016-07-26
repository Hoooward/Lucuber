//
//  FormulaNameTextField.swift
//  Lucuber
//
//  Created by Howard on 7/11/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaNameTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    private func makeUI() {
        addSubview(placeholdTextLabel)
        placeholdTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let placeholdLeft = NSLayoutConstraint(item: placeholdTextLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let placeholdTop = NSLayoutConstraint(item: placeholdTextLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([placeholdTop, placeholdLeft])
    }
    
    func updatePlaceholderLabel(showPlaceholderText: Bool) {
        placeholdTextLabel.text = showPlaceholderText ? "输入名称, 可使用: F2L、 PLL、 OLL。" : ""
        spring(0.5) {
            self.placeholdTextLabel.hidden = !self.text!.isDirty
        }
    }

    override func becomeFirstResponder() -> Bool {
        userInteractionEnabled = true
        updatePlaceholderLabel(false)
        return super.becomeFirstResponder()
        
    }
    
    override func resignFirstResponder() -> Bool {
        userInteractionEnabled = false
        updatePlaceholderLabel(true)
        if text!.isDirty { text = "" }
        return super.resignFirstResponder()
    }
    
    lazy var placeholdTextLabel: UILabel = {
        let label = UILabel()
        label.text = "输入名称, 可使用: F2L、 PLL、 OLL。"
        label.textColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        label.font = UIFont.systemFontOfSize(12)
        label.sizeToFit()
        return label
    }()
    
}
