//
//  NormalFormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class NormalFormulaCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var indicaterLabel: UILabel!
    @IBOutlet weak var starRatingView: StarRatingView!
    
    var formula: Formula? {
        didSet{
//            updateUI()
        }
    }
    
    func configerCell(with formula: Formula?) {
        
        guard let formula = formula else {
            return
        }
        updateUI(with: formula)
    }
    
    private func updateUI(with formula: Formula) {
        
        if let text = formula.contents.first?.text {
            
            contentLabel.attributedText = text.setAttributesFitDetailLayout(style: .normal)
        }
        
        imageView.image = UIImage(named: formula.imageName)
        nameLabel.text = formula.name
        indicaterLabel.text = formula.category.rawValue
        starRatingView.maxRating = formula.rating
        starRatingView.rating = formula.rating
        
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        contentLabel.font = UIFont.formulaNormalContent()
        imageView.layer.cornerRadius = 2
        imageView.clipsToBounds = true
    }
    
}
