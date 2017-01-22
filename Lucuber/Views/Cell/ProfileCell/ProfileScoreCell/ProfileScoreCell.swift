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
    @IBOutlet weak var scoreTimerLabel: UILabel!
    @IBOutlet weak var scoreTimerLabelTrailingConstraint: NSLayoutConstraint!
    
    var scores: CubeScores? {
        didSet {
            
            guard let scores = scores else {
                return
            }
            
            categoryLabel.text = scores.categoryString
            scoreTimerLabel.text = scores.scoreTimerString + "秒"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryLabelLeadingConstraint.constant = Config.Profile.leftEdgeInset + 2
        scoreTimerLabelTrailingConstraint.constant = Config.Profile.rightEdgeInset + 10
        
        categoryLabel.textColor = UIColor.gray
        scoreTimerLabel.textColor = UIColor.gray
    }

}
