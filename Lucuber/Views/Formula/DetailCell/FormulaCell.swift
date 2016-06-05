//
//  FormulaCell.swift
//  Lucuber
//
//  Created by Howard on 6/5/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaCell: UICollectionViewCell {

    @IBOutlet var formulaLabel: UILabel!
    @IBOutlet var indicaterImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    var formulaString: String = "" {
        didSet {
            
//            let attributes = NSMutableAttributedString(string: formula)
////            let str = "(R U R' U) (R U' R' U') (R' F R F')"
//            
//            let pattern = "\\(.*?\\)"
//            
//            
//            do {
//                let a =  try NSRegularExpression(pattern:pattern, options: NSRegularExpressionOptions.init(rawValue: 0))
//                //           let result = a.rangeOfFirstMatchInString(str, options: NSMatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: str.characters.count))
//                let resu = a.matchesInString(formula, options: NSMatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: formula.characters.count))
//                
//                for s in resu {
//                    print(s.range)
//                    let stt = (formula as NSString).substringWithRange(s.range)
//                    attributes.addAttributes([NSForegroundColorAttributeName : UIColor.cubeTintColor()], range:s.range)
//                    print(stt)
//                }
//                
//                
//            } catch{
//                print(error)
//            }
            formulaLabel.attributedText = formulaString.setAttributesFitDetailLayout()
            
        }
    }

}
