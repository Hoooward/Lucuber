//
//  FormulaNameTextField.swift
//  Lucuber
//
//  Created by Howard on 7/11/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaNameTextField: UITextField {
    
    // MARK: - Properties
    
    lazy var placeholdTextLabel: UILabel = {
        let label = UILabel()
        label.text = "输入名称, 可使用: F2L、 PLL、 OLL。"
        label.textColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        return label
    }()
    
    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    private func makeUI() {
        addSubview(placeholdTextLabel)
        placeholdTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let placeholdLeft = NSLayoutConstraint(item: placeholdTextLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let placeholdTop = NSLayoutConstraint(item: placeholdTextLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([placeholdTop, placeholdLeft])
    }
    
    // MARK: Action & Target
    
    func updatePlaceholderLabel(showPlaceholderText: Bool) {
        placeholdTextLabel.text = showPlaceholderText ? "输入名称, 可使用: F2L、 PLL、 OLL。" : ""
        spring(duration: 0.5) {
            self.placeholdTextLabel.isHidden = !self.text!.isDirty
        }
    }

    override func becomeFirstResponder() -> Bool {
        isUserInteractionEnabled = true
        updatePlaceholderLabel(showPlaceholderText: false)
        return super.becomeFirstResponder()
        
    }
    
    override func resignFirstResponder() -> Bool {
        isUserInteractionEnabled = false
        updatePlaceholderLabel(showPlaceholderText: true)
        if text!.isDirty { text = "" }
        return super.resignFirstResponder()
    }
    
 
    
}
