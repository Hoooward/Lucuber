//
//  CubeCategoryCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/10.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class CubeCategoryCell: UICollectionViewCell {

    static let height: CGFloat = 24
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        categoryLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    var tapped: Bool = false {
        willSet {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] _ in
                self?.backgroundImageView.tintColor = newValue ? UIColor.black.withAlphaComponent(0.25) : UIColor.cubeTintColor()
            }, completion: nil)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tapped = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        delay(0.15) { [weak self] in
            
            if let strongSelf = self {
                strongSelf.tapped = false
            }
            
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        tapped = false
    }

}
