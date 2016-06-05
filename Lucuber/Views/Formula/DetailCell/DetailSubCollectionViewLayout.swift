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
        
        let minY = -contentInset.top
        print(contentInset.top)
        print(contentOffset)
        
        if contentOffset.y < minY {
            let deltaY = abs(contentOffset.y - minY)
            
            if let layoutAttributes = layoutAttributes {
                for attributes in layoutAttributes {
                    if attributes.indexPath.section == ShowDetailCell.Section.Header.rawValue {
                        var frame = attributes.frame
                        frame.size.height = max(minY, CGRectGetWidth(collectionView!.bounds) * (12.0/16.0) + deltaY)
                        frame.origin.y = CGRectGetMinY(frame) - deltaY
                        attributes.frame = frame
                    }
                }
            }
        }
        return layoutAttributes
    }
}
