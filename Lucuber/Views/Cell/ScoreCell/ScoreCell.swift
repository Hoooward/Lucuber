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
        // Initialization code
    }
    
    public func configreCell(with score: String) {
    
    }
}
