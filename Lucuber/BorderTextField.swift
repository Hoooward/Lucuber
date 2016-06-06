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
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(leftTextInset, 0, bounds.width - leftTextInset - rightTextInset, bounds.height)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}
