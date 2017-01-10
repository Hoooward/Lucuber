//
//  ProfileMasterCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/30.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ProfileMasterCell: UICollectionViewCell {

    @IBOutlet weak var indicatorTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelLeadingConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelLeadingConstraint.constant = Config.Profile.leftEdgeInset
        indicatorTrailingConstraint.constant = Config.Profile.rightEdgeInset
        
    }

}
