//
//  fullLayout.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class DetailFormulaLayout: UICollectionViewFlowLayout {
    
    override func prepareLayout() {
        
        super.prepareLayout()
        itemSize = screenBounds.size
        scrollDirection = .Horizontal
        collectionView!.pagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }
  
}
