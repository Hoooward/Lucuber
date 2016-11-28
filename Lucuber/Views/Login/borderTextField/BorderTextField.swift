//
//  BorderTextField.swift
//  Lucuber
//
//  Created by Howard on 6/6/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class BorderTextField: UITextField {

    @IBInspectable var leftTextInset: CGFloat = 20
    @IBInspectable var rightTextInset: CGFloat = 20
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: leftTextInset, y: 0, width: bounds.width - leftTextInset - rightTextInset, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
