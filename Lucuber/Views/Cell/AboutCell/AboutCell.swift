//
//  AboutCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/14.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class AboutCell: UITableViewCell {
    @IBOutlet weak var annotationLabel: UILabel!
    @IBOutlet weak var accessoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryImageView.tintColor = UIColor.lightGray
    }
    
}
