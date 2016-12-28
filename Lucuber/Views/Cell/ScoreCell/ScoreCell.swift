//
//  ScoreCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

public class ScoreCell: UITableViewCell {
    

    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        scoreLabel.font = UIFont.scoreLabelFont()
        scoreLabel.textColor = UIColor.gray
    }
    
    public func configreCell(with score: Score) {
    
        scoreLabel.text = score.timertext
        indicatorImageView.image = UIImage(named: score.isDNF ? "OvalRed" : "OvalBlue")
    }
}
