//
//  DetailSubCollectionView.swift
//  Lucuber
//
//  Created by Howard on 6/5/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class DetailSubCollectionView: UICollectionView {

  
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    
}

extension DetailSubCollectionView: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x < 0 {
            print(#function)
        }
    }
}
