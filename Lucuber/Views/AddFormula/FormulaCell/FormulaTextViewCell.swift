//
//  FormulaTextViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaTextViewCell: UITableViewCell {

    @IBOutlet var textView: FormulaTextView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
