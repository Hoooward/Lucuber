//
//  FormulaNameTextField.swift
//  Lucuber
//
//  Created by Howard on 7/11/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaNameTextField: UITextField {

    override func becomeFirstResponder() -> Bool {
        print(#function)
        userInteractionEnabled = true
        return super.becomeFirstResponder()
        
    }
    
    override func resignFirstResponder() -> Bool {
        print(#function)
        userInteractionEnabled = false
        return super.resignFirstResponder()
    }
}
