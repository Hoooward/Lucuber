//
//  SettingsUserCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/12.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import RealmSwift
import Navi

class SettingsUserCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    
    @IBOutlet weak var accessoryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageViewWidthConstraint.constant = 80
        accessoryImageView.tintColor = UIColor.lightGray
    }

    public func configureCell(with user: RUser) {
        
        nameLabel.text = user.nickname
        introLabel.text = user.introduction
        
        if let avatarURLString = user.avatorImageURL {
            
            let avatarSize: CGFloat = 80
            let avatarStyle: AvatarStyle = AvatarStyle.roundedRectangle(size: CGSize(width: avatarSize, height: avatarSize), cornerRadius: avatarSize * 0.5, borderWidth: 0)
            let avatar = CubeAvatar(avatarUrlString: avatarURLString, avatarStyle: avatarStyle)
            avatarImageView.navi_setAvatar(avatar, withFadeTransitionDuration: 0.0)
        }
 
        
    }
 
    
}









