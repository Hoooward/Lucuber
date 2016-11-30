//
//  DeatilHeaderCollectionViewLayout.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/29.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class DeatilHeaderCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        self.scrollDirection = .horizontal
        
        self.minimumLineSpacing = Config.DetailHeaderView.collectionViewMinimumLineSpacing
        collectionView?.decelerationRate = UIScrollViewDecelerationRateNormal
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: Config.DetailHeaderView.screenMargin, bottom: 0, right: Config.DetailHeaderView.screenMargin)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        guard let collectionView = collectionView else {
            return nil
        }
        
        let cacheAttributes = NSArray(array: attributes, copyItems: true) as! [UICollectionViewLayoutAttributes]
        
        let visiableRect = CGRect(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y, width: collectionView.frame.width, height: collectionView.frame.height)
        
        for attribute in cacheAttributes {
            
            if !visiableRect.intersects(attribute.frame) {continue}
            let frame = attribute.frame
            let distance = abs(collectionView.contentOffset.x + collectionView.contentInset.left - frame.origin.x)
            let scale = min( max( 1 - distance / (collectionView.bounds.width), 0.85), 1)
            attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
            
        }
        
        return cacheAttributes
        
    }
    
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        var point = proposedContentOffset
////        let x = proposedContentOffset.x / self.itemSize.width + self.minimumLineSpacing
////        
////        point.x = x * (self.itemSize.width + self.minimumLineSpacing)
//        
//        if proposedContentOffset.x > 0 + self.itemSize.width / 3.0 {
//            
//        }
////
//        return point
//    }
    
    
}

