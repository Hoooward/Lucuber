//
//  ProfileScoreCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/30.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ProfileScoreCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var accessoryImageView: UIImageView!
    @IBOutlet weak var accessoryImageViewtrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreTimerLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryLabelLeadingConstraint.constant = Config.Profile.leftEdgeInset
        accessoryImageViewtrailingConstraint.constant = Config.Profile.rightEdgeInset
        accessoryImageView.tintColor = UIColor.lightGray
        
        categoryLabel.textColor = UIColor.gray
        scoreTimerLabel.textColor = UIColor.gray
        accessoryImageView.isHidden = true
    }

}
