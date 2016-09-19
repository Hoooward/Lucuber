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
        
        contentLabel.font = UIFont.formulaNormalContent()
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
        
        contentView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        contentView.layer.borderWidth = 1.0
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
    }
    
    func updateUI() {
        
        if let formula = formula {
            
            
            if let text = formula.contents.first?.text {
                
                contentLabel.attributedText = text.setAttributesFitDetailLayout(style: .normal)
            }
            
            imageView.image = UIImage(named: formula.imageName)
            nameLabel.text = formula.name
            starRatingView.maxRating = formula.rating
            starRatingView.rating = formula.rating
            indicaterLabel.text = formula.category.rawValue
        }
        
    }
}
