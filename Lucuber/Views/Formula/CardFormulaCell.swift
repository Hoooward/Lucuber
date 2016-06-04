//
//  CardFormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class CardFormulaCell: UICollectionViewCell {

    @IBOutlet var formulaImageView: UIImageView!
    @IBOutlet var formulaNameLabel: UILabel!
    @IBOutlet var formulaLabel: UILabel!
    @IBOutlet var favoriteImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
        
        contentView.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor
        contentView.layer.borderWidth = 1.0
        formulaImageView.contentMode = .ScaleAspectFill
        formulaImageView.clipsToBounds = true
        favoriteImageView.contentMode = .ScaleAspectFit
    }
}
