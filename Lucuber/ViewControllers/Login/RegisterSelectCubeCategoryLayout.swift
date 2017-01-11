//
//  RegisterSelectCubeCategoryLayout.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/11.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit


final class RegisterSelectCubeCategoryLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let _layoutAttirbutes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        let layoutAttributes = _layoutAttirbutes.map({
            $0.copy() as! UICollectionViewLayoutAttributes
        })
        
        var rowCollections = [CGFloat: [UICollectionViewLayoutAttributes]]()
        
        for (_, attributes) in layoutAttributes.enumerated() {
            let centerY = attributes.frame.midY
            
            if let rowCollection = rowCollections[centerY] {
                var rowCollection = rowCollection
                rowCollection.append(attributes)
                rowCollections[centerY] = rowCollection
                
            } else {
                rowCollections[centerY] = [attributes]
            }
        }
        
        for (_, rowCollection) in rowCollections {
            
            let rowItemsCount = rowCollection.count
            
            // 每一行所有 items 的宽度
            var aggregateItemsWidth: CGFloat = 0
            for attributes in rowCollection {
                aggregateItemsWidth += attributes.frame.width
            }
            
            var previousFrame = CGRect.zero
            
            let rowFullWidth: CGFloat = rowCollection.map({ $0.frame.width }).reduce(0, +) + CGFloat(rowItemsCount - 1) * minimumInteritemSpacing
            
            let firstOffset: CGFloat
            
            if let collectionView = collectionView {
                firstOffset = (collectionView.frame.width - rowFullWidth) / 2
            } else {
                fatalError()
            }
            
            for attributes in rowCollection {
                
                var itemFrame = attributes.frame
                
                if attributes.representedElementCategory == .cell {
                    
                    if previousFrame.equalTo(CGRect.zero) {
                        itemFrame.origin.x = firstOffset
                    } else {
                        itemFrame.origin.x = previousFrame.maxX + minimumInteritemSpacing
                    }
                    
                    attributes.frame = itemFrame
                }
                
                previousFrame = itemFrame
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
