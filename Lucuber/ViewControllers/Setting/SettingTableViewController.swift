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

        let view = UIView()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        // 恢复备份
        if indexPath.row == 0 {

            fetchDiscoverFormula(with: UploadFormulaMode.my , categoty: nil,  failureHandler: {
                reason, errorMessage in

                defaultFailureHandler(reason, errorMessage)

                //                self.isUploadingFormula = false


            }, completion: { formulas in
                printLog("更新数据成功")
            })

        }

        // 上传备份
        if indexPath.row == 1 {
            //            pushCurrentUserUpdateInformation()
        }
    }
}
