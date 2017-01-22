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
    
    var afterUploadFormulaInformationNotificationToken: NotificationToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyFormulaViewController.afterUploadInformation), name: NSNotification.Name.afterUploadUserInformationNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyFormulaViewController.afterUploadInformation), name: Config.NotificationName.updateMyFormulas, object: nil)
        
        
        userMode = .normal
        uploadMode = .my
        
        seletedCategory = UserDefaults.getSeletedCategory(mode: uploadMode)
        
//        pushCurrentUserUpdateInformation()
      
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
        updateVistorViewStatus()
    }
    
    deinit {
        afterUploadFormulaInformationNotificationToken?.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    func afterUploadInformation() {
        updateVistorViewStatus()
        collectionView?.reloadData()
    }
    
    fileprivate func updateVistorViewStatus() {
        
        if formulasData.isEmpty {
            self.searchBar.isHidden = true
            self.view.addSubview(vistorView)
            
        } else {
            self.searchBar.isHidden = false
            vistorView.removeFromSuperview()
        }
    }
}
