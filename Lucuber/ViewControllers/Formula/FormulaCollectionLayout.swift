//
//  FormulaCollectionLayout.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaCollectionLayout: UICollectionViewFlowLayout {
    
    var userMode: FormulaUserMode?
    override func prepareLayout() {
        itemSize = CGSize(width: (screenWidth - (10 + 10 + 10)) * 0.5, height: 280)
    }

}
