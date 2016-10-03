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
    
    // MARK: - Properties
    
    let indicatorView = UpdateLibraryErrorView(frame: UIScreen.main.bounds)
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userMode = .normal
        uploadMode = .library
        
        seletedCategory = UserDefaults.getSeletedCategory(mode: uploadMode)

        NotificationCenter.default.addObserver(self, selector: #selector(LibraryFormulaViewController.reloadFormulasData), name: Notification.Name.needReloadFormulaFromRealmNotification, object: nil)
        
        
        indicatorView.retryUpdateLibrary = { [unowned self] in
            
            HUD.show(.label("正在更新公式库..."))
            
            fetchLibraryFormulaFormLeanCloudAndSaveToRealm(completion: { [unowned self] in
                
                HUD.flash(.label("更新成功"), delay: 2)
                self.reloadFormulasData()
                
                }, failureHandler: { _ in
                    HUD.flash(.label("更新失败，似乎已断开与互联网的连接。"), delay: 2)
            })
            
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Target & Action
    
    
    func reloadFormulasData() {
        
        uploadingFormulas(with: uploadMode, category: seletedCategory, finish: {
            
            self.collectionView?.reloadData()
        })
        
    }
    
    override func uploadingFormulas(with mode: UploadFormulaMode, category: Category, finish: (() -> Void)?) {
        
        if isUploadingFormula {
            finish?()
            return
        }
        
        isUploadingFormula = true
        
        func fetchFormulaFromRealm() {
            
            self.isUploadingFormula = false
            
            self.indicatorView.removeFromSuperview()
            
            let result = getFormulsFormRealmWithMode(mode: mode, category: category)
            
            if result.isEmpty {
                
                self.searchBar.isHidden = true
                self.indicatorView.status = .normal
                self.view.addSubview(self.indicatorView)
                
            } else {
                self.searchBar.isHidden = false
                self.indicatorView.removeFromSuperview()
                self.formulasData = self.parseFormulasData(with: result)
            }
            
            finish?()
 
        }
        
        let completion: () -> Void = { formulas in
            
            HUD.flash(.label("更新成功"), delay: 2)
            
            fetchFormulaFromRealm()
        }
        
        let failureHandler: (NSError) -> Void = { [unowned self] error in
            
            HUD.flash(.label("更新失败，似乎已断开与互联网的连接。"), delay: 2)
            
            self.isUploadingFormula = false
            
            let result = getFormulsFormRealmWithMode(mode: mode, category: category)
            
            if result.isEmpty {
               
                self.searchBar.isHidden = true
                self.indicatorView.status = .normal
                self.view.addSubview(self.indicatorView)
                
            } else {
                
                self.searchBar.isHidden = false
                self.indicatorView.removeFromSuperview()
                self.formulasData = self.parseFormulasData(with: result)
            }
            
            finish?()
            
        }
        
        if let currentUser = AVUser.current(), currentUser.getNeedUpdateLibrary() {
           
            fetchLibraryFormulaFormLeanCloudAndSaveToRealm(completion: completion, failureHandler: failureHandler)
            
        }  else {
            
            fetchFormulaFromRealm()
            
        }
        
        
    }


}
