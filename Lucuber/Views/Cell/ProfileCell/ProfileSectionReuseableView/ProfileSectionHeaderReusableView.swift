//
//  ProfileSectionHeaderReusableView.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/10.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class ProfileSectionHeaderReusableView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var accessoryImageView: UIImageView!
    @IBOutlet weak var accessoryImageViewTrailingConstraint: NSLayoutConstraint!
    
    var tapAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryImageView.tintColor = UIColor.lightGray
        
        titleLabelLeadingConstraint.constant = Config.Profile.leftEdgeInset
        accessoryImageViewTrailingConstraint.constant = Config.Profile.rightEdgeInset
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ProfileSectionHeaderReusableView.tap))
        addGestureRecognizer(tap)
    }
    
    func tap() {
        tapAction?()
    }
    
}
