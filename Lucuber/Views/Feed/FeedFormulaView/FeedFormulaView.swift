//
//  FeedFormulaView.swift
//  Lucuber/Users/howard/Documents/PracticeDemo/Lucuber/Lucuber/Views/Feed/FeedFormulaView/FeedFormulaView.swift
//
//  Created by Howard on 7/25/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import Kingfisher

class FeedFormulaView: UIView {
    
    class func creatFeedFormulaViewFromNib() -> FeedFormulaView {
        return NSBundle.mainBundle().loadNibNamed("FeedFormulaView", owner: nil, options: nil).last! as! FeedFormulaView
    }
    
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
    @IBOutlet weak var indicatorView: CategoryIndicaterView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor
        self.layer.borderWidth = 1.0
        
    }

}
