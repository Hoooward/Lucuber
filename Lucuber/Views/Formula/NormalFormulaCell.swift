//
//  NormalFormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class NormalFormulaCell: UICollectionViewCell {
    
    @IBOutlet var formulaImageView: UIImageView!
    @IBOutlet var formulaNameLabel: UILabel!
    @IBOutlet var formulaLabel: UILabel!
    @IBOutlet var favorateImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        formulaImageView.layer.cornerRadius = 2
        formulaImageView.clipsToBounds = true
    }
    
}
