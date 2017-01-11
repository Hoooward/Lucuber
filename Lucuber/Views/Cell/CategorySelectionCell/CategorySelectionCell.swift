//
//  CategorySelectionCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/11.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class CategorySelectionCell: UICollectionViewCell {
    
    static let height: CGFloat = 35

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    enum Selection {
        case unavailable
        case off
        case on
    }
    
    var categorySelection: Selection = .off {
        willSet {
            
            switch newValue {
                
            case .unavailable:
                
                backgroundImageView.image = UIImage(named: "skill_bubble_large_empty")
                categoryLabel.textColor = UIColor.cubeTintColor()
                contentView.alpha = 0.2
                
            case .off:
                backgroundImageView.image = UIImage(named: "skill_bubble_large_empty")
                categoryLabel.textColor = UIColor.cubeTintColor()
                contentView.alpha = 1
                
            case .on:
                backgroundImageView.image = UIImage(named: "skill_bubble_large")
                categoryLabel.textColor = UIColor.white
                contentView.alpha = 1
            }
        
        
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryLabel.font = UIFont.systemFont(ofSize: 20)
    }

}
