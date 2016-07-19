//
//  DetailSubCollectionViewLayout.swift
//  Lucuber
//
//  Created by Howard on 6/5/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

let profileAvatarAspectRatio: CGFloat = 12.0 / 16.0

class DetailSubCollectionViewLayout: UICollectionViewFlowLayout {

    var scrollUpAction: ((progress: CGFloat) -> Void)?
  
    let topBarsHeight: CGFloat = 64
    //无效
    
    /*
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let layoutAttributes = super.layoutAttributesForElementsInRect(rect)
        let contentInset = collectionView!.contentInset
        let contentOffset = collectionView!.contentOffset
        
        let minY = -contentInset.top
        
        if contentOffset.y < minY {
            let deltaY = abs(contentOffset.y - minY)
            
            if let layoutAttributes = layoutAttributes {
                for attributes in layoutAttributes {
                    if attributes.indexPath.section == FormulaDetailCell.Section.Header.rawValue {
                        var frame = attributes.frame
                        frame.size.height = max(minY, CGRectGetWidth(collectionView!.bounds) * profileAvatarAspectRatio + deltaY)
                        frame.origin.y = CGRectGetMinY(frame) - deltaY
                        attributes.frame = frame
                        
                        break
                    }
                }
            }
            
        } else {
            let coverHeight = CGRectGetWidth(collectionView!.bounds) * profileAvatarAspectRatio
            let coverHideHeight = coverHeight - topBarsHeight
            
            if contentOffset.y > coverHideHeight {
                
                let deltaY = abs(contentOffset.y - minY)
                
                if let layoutAttributes = layoutAttributes {
                    for attributes in layoutAttributes {
                        if attributes.indexPath.section == FormulaDetailCell.Section.Header.rawValue {
                            var frame = attributes.frame
                            frame.origin.y = deltaY - coverHideHeight
                            attributes.frame = frame
                            attributes.zIndex = 1000
                            
                            break
                        }
                    }
                }
            }
            
            if coverHideHeight > contentOffset.y {
                scrollUpAction?(progress: 1.0 - (coverHideHeight - contentOffset.y) / coverHideHeight)
                
            } else {
                scrollUpAction?(progress: 1.0)
            }
            
        }
        
        return layoutAttributes
    }
 */
}
