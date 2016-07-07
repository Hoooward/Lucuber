//
//  ChannelTableViewCell.swift
//  Lucuber
//
//  Created by Howard on 16/7/6.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var channelBackgroundView: UIImageView!
    @IBOutlet var chanelTitleLabel: UILabel!
    @IBOutlet var indicaterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    func bringUpPickViewStatus(pickViewisDismiss: Bool) {
//        titleLabel.alpha = pickViewisDismiss ? 1 : 0
        indicaterImageView.alpha = pickViewisDismiss ? 1 : 0
    }

}
