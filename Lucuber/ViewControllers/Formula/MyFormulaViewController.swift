//
//  MyFormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    override open func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        
        if self.isTracking {
            
            let diff = contentInset.top - self.contentInset.top
            var translation = self.panGestureRecognizer.translation(in: self)
            translation.y -= diff * 3.0 / 2.0
            self.panGestureRecognizer.setTranslation(translation, in: self)
        }
        
        super.setContentOffset(contentOffset, animated: animated)
    }
}

class MyFormulaViewController: BaseCollectionViewController {
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userMode = .card
        uploadMode = .my
        
        
        seletedCategory = UserDefaults.getSeletedCategory(mode: uploadMode)
        
        
        uploadingFormulas(with: uploadMode, category: seletedCategory, finish: {
            
            self.collectionView?.reloadData()
            
        })
        
        refreshControl.addTarget(self, action: #selector(MyFormulaViewController.refresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        collectionView?.alwaysBounceVertical = true
        
        refreshControl.bounds.origin.y = -44
        self.collectionView?.addSubview(refreshControl)
      
    }
    
    func refresh() {
        
        uploadingFormulas(with: uploadMode, category: seletedCategory, finish: {
            
            
            delay(2, clouser: {
                
                self.collectionView?.reloadData()
                self.refreshControl.endRefreshing()
                
            })
        })
            
    }
    
    


}
