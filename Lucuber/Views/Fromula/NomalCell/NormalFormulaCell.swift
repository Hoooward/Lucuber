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
        
        if
            let currentUser = AVUser.current(),
            let list = currentUser.getMasterFormulasIDList() {
            
            nameLabel.textColor = list.contains(formula.localObjectID) ? UIColor.masterLabelText() : UIColor.black
            
        }
        
        imageView.image = UIImage(named: formula.imageName)
        nameLabel.text = formula.name
        indicaterLabel.text = formula.category.rawValue
        starRatingView.maxRating = formula.rating
        starRatingView.rating = formula.rating
        
        
        if let currentUser = AVUser.current(), let list = currentUser.getMasterFormulasIDList() {
            masterImageView.isHidden = !list.contains(formula.localObjectID)
            
        }
        
        
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
//        contentView.layer.cornerRadius = 6
//        contentView.layer.masksToBounds = true
//        
//        contentView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
//        contentView.layer.borderWidth = 1.0
        
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
