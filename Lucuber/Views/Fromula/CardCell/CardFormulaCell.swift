//
//  CardFormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class CardFormulaCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var starRatingView: StarRatingView!
    @IBOutlet weak var indicaterLabel: UILabel!
    
    var formula: Formula? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentLabel.font = UIFont.cubeFormulaNormalContentFont()
        contentView.backgroundColor = UIColor.white
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
            
            indicaterLabel.text = formula.category.rawValue
        }
        
    }
}
