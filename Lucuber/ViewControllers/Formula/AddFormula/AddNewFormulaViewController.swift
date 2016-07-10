//
//  AddNewFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class AddNewFormulaViewController: UIViewController {

    @IBOutlet var headerView: UIView!
    @IBOutlet var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    let sectionHeaderTitles = ["名称", "学习优先级", "类型", "公式"]
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        setupNavigationbar()
    }
    
    private func makeUI() {
        tableView.contentInset = UIEdgeInsets(top: 64 + headerViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

    private func setupNavigationbar() {
        let titleView = UILabel()
        titleView.text = "创建新公式"
        titleView.sizeToFit()
        navigationItem.titleView = titleView
        addChildViewController(formulaInputViewController)
        childViewControllers.first!.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 226)
    }
    
    private lazy var formulaInputViewController: FormulaInputViewController = {
        let viewController = FormulaInputViewController {
            [unowned self]  button in
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 2)) as! FormulasTextTableViewCell
            cell.textView.insertKeyButtonTitle(button)
        }
        return viewController
    }()

   
}

// MARK: - UITableViewDelegate&dataSource
extension AddNewFormulaViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionHeaderTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = AddSectionHeaderView.creatHeaderView()
        headerView.titleLabel.text = sectionHeaderTitles[section]
        return headerView
    }
}

// MARK: - UIScrollerDelegate
extension AddNewFormulaViewController: UIScrollViewDelegate {
    //设置Header的方法缩小
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 { return }
        let offsetY = abs(scrollView.contentOffset.y) - tableView.contentInset.top
        if offsetY > 0 {
            headerViewHeightConstraint.constant = 170 + offsetY
            headerView.layoutIfNeeded()
        }
        
    }
}
