//
//  FormulaView.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/21.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FeedFormulaView: UIView {
 
    var formula: Formula? {
        didSet {
            
            if let formula = formula {
                nameLabel.text = formula.name
            }
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var indicatorView: CategoryIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        self.layer.borderWidth = 1.0
        
    }
    
    func configViewWith(formula: Formula) {
    }
    
}
