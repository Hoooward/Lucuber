//
//  HeaderTableViewCell.swift
//  Lucuber
//
//  Created by Howard on 16/7/5.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    @IBOutlet var formulaImageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        formulaImageButton.layer.cornerRadius = 8
        formulaImageButton.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
