//
//  NameTextViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class NameTextViewCell: UITableViewCell {

    @IBOutlet var textField: FormulaNameTextField!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func makeUI() {
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
 
}
