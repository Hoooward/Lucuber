//
//  LibraryFormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Realm
import PKHUD
import AVOSCloud


class LibraryFormulaViewController: BaseCollectionViewController {
    
    private lazy var indicatorView = UpdateLibraryErrorView(frame: UIScreen.main.bounds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userMode = .normal
        uploadMode = .library
        
        seletedCategory = UserDefaults.getSeletedCategory(mode: uploadMode)
        
        indicatorView.retryUpdateLibrary = { [unowned self] in
            
            updateLibraryDate(failureHandeler: {
                reason, errorMessage in
                defaultFailureHandler(reason, errorMessage)
                
            }, completion: { [unowned self] in
                
                self.indicatorView.removeFromSuperview()
                self.searchBar.isHidden = false
                self.collectionView?.reloadData()
                
            })
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(LibraryFormulaViewController.afterUploadInformation), name: Config.NotificationName.updateLibraryFormulas, object: nil)
        
        updateDataVersion()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func afterUploadInformation() {
       collectionView?.reloadData()
    }
    
    private func updateDataVersion() {
        
        if formulasData.isEmpty {
            
            updateLibraryDate(failureHandeler: {
                reason, errorMessage in
                defaultFailureHandler(reason, errorMessage)
                self.view.addSubview(self.indicatorView)
                self.searchBar.isHidden = true
                
            }, completion: {
                self.collectionView?.reloadData()
                self.indicatorView.removeFromSuperview()
                self.searchBar.isHidden = false
                
            })
        }
    }
}
