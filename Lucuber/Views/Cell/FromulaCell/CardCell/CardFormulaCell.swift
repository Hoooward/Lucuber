//
//  CardFormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVOSCloud

class CardFormulaCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var starRatingView: StarRatingView!
    @IBOutlet weak var indicaterLabel: UILabel!
    @IBOutlet weak var masterImageView: UIImageView!
    
    public func configerCell(with formula: Formula?) {
        
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
        
        
        imageView.image = UIImage(named: formula.imageName)
        nameLabel.text = formula.name
        starRatingView.maxRating = formula.rating
        starRatingView.rating = formula.rating
        indicaterLabel.text = formula.category.rawValue
        
        if formula.isNewVersion {
            nameLabel.textColor = UIColor.cubeTintColor()
        } else {
            nameLabel.textColor = UIColor.black
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
        masterImageView.isHidden = true
        
    }

}
