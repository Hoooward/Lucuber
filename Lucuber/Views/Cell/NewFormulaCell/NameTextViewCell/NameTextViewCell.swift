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
    
    var nameDidChanged: ((_ newText: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }

    private func makeUI() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(NameTextViewCell.textFieldDidChanged(notification:)), name: Notification.Name.UITextFieldTextDidChange , object: nil)
    }
    
    //通知HeaderView更新Name
    func textFieldDidChanged(notification: NSNotification) {
        let newText = self.textField.text!
        nameDidChanged?(newText)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


