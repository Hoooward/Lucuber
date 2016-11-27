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
            
            updateLibraryDateVersion(completion: { [unowned self] in
                
                self.indicatorView.removeFromSuperview()
                self.searchBar.isHidden = false
                
            }, failureHandeler: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateDataVersion()
    }
    
    private func updateDataVersion() {
        
        // Realm is no data
        if formulasData.isEmpty {
           
            updateLibraryDateVersion(completion: {
                
                self.collectionView?.reloadData()
                self.indicatorView.removeFromSuperview()
                self.searchBar.isHidden = false
                
            }, failureHandeler: {
                
                self.view.addSubview(self.indicatorView)
                self.searchBar.isHidden = true
 
            })
            
        } else {
            
            let currentVersion = UserDefaults.dataVersion()
            
            syncPreferences(completion: {
                version in
                
                if currentVersion != version {
                    
                    CubeAlert.confirmOrCancel(title: "更新", message: "检测到公式库有可用更新, 是否需要现在更新? 不会消耗太多流量哦哦~", confirmTitle: "恩, 就是现在", cancelTitles: "起开", inViewController: self, confirmAction: {
                        
                        updateLibraryDateVersion(completion: {
                            
                            UserDefaults.setDataVersion(version)
                            self.collectionView?.reloadData()
                            
                        }, failureHandeler: nil)
                        
                        }, cancelAction: {
                    })
                }
                
            }, failureHandler: { error in printLog(error) })
            
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Target & Action
    
}
