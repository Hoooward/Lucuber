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
private let FormulasCellIdentifier = "FormulasTextTableViewCell"

class AddFormulaViewController: UITableViewController {

    
    var formula = Formula()
    var formulas: [String] = []
    private var categoryPickViewDismiss = true
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationbar()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddFormulaViewController.pickViewDidSeletedRow(_:)), name: CategotyPickViewDidSeletedRowNotification, object: nil)
    }
    
    func pickViewDidSeletedRow(notification: NSNotification) {
        print(":被选了")
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CategotyPickViewDidSeletedRowNotification, object: nil)
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
    
    enum Section: Int {
        case BaseInformation = 0
        case Category
        case Formulas
        case Footer
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        switch section {
        case .BaseInformation:
            return 1
        case .Category:
            return categoryPickViewDismiss ? 1 : 2
        case .Formulas:
            return 1
        default:
            return 1
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .BaseInformation:
            let cell = tableView.dequeueReusableCellWithIdentifier(HeaderCellIdentifier, forIndexPath: indexPath)
            return cell
        case .Category:
            if indexPath.row == 0 {
                let categoryCell = tableView.dequeueReusableCellWithIdentifier(ChannelCellIdentifier, forIndexPath: indexPath)
                
                return categoryCell
            } else {
                let pickViewCell = tableView.dequeueReusableCellWithIdentifier(CategoryCellIdentifier, forIndexPath: indexPath)
                return pickViewCell
            }
        case .Formulas:
            let cell = tableView.dequeueReusableCellWithIdentifier(<#T##identifier: String##String#>, forIndexPath: <#T##NSIndexPath#>)
        default:
            return UITableViewCell()
        }
        
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        switch section {
        case .BaseInformation:
            return "基本信息"
        case .Category:
            return "类型"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .BaseInformation:
            return 130
        case .Category:
            if indexPath.row == 0 {
                return 44
            } else {
                return 120
            }
        default:
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            categoryPickViewDismiss = !categoryPickViewDismiss
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as?ChannelTableViewCell {
                cell.bringUpPickViewStatus(categoryPickViewDismiss)
            }
            
            tableView.reloadData()
        }
    }
}
