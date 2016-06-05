//
//  HeaderCell.swift
//  Lucuber
//
//  Created by Howard on 6/5/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class HeaderCell: UICollectionViewCell {

    @IBOutlet var formulaImageView: UIImageView!
    @IBOutlet var formulaNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var formula: Formula? {
        didSet {
            if let formula = formula {
                formulaImageView.image = UIImage(named: formula.imageName)
                formulaNameLabel.text = formula.name
            }
        }
    }
}
