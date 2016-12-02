//
//  MyFormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit


class MyFormulaViewController: BaseCollectionViewController {
    
    // MARK: - Properties
    
    let refreshControl = UIRefreshControl()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userMode = .card
        uploadMode = .my
        
        seletedCategory = UserDefaults.getSeletedCategory(mode: uploadMode)
        
        refreshControl.addTarget(self, action: #selector(MyFormulaViewController.refresh), for: .valueChanged)
        refreshControl.layer.zPosition = -1
        collectionView?.alwaysBounceVertical = true
        
        refreshControl.bounds.origin.y = -44
        // self.collectionView?.addSubview(refreshControl)
        
         updateMyFormula()
      
    }
    
    func updateMyFormula() {
        
        if isUploadingFormula {
            return
        }
        
        isUploadingFormula = true
        
        if formulasData.isEmpty {
            
            self.view.addSubview(self.vistorView)
            self.searchBar.isHidden = true
            
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
    
    // MARK: - Target & Action
    
    @objc private func refresh() {
        
        
        if isUploadingFormula {
            return
        }
        
        fetchDiscoverFormula(with: self.uploadMode, categoty: self.seletedCategory, failureHandler: { error in
            
            self.searchBar.isHidden = true
            self.isUploadingFormula = false
            self.view.addSubview(self.vistorView)
            self.isUploadingFormula = false
            
            printLog(error)
        }, completion: {
            formulas in
            
            delay(1) {
                self.collectionView?.reloadData()
                self.refreshControl.endRefreshing()
            }
            
        })
    
    }
    
    
    

    /*
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
 */
}

