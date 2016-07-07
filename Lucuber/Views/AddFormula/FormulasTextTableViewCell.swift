//
//  FormulasTextTableViewCell.swift
//  Lucuber
//
//  Created by Howard on 16/7/7.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class FormulasTextTableViewCell: UITableViewCell {

    @IBOutlet var textField: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.textContainer.lineFragmentPadding = 0
        textField.tintColor = UIColor.cubeTintColor()
        textField.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
