//
//  FormulaCollectionLayout.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaCollectionLayout: UICollectionViewFlowLayout {
    
    var userMode: FormulaUserMode?
    override func prepareLayout() {
        if let userMode = userMode {
            switch userMode {
            case .Card:
                itemSize = CGSize(width: (screenWidth - (10 + 10 + 10)) * 0.5, height: 280)
                sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            case .Normal:
                itemSize = CGSize(width: screenWidth, height: 80)
                sectionInset = UIEdgeInsetsZero
            }
        }
        
        headerReferenceSize = CGSize(width: screenWidth, height: 15)
    }
    
    /**
     override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
     let attris = super.layoutAttributesForElementsInRect(rect)
     print(#function)
     return attris
     }
     
     override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
     print(#function)
     return nil
     }
     */

}
