//
//  MyFormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift


class MyFormulaViewController: BaseCollectionViewController {
    
    // MARK: - Properties
    
    let refreshControl = UIRefreshControl()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userMode = .card
        uploadMode = .my
        
        seletedCategory = UserDefaults.getSeletedCategory(mode: uploadMode)
        
//        updateMyFormula()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let realm = try? Realm() else {
            return
        }
        
        // 如果用户删除公式后, 此 category 为空, 重设 seletedCategory 为 x3x3
        if formulasCountWith(uploadMode, category: seletedCategory, inRealm: realm) <= 0 {
            
            seletedCategory = .x3x3
            
            UserDefaults.setSelected(category: .x3x3, mode: uploadMode)
            
            if let button = parent?.navigationItem.rightBarButtonItem as? CategoryButton {
                button.seletedCategory = .x3x3
            }
            
        }
        
        
        if formulasData.isEmpty {
            
            self.searchBar.isHidden = true
            self.view.addSubview(vistorView)
            
        } else {
            
            self.searchBar.isHidden = false
            vistorView.removeFromSuperview()
            
        }
    }
    
    func updateMyFormula() {
      
        if formulasData.isEmpty {
            self.view.addSubview(self.vistorView)
            self.searchBar.isHidden = true
        }
        
        fetchDiscoverFormula(with: self.uploadMode, categoty: self.seletedCategory, failureHandler: {
            reason, errorMessage in
            
            defaultFailureHandler(reason, errorMessage)
            
            self.isUploadingFormula = false
            
            
        }, completion: { formulas in
            
            if self.formulasData.isEmpty {
                
            } else {
                
                self.vistorView.removeFromSuperview()
                self.searchBar.isHidden = false
                self.isUploadingFormula = false
                
                self.collectionView?.reloadData()
            }
            
            
        })
 
        
    }
    

}

