//
//  NormalFormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVOSCloud

class NormalFormulaCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var indicaterLabel: UILabel!
    @IBOutlet weak var starRatingView: StarRatingView!
    @IBOutlet weak var masterImageView: UIImageView!
    
    func configerCell(with formula: Formula?) {
        
        guard let formula = formula else {
            return
        }
        
        if let text = formula.contents.first?.text {
            contentLabel.attributedText = text.setAttributesFitDetailLayout(style: .normal)
        }
        
        if let masterList = AVUser.current()?.masterList() {
            nameLabel.textColor = masterList.contains(formula.localObjectID) ? UIColor.masterLabelText() : UIColor.black
            masterImageView.isHidden = !masterList.contains(formula.localObjectID)
        }
        
         imageView.cube_setImageAtFormulaCell(with: formula.imageURL ?? "", size: self.imageView.size)
        nameLabel.text = formula.name
        indicaterLabel.text = formula.categoryString
        starRatingView.maxRating = formula.rating
        starRatingView.rating = formula.rating
        
        if formula.isNewVersion {
            nameLabel.textColor = UIColor.cubeTintColor()
        } else {
            nameLabel.textColor = UIColor.black
        }
    }
  
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentLabel.font = UIFont.formulaNormalContent()
        imageView.layer.cornerRadius = 2
        imageView.clipsToBounds = true
        masterImageView.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = ""
    }
    
}
