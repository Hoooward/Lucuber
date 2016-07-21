//
//  DetailFormulasCell.swift
//  Lucuber
//
//  Created by Howard on 7/21/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class DetailFormulasCell: UITableViewCell {

    @IBOutlet var rotationIndicator: UIImageView!
    @IBOutlet var contentLabel: UILabel!
    

    var formulaContent: FormulaContent? {
        didSet {
            if let content = formulaContent {
                var indicaterImagename = ""
                switch content.rotation {
                case .FR(let imageName, _):
                    indicaterImagename = imageName
                case .FL(let imageName, _):
                    indicaterImagename = imageName
                case .BL(let imageName, _):
                    indicaterImagename = imageName
                case .BR(let imageName, _):
                    indicaterImagename = imageName
                }
                rotationIndicator.image = UIImage(named: indicaterImagename + "_gray")
                
                contentLabel.attributedText = content.text?.setAttributesFitDetailLayout(ContentStyle.Detail)
          
        }
    }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
