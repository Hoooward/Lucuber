//
//  ScoreDetailCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ScoreDetailCell: UITableViewCell {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var indicatorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        timerLabel.textColor = UIColor.gray
        timerLabel.font = UIFont.scoreLabelFont()
        indicatorLabel.textColor = UIColor.gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
