//
//  EditProfileLessInfoCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/13.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class EditProfileLessInfoCell: UITableViewCell {

    @IBOutlet weak var annotationLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoLabelTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bageImageView: UIImageView!
    @IBOutlet weak var accessoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryImageView.tintColor = UIColor.lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
