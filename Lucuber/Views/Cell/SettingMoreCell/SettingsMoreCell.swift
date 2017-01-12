//
//  SettingsMoreCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/12.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class SettingsMoreCell: UITableViewCell {
    @IBOutlet weak var annotationLabel: UILabel!
    @IBOutlet weak var accessoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryImageView.tintColor = UIColor.lightGray
    }
    

    
}
