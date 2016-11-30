//
//  DeatilHeaderCollectionViewLayout.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/29.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class DeatilHeaderCollectionViewLayout: UICollectionViewFlowLayout {
    
//    var previousOffsetx: CGFloat = 0
    
    override func prepare() {
        super.prepare()
        
        self.scrollDirection = .horizontal
        
        self.minimumLineSpacing = Config.DetailHeaderView.collectionViewMinimumLineSpacing
        collectionView?.decelerationRate = UIScrollViewDecelerationRateNormal
        
        let imageWidth =  Config.DetailHeaderView.imageViewWidth
//         collectionView?.contentInset = UIEdgeInsets.init(top: 0, left: collectionView!.frame.width / 2 - imageWidth / 2, bottom: 0, right: collectionView!.frame.width / 2 - imageWidth / 2)
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
        
        let visiableRect = CGRect(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y, width: collectionView.frame.width, height: collectionView.frame.height)
        
        for attribute in attributes {
            
            if !visiableRect.intersects(attribute.frame) {continue}
            let frame = attribute.frame
            let distance = abs(collectionView.contentOffset.x + collectionView.contentInset.left - frame.origin.x)
            let scale = min( max( 1 - distance / (collectionView.bounds.width), 0.85), 1)
            attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
            
        }
        
        return attributes
        
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

