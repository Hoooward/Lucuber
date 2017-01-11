//
//  MyFormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud


class MyFormulaViewController: BaseCollectionViewController {
    
    // MARK: - Properties
    
    var afterUploadFormulaInformationNotificationToken: NotificationToken? = nil
    
    let refreshControl = UIRefreshControl()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        afterUploadFormulaInformationNotificationToken = formulasData.addNotificationBlock { [weak self] changes in
//            
//            guard let strongSelf = self else {
//                return
//            }
//            
//            switch changes {
//                
//            case .initial(_):
//                strongSelf.collectionView?.reloadData()
//                printLog("初始化数据刷新了")
//                
//            case .update(_, deletions: _, insertions: _, modifications: _):
//                
//                strongSelf.collectionView?.reloadData()
//                printLog("更新数据刷新了")
//                
//            default:break
//            }
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyFormulaViewController.afterUploadInformation), name: NSNotification.Name.afterUploadUserInformationNotification, object: nil)
        
        userMode = .normal
        uploadMode = .my
        
        seletedCategory = UserDefaults.getSeletedCategory(mode: uploadMode)
        
        pushCurrentUserUpdateInformation()
      
    }
    
    deinit {
        afterUploadFormulaInformationNotificationToken?.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    func afterUploadInformation() {
        printLog("数据更新了")
        collectionView?.reloadData()
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

