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
            
            HUD.show(.label("更新公式库..."))
            
            syncFormula(with: self.uploadMode, categoty: nil, completion: {
                _ in
                
                HUD.flash(.label("更新成功"), delay: 2)
                self.collectionView?.reloadData()
            
            }, failureHandler: {
                _ in
                HUD.flash(.label("更新失败，似乎已断开与互联网的连接。"), delay: 2)
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func updateDataVersion() {
        
        let currentVersion = UserDefaults.dataVersion()
        
        syncPreferences(completion: {
            version in
            
            if currentVersion != version {
                
                CubeAlert.confirmOrCancel(title: "更新", message: "检测到公式库有可用更新, 是否需要现在更新? 不会消耗太多流量哦哦~", confirmTitle: "恩, 就是现在", cancelTitles: "起开", inViewController: self, confirmAction: {
                    
                    self.indicatorView.retryUpdateLibrary?()
                
                }, cancelAction: {
                    
                })
            }
            
        }, failureHandler: { error in printLog(error) })
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Target & Action
    
}
