//
//  NormalFormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class NormalFormulaCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var indicaterLabel: UILabel!
    @IBOutlet var starRatingView: StarRatingView!
    
    var formula: Formula? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI() {
        if let formula = formula {
            imageView.image = UIImage(named: formula.imageName)
            nameLabel.text = formula.name
            contentLabel.attributedText = formula.contents.first!.text!.setAttributesFitDetailLayout(ContentStyle.Normal)
            indicaterLabel.text = formula.category.rawValue
            starRatingView.maxRating = formula.rating
            starRatingView.rating = formula.rating
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentLabel.font = UIFont.cubeFormulaNormalContentFont()
        imageView.layer.cornerRadius = 2
        imageView.clipsToBounds = true
    }
    
}
