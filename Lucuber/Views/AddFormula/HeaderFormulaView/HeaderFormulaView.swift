//
//  HeaderFormulaView.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class HeaderFormulaView: UIView {

    @IBOutlet var imageButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var creatTimeLabel: UILabel!
    @IBOutlet var creatUserLabel: UILabel!
    @IBOutlet var centerBackView: UIView!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    private func makeUI() {
//        addSubview(categoryView)
      
    
        
        categoryView.frame.origin = CGPoint(x: screenWidth - categoryView.frame.size.width + 30, y: centerBackView.frame.origin.y + 10)
        print(categoryView.frame)
        imageButton.layer.cornerRadius = 8
        imageButton.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        let categoryViewTop = NSLayoutConstraint(item: categoryView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 10)
//        let categoryViewTrailing = NSLayoutConstraint(item: categoryView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -15)
//        NSLayoutConstraint.activateConstraints([categoryViewTop, categoryViewTrailing])
        

    
    }
    
    lazy var categoryView: CubeCategoryItemView = {
        let view = CubeCategoryItemView()
        view.configureWithCategory("3x3x3")
        //TODO: 这个frame有问题
        view.frame = view.bubbleImageView.frame
        return view
    }()

    
}
