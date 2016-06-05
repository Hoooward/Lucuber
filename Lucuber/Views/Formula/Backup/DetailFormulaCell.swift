//
//  DetailFormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class DetailFormulaCell: UICollectionViewCell {

    @IBOutlet var favorateImageView: UIImageView!
    @IBOutlet var formulaImageView: UIImageView!
    @IBOutlet var formulaNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
        
        contentView.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor
        contentView.layer.borderWidth = 1.0
        formulaImageView.contentMode = .ScaleAspectFill
//        formulaImageView.clipsToBounds = true
        formulaImageView.layer.cornerRadius = 4
        formulaImageView.layer.masksToBounds = true
//        favoriteImageView.contentMode = .ScaleAspectFit
    }

}
