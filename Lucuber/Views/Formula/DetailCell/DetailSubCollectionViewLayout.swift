//
//  DetailSubCollectionViewLayout.swift
//  Lucuber
//
//  Created by Howard on 6/5/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class DetailSubCollectionViewLayout: UICollectionViewFlowLayout {

    //无效
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElementsInRect(rect)
        let contentInset = collectionView!.contentInset
        let contentOffset = collectionView!.contentOffset
        
//        let minY = -contentInset.top
        print(contentInset.top)
        print(contentOffset)
        
        
        
        if let layoutAttributes = layoutAttributes {
            for attributes in layoutAttributes {
                if attributes.indexPath.section == ShowDetailCell.Section.Formula.rawValue {
//                    var frame = attributes.frame
                    print("frame = \(attributes)")
                }
            }
        }
        return layoutAttributes
    }
}
