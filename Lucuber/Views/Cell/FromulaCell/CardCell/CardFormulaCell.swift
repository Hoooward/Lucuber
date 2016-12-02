//
//  CardFormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVOSCloud
import RealmSwift

class CardFormulaCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var starRatingView: StarRatingView!
    @IBOutlet weak var indicaterLabel: UILabel!
    @IBOutlet weak var masterImageView: UIImageView!
    
    private var formula: Formula?
    
    public func configerCell(with formula: Formula?, inRealm realm: Realm) {
        
        guard let formula = formula else {
            return
        }
        
        self.formula = formula
        
        if let text = formula.contents.first?.text {
            
            contentLabel.attributedText = text.setAttributesFitDetailLayout(style: .normal)
        }
        
        if let currentUser = currentUser(in: realm) {
            
            let masterList: [String] = mastersWith(currentUser, inRealm: realm).map {
                $0.formulaID
            }
            
            masterImageView.isHidden = !masterList.contains(formula.localObjectID)
        }
        
        
        if let localImageURL = FileManager.cubeFormulaLocalImageURL(with: formula.localObjectID) {
            
            if let image = UIImage(contentsOfFile: localImageURL.path) {
                
                imageView.image = image
            }
        }
        
        if imageView.image == nil {
            imageView.cube_setImageAtFormulaCell(with: formula.imageURL, size: Config.FormulaCell.cardCellSize)
        }
        
        nameLabel.text = formula.name
        starRatingView.maxRating = formula.rating
        starRatingView.rating = formula.rating
        indicaterLabel.text = formula.categoryString
        
        if formula.isNewVersion {
            nameLabel.textColor = UIColor.cubeTintColor()
        } else {
            nameLabel.textColor = UIColor.black
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
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
        
        
        imageView.backgroundColor = UIColor(red: 250/255.0, green: 248/255.0, blue: 244/255.0, alpha: 1)
        
    }

}
