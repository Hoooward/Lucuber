//
//  EditMasterViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/11.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift

final class EditMasterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomButtonView: BottomButtonView!
    
    fileprivate var realm: Realm = try! Realm()
    fileprivate var me: RUser?
    
    fileprivate var cubeCategarys: [CubeCategoryMaster]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "擅长"
        me = currentUser(in: realm)
        
        fetchCubeCategorys(failureHandler: { reason, errorMessage in
            defaultFailureHandler(reason, errorMessage)
        }, completion: { [weak self] results in
            
            self?.cubeCategarys = results.map {
                let cube = CubeCategoryMaster()
                cube.atRUser = self?.me
                cube.categoryString = $0.categoryString
                return cube
            }
        })
        
        var contentInset = tableView.contentInset
        contentInset.bottom = bottomButtonView.frame.height
        tableView.contentInset = contentInset
        
        tableView.rowHeight = 60
        
        var separatorInset = tableView.separatorInset
        separatorInset.left = CubeRuler.iPhoneHorizontal(15, 20, 25).value
        tableView.separatorInset = separatorInset
        
        tableView.registerNib(of: EditMasterCell.self)
        
        bottomButtonView.title = "添加技能"
        
        bottomButtonView.tapAction = { [weak self] in
            
            guard let categorys = self?.cubeCategarys else {
                return
            }
            
            let storyboard = UIStoryboard(name: "Resgin", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RegisterSelectCubeCategoryViewController") as! RegisterSelectCubeCategoryViewController
            
            vc.categorys = categorys
            vc.seletedCategorys = self?.me?.cubeCategoryMasterList.map { $0 }
            
            vc.pushNewUserInfoAction = { [weak self] in
                
                pushMyInfoToLeancloud(completion: {
                    
                    self?.tableView.reloadData()
                    
                }, failureHandler: { reason, errorMessage in
                    defaultFailureHandler(reason, errorMessage)
                })
            }
            
            vc.selectCategoryAction = { [weak self] category, selected in
                
                guard let strongSelf = self else {
                    return false
                }
                
                guard let myCubeCategorysList = strongSelf.me?.cubeCategoryMasterList else {
                    return false
                }
                
                let myCubeCategorys: [CubeCategoryMaster] = myCubeCategorysList.map { $0 }
                
                var success = false
                
                if selected {
                    
                    if myCubeCategorys.filter({ $0.categoryString == category.categoryString }).count == 0 {
                        
                        guard let realm = try? Realm() else {
                            return success
                        }
                        // 如果不存在, 再数据库中创建
                        try? realm.write {
                            let newCategory = CubeCategoryMaster()
                            newCategory.categoryString = category.categoryString
                            newCategory.atRUser = strongSelf.me
                            realm.add(newCategory)
                        }
                        success = true
                        
                    }
                    
                } else {
                    
                    let categoryToDelete = myCubeCategorys.filter({ $0.categoryString == category.categoryString })
                    if categoryToDelete.count > 0 {
                        for category in categoryToDelete {
                            guard let realm = try? Realm() else {
                                return success
                            }
                            if let myCategory = myCubeCategoryMasterWith(category.categoryString, inRealm: realm) {
                                try? realm.write {
                                    realm.delete(myCategory)
                                }
                            }
                        }
                        success = true
                    }
                }
                
                strongSelf.tableView.reloadData()
                return success
            }
            
            self?.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension EditMasterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let me = me {
            return me.cubeCategoryMasterList.count
    }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: EditMasterCell = tableView.dequeueReusableCell(for: indexPath)
        
        var category: CubeCategoryMaster?
        
        if let me = me {
            category = me.cubeCategoryMasterList[indexPath.row]
        }
        
        cell.category = category
        
        cell.removeCategoryAction = { [weak self] cell, category in
            
            if let me = self?.me {
                
                let rowToDelete: Int? = me.cubeCategoryMasterList.index(of: category)
                
                try? self?.realm.write {
                    self?.realm.delete(category)
                    
                    cell.category = nil
                }
                
                if let rowToDelete = rowToDelete {
                    let indexPathToDelete = IndexPath(row: rowToDelete, section: 0)
                    self?.tableView.deleteRows(at: [indexPathToDelete], with: .automatic)
                }
                
                self?.tableView.reloadData()
            }
            
        }
        
        return cell
    }
}
