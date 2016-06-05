//
//  NormalCollectionViewLayout.swift
//  Lucuber
//
//  Created by Howard on 6/5/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class NormalCollectionViewLayout: UICollectionViewFlowLayout {

    override func prepareLayout() {
        super.prepareLayout()
        itemSize = CGSize(width: screenWidth, height: 80)
        sectionInset = UIEdgeInsetsZero
    }
}
