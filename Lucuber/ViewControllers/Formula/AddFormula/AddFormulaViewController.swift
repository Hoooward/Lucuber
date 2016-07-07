//
//  AddNewFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 16/7/3.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit
private let HeaderCellIdentifier = "HeaderTableViewCell"
private let ChannelCellIdentifier = "ChannelTableViewCell"
private let CategoryCellIdentifier = "CategoryPickViewCell"

class AddFormulaViewController: UITableViewController {

    private var categoryPickViewDismiss = true
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationbar()
    }

    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func setupNavigationbar() {
        let titleView = UILabel()
        titleView.text = "创建新公式"
        titleView.sizeToFit()
        navigationItem.titleView = titleView
    }
    
}

extension AddFormulaViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            if categoryPickViewDismiss {
                return 1
            } else {
                return 2
            }
        }
        return 1
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(HeaderCellIdentifier, forIndexPath: indexPath)
            return cell
            
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(ChannelCellIdentifier, forIndexPath: indexPath)
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier(CategoryCellIdentifier, forIndexPath: indexPath)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "基本信息"
        }
        return "类型"
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 130
        }
        return 44
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            categoryPickViewDismiss = !categoryPickViewDismiss
            tableView.reloadData()
        }
    }
}
