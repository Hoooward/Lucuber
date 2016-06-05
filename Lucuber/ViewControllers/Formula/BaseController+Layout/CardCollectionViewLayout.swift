//
//  CardCollectionViewLayout.swift
//  Lucuber
//
//  Created by Howard on 6/5/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class CardCollectionViewLayout: UICollectionViewFlowLayout {

    override func prepareLayout() {
        super.prepareLayout()
        itemSize = CGSize(width: (screenWidth - (10 + 10 + 10)) * 0.5, height: 280)
        sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
