//
//  FormulaDetailContentCell.swift
//  Lucuber
//
//  Created by Howard on 6/5/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaDetailContentCell: UICollectionViewCell {

    @IBOutlet var formulaLabel: UILabel!
    @IBOutlet var indicaterImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var showHeight: CGFloat = 0
    var formulaString: String = "" {
        didSet {
            
//            let attributesStr = formulaString.setAttributesFitDetailLayout()
//             //如果文字+top约束 > 图片高度+top约束
//             showHeight = attributesStr.boundingRectWithSize(CGSizeMake(screenWidth - 38 - 30 - 4 - 20 - 20 - 38, CGFloat(MAXFLOAT)), options:NSStringDrawingOptions.init(rawValue: 1), context: nil).height
// 
            
            formulaLabel.attributedText = formulaString.setAttributesFitDetailLayout(.Detail)
            
        }
    }

}
