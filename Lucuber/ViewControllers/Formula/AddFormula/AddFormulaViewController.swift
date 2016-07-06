//
//  AddNewFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 16/7/3.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class AddFormulaViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
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
//        titleView.textColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0 )
        titleView.sizeToFit()
        navigationItem.titleView = titleView
        
    }


}
