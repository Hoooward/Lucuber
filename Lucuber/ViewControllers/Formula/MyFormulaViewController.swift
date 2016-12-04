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
    
    let refreshControl = UIRefreshControl()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userMode = .card
        uploadMode = .my
        
        seletedCategory = UserDefaults.getSeletedCategory(mode: uploadMode)
        
        pushCurrentUserUpdateInformation()
      
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
    
    public func pushCurrentUserUpdateInformation() {
        
        
        
        if let currentUser = currentUser(in: realm) {
            
            // 更新用户修改的公式
            let unPusheFormula = unPushedFormula(with: currentUser, inRealm: realm)
            
            if !unPusheFormula.isEmpty {
                
                for formula in unPusheFormula {
                    
                    pushFormulaToLeancloud(with: formula, failureHandler: {
                        reason, errorMessage in
                        
                        defaultFailureHandler(reason, errorMessage)
                        
                    }, completion: {
                        _ in
                        self.realm.refresh()
                        printLog("更新公式信息到Leancloud成功")
                    })
                }
            }
            // Leanclooud 断标记删除的内容
            let deletedFormula = deleteByCreatorFormula(with: currentUser, inRealm: realm)
            var discoverFormulas = [DiscoverFormula]()
            
            if !deletedFormula.isEmpty {
                
                for formula in deletedFormula {
                    
                    if formula.lcObjectID == "" {
                        
                        try? realm.write {
                            realm.delete(formula)
                        }
                        realm.refresh()
                        
                    } else {
                        
                        let discoverFormula = DiscoverFormula(className: "DiscoverFormula", objectId: formula.lcObjectID)
                        
                       discoverFormula.setValue(true, forKey: "deletedByCreator")
                        
                       discoverFormulas.append(discoverFormula)
                    }
                }
            }
            
            if !discoverFormulas.isEmpty {
                
                AVObject.saveAll(inBackground: discoverFormulas, block: { [weak self] success, error in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if error != nil {
                        defaultFailureHandler(Reason.network(error), "删除公式推送失败")
                    }
                    
                    if success {
                        printLog("删除公式推送成功, 共删除 \(discoverFormulas.count) 个公式")
                        try? strongSelf.realm.write {
                            strongSelf.realm.delete(deletedFormula)
                        }
                        strongSelf.realm.refresh()
                    }
                    
                })
            }
            
            let deletedContents = deleteByCreatorRContent(with: currentUser, inRealm: realm)
            
            var discoverContents = [DiscoverContent]()
            if !deletedContents.isEmpty {
                
                for content in deletedContents {
                    
                    if content.lcObjectID == "" {
                        try? realm.write {
                            realm.delete(content)
                        }
                        realm.refresh()
                        
                    } else {
                        
                        let discoverContent = DiscoverContent(className: "DiscoverContent", objectId: content.lcObjectID)
                        discoverContent.setValue(true, forKey: "deletedByCreator")
                        discoverContents.append(discoverContent)
                    }
                }
            }
            
            if !discoverContents.isEmpty {
               
                AVObject.saveAll(inBackground: discoverContents, block: { [weak self] success, error in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if error != nil {
                        defaultFailureHandler(Reason.network(error), "删除公式Content推送失败")
                    }
                    
                    if success {
                        printLog("删除公式Content信息推送成功, 共删除 \(discoverContents.count) 个Content")
                        try? strongSelf.realm.write {
                            strongSelf.realm.delete(deletedContents)
                        }
                        strongSelf.realm.refresh()
                    }
                })
            }
            
            
        }
    }
    
}

