//
//  DeatilHeaderCollectionViewLayout.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/29.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class DeatilHeaderCollectionViewLayout: UICollectionViewFlowLayout {
    
    var previousOffsetx: CGFloat = 0
    
    override func prepare() {
        super.prepare()
        self.scrollDirection = .horizontal
        self.minimumLineSpacing = 6
        
        collectionView?.decelerationRate = UIScrollViewDecelerationRateNormal
        let margin = Config.FormulaDetail.screenMargin
        let imageWidth = UIScreen.main.bounds.width - margin - margin
//        let screenWidth = UIScreen.main.bounds.width
         collectionView?.contentInset = UIEdgeInsets.init(top: 0, left: collectionView!.frame.width / 2 - imageWidth / 2, bottom: 0, right: collectionView!.frame.width / 2 - imageWidth / 2)
//        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
  
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let array = super.layoutAttributesForElements(in: rect)
        
        let visiableRect = CGRect(x: self.collectionView!.contentOffset.x, y: self.collectionView!.contentOffset.y, width: self.collectionView!.frame.width, height: self.collectionView!.frame.height)
        
        
        for attribute in array! {
            
            if !visiableRect.intersects(attribute.frame) {continue}
            let frame = attribute.frame
            let distance = abs(collectionView!.contentOffset.x + collectionView!.contentInset.left - frame.origin.x)
            let scale = min(max(1 - distance/(collectionView!.bounds.width), 0.85), 1)
            attribute.transform = CGAffineTransform(scaleX: scale, y: scale)
            
        }
        
        return array
        
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

