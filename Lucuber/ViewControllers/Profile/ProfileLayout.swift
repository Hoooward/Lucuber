//
//  ProfileLayout.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/29.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
let profileAvatarAspectRatio: CGFloat = 12.0 / 16.0

final class ProfileLayout: UICollectionViewFlowLayout {
    
    public var scrollUpAction: ((CGFloat) -> Void)?
    let topBarHeight: CGFloat = 64
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        let contentInset = collectionView!.contentInset
        let contentOffset = collectionView!.contentOffset
        
        let minY = -contentInset.top
        
        if contentOffset.y < minY {
            
            let deltaY = abs(contentOffset.y - minY)
            
            if let layoutAttributes = layoutAttributes {
                for attributes in layoutAttributes {
                    
                    if attributes.indexPath.section == ProfileViewController.Section.header.rawValue {
                        var frame = attributes.frame
                        frame.size.height = max(minY, collectionView!.bounds.width * profileAvatarAspectRatio + deltaY)
                        frame.origin.y = frame.minY - deltaY
                        attributes.frame = frame
                        break
                    }
                }
            }
            
        } else {
           
            let coverHeight = collectionView!.bounds.width * profileAvatarAspectRatio
            let coverHideHeight = coverHeight - topBarHeight
            
            if contentOffset.y > coverHideHeight {
                
                let deltaY = abs(contentOffset.y - minY)
                
                if let layoutAttributes = layoutAttributes {
                    for attributes in layoutAttributes {
                        
                        if attributes.indexPath.section == ProfileViewController.Section.header.rawValue {
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
                scrollUpAction?(1.0 - (coverHideHeight - contentOffset.y) / coverHideHeight)
            } else {
                scrollUpAction?(1.0)
            }
        }
        
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
