//
//  MyFormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

//extension UICollectionView {
//    
//    override open func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
//        
//        if self.isTracking {
//            
//            let diff = contentInset.top - self.contentInset.top
//            var translation = self.panGestureRecognizer.translation(in: self)
//            translation.y -= diff * 3.0 / 2.0
//            self.panGestureRecognizer.setTranslation(translation, in: self)
//        }
//        
//        super.setContentOffset(contentOffset, animated: animated)
//    }
//}

class MyFormulaViewController: BaseCollectionViewController {
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userMode = .card
        uploadMode = .my
        
        
        seletedCategory = UserDefaults.getSeletedCategory(mode: uploadMode)
        
//        
//        uploadingFormulas(with: uploadMode, category: seletedCategory, finish: {
//            
//            self.collectionView?.reloadData()
//            
//        })
        
        refreshControl.addTarget(self, action: #selector(MyFormulaViewController.refresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        collectionView?.alwaysBounceVertical = true
        
        refreshControl.bounds.origin.y = -44
        self.collectionView?.addSubview(refreshControl)
        
      
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshControl.beginRefreshing()
        self.collectionView?.setContentOffset(CGPoint(x: 0, y: -(self.collectionView!.contentInset.top + self.refreshControl.frame.size.height - 44)), animated: true)
        refresh()
    }
    
    
   @objc private func refresh() {
        
        uploadingFormulas(with: uploadMode, category: seletedCategory, finish: {
            
            delay(1) {
                self.collectionView?.reloadData()
                self.refreshControl.endRefreshing()
            }
            
        })
    }
    
    

    override func uploadingFormulas(with mode: UploadFormulaMode, category: Category, finish: (() -> Void)?) {
        
        if isUploadingFormula {
            finish?()
            return
        }
        
        isUploadingFormula = true
        
        let failureHandler: (_ error: NSError?) -> Void = {
            error in
            
            DispatchQueue.main.async { [unowned self] in
                
                self.searchBar.isHidden = true
                self.isUploadingFormula = false
                self.view.addSubview(self.vistorView)
                self.isUploadingFormula = false
                finish?()
                
                // 提示失败
                
            }
        }
        
        let completion: ([Formula]) -> Void = { formulas in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                if formulas.isEmpty {
                    
                    strongSelf.searchBar.isHidden = true
                    strongSelf.view.addSubview(strongSelf.vistorView)
                    
                } else {
                    
                    strongSelf.searchBar.isHidden = false
                    strongSelf.formulasData = strongSelf.parseFormulasData(with: formulas)
                    strongSelf.vistorView.removeFromSuperview()
                }
                
                strongSelf.isUploadingFormula = false
                
                finish?()
            }
        }
        
        fetchFormulaWithMode(uploadingFormulaMode: uploadMode, category: category, completion: completion, failureHandler: failureHandler)
        
    }
}

