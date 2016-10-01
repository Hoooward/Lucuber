//
//  DetailLayout.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/30.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class DetailLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
//        let size = CGSize(width: UIScreen.main.bounds.width - 1, height: UIScreen.main.bounds.height - 1)
        itemSize = UIScreen.main.bounds.size
        scrollDirection = .horizontal
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        
    }
}
