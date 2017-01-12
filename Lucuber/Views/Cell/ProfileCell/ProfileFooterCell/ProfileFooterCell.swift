//
//  ProfileFooterCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/29.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift

class ProfileFooterCell: UICollectionViewCell {
    
    public var tapUsernameAction: ((String) -> Void)?

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var textView: ChatTextView!
    @IBOutlet weak var textViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewRightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textViewLeftConstraint.constant = Config.Profile.leftEdgeInset
        textViewRightConstraint.constant = Config.Profile.rightEdgeInset
        
        textView.isScrollEnabled = false
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        
        textView.textContainer.lineFragmentPadding = 0
        textView.textColor = UIColor.cubeGrayColor()
        textView.backgroundColor = UIColor.clear
        textView.tintColor = UIColor.black
        textView.linkTextAttributes = [
            NSForegroundColorAttributeName: UIColor.cubeTintColor()
        ]
    }
    
    func configureWithProfileUser(_ profileUser: ProfileUser, introduction: String) {
        
        nicknameLabel.text = profileUser.nickname
        usernameLabel.text = profileUser.username
        
        textView.text = introduction
        
        
    }
    
    
    
}









