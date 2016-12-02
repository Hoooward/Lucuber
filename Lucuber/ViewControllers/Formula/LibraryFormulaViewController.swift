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
    
    private lazy var indicatorView = UpdateLibraryErrorView(frame: UIScreen.main.bounds)
    
    // MARK: - Life Cycle
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
        updateDataVersion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func updateDataVersion() {
        
        // Realm is no data
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
            
        } else {
            
            let currentVersion = UserDefaults.dataVersion()
            
            fetchPreferences(failureHandler: {
                reason, errorMessage in
                defaultFailureHandler(reason, errorMessage)
                
            }, completion: { newVersion in
               
                if currentVersion == newVersion {
                    return
                }
                
                CubeAlert.confirmOrCancel(title: "更新", message: "检测到公式库有可用更新, 是否需要现在更新? 不会消耗太多流量哦哦~", confirmTitle: "恩, 就是现在", cancelTitles: "暂不更新", inViewController: self, confirmAction: {
                    
                    updateLibraryDate(failureHandeler: {
                        reason, errorMessage in
                        defaultFailureHandler(reason, errorMessage)
                        
                    }, completion: {
                        
                        UserDefaults.setDataVersion(newVersion)
                        self.collectionView?.reloadData()
                        
                    })
                    
                }, cancelAction: {
                    
                })
            })
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Target & Action
    
}
