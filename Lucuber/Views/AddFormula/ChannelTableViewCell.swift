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
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
