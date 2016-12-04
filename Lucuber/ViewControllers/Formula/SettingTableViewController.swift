//
//  SettingTableViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/3.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        // 恢复备份
        if indexPath.row == 0 {
            
            fetchDiscoverFormula(with: UploadFormulaMode.my , categoty: nil,  failureHandler: {
                reason, errorMessage in
                
                defaultFailureHandler(reason, errorMessage)
                
//                self.isUploadingFormula = false
                
                
            }, completion: { formulas in
//                
                printLog("更新数据成功")
//                if self.formulasData.isEmpty {
//                    
//                } else {
//                    
//                    self.vistorView.removeFromSuperview()
//                    self.searchBar.isHidden = false
//                    self.isUploadingFormula = false
//                    
//                    self.collectionView?.reloadData()
//                }
                
                
            })
            
        }
        
        // 上传备份
        if indexPath.row == 1 {
            
            
//            pushCurrentUserUpdateInformation()
        }
    }
}
