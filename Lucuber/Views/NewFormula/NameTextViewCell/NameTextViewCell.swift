//
//  NameTextViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class NameTextViewCell: UITableViewCell {

    @IBOutlet weak var textField: FormulaNameTextField!
    
    var nameDidChanged: ((newText: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }

    private func makeUI() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NameTextViewCell.textFieldDidChanged(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    //通知HeaderView更新Name
    
    func textFieldDidChanged(notification: NSNotification) {
        let newText = self.textField.text!
        NSNotificationCenter.defaultCenter().postNotificationName(AddFormulaDetailDidChangedNotification, object: nil, userInfo: [AddFormulaNotification.NameChanged.rawValue : newText])
        
        nameDidChanged?(newText: newText)
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


