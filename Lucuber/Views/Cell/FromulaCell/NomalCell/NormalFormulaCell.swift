//
//  NormalFormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVOSCloud
import RealmSwift

class NormalFormulaCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var indicaterLabel: UILabel!
    @IBOutlet weak var starRatingView: StarRatingView!
    @IBOutlet weak var masterImageView: UIImageView!
    
    
    public func configerCell(with formula: Formula?, inRealm realm: Realm) {
        
        guard let formula = formula else {
            return
        }
        
        if let text = formula.contents.first?.text {
            contentLabel.attributedText = text.setAttributesFitDetailLayout(style: .normal)
        }
        
        if let currentUser = currentUser(in: realm) {
            
            let masterList: [String] = mastersWith(currentUser, inRealm: realm).map {
                $0.formulaID
            }
            
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
        
         imageView.backgroundColor = UIColor(red: 250/255.0, green: 248/255.0, blue: 244/255.0, alpha: 1)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = ""
    }
    
}
