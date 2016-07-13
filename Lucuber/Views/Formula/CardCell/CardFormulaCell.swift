//
//  CardFormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class CardFormulaCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var starRatingView: StarRatingView!
    
    var formula: Formula? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentLabel.font = UIFont.cubeFormulaNormalContentFont()
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
        
        contentView.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor
        contentView.layer.borderWidth = 1.0
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
    }
    
    func updateUI() {
        if let formula = formula {
            contentLabel.attributedText = formula.contents.first!.text!.setAttributesFitDetailLayout(ContentStyle.Normal)
            imageView.image = UIImage(named: formula.imageName)
            nameLabel.text = formula.name
            starRatingView.maxRating = formula.rating
            starRatingView.rating = formula.rating
        }
        
    }
}
