//
//  FormulaView.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/21.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FeedFormulaView: UIView {
    
    var tapAction: (() -> Void)?
 
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
        
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(FeedFormulaView.tap(sender:)))
        self.addGestureRecognizer(tap)
    }
    
    func configViewWith(formula: Formula?) {
        
        guard let formula = formula else {
            return
        }
        
        nameLabel.text = formula.name
        
        indicatorView.configureWithCategory(category: formula.categoryString)
        let contents:[Content] = formula.contents.map { $0 }
        let flatResult = contents.filter({ $0.deleteByCreator == false })

        countLabel.text = "\(flatResult.count)个公式"
        
        if let firstContent = flatResult.first {
            contentLabel.text = firstContent.text
        }
        
        if let image = formula.pickedLocalImage {
            imageView.image = image
        } else {
            imageView.image = nil
            imageView.backgroundColor = UIColor.lightGray
        }
        
    }
    
    func tap(sender: UIGestureRecognizer) {
        tapAction?()
    }
}
