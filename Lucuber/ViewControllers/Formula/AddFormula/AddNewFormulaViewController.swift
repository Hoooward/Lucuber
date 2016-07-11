//
//  AddNewFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

private let NameTextViewCellIdentifier = "NameTextViewCell"
private let CategorySeletedCellIdentifier = "CategorySeletedCell"
private let CategotryPickViewCellIdentifier = "CategoryPickViewCell"
private let FormulaTextViewCellIdentifier = "FormulaTextViewCell"

class AddNewFormulaViewController: UIViewController {

    private let headerViewHeight: CGFloat = 150
    @IBOutlet var headerView: HeaderFormulaView!
    @IBOutlet var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    private let sectionHeaderTitles = ["名称", "类型", "公式"]
    
    private var keyboardFrame = CGRectZero
    private var categoryPickViewIsShow = false
    
    var newFormula = Formula(name: "公式名称", formula: [], imageName: "placeholder", level: 3, favorate: false, modifyDate: "", category: .x3x3, type: .F2L)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()
        setupNavigationbar()
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddNewFormulaViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func keyboardDidShow(notification: NSNotification) {
//        print(notification)
        if let rect = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {
            keyboardFrame = rect
            
            
        }
        
    }
    
    deinit {
        print("NewFormula死了")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    private func makeUI() {
        tableView.contentInset = UIEdgeInsets(top: 64 + headerViewHeightConstraint.constant, left: 0, bottom: screenHeight - headerViewHeight - 64 - 44 - 25, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 64 + headerViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        
        tableView.registerNib(UINib(nibName: NameTextViewCellIdentifier, bundle: nil), forCellReuseIdentifier: NameTextViewCellIdentifier)
        tableView.registerNib(UINib(nibName: CategorySeletedCellIdentifier, bundle: nil), forCellReuseIdentifier: CategorySeletedCellIdentifier)
        tableView.registerNib(UINib(nibName: CategotryPickViewCellIdentifier, bundle: nil), forCellReuseIdentifier: CategotryPickViewCellIdentifier)
        tableView.registerNib(UINib(nibName: FormulaTextViewCellIdentifier, bundle: nil), forCellReuseIdentifier: FormulaTextViewCellIdentifier)
    }

    private func setupNavigationbar() {
        let titleView = UILabel()
        titleView.text = "创建新公式"
        titleView.sizeToFit()
        navigationItem.titleView = titleView
        addChildViewController(formulaInputViewController)
        //TODO: 键盘布局有问题
        childViewControllers.first!.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 226)
    }
    
    private lazy var formulaInputViewController: FormulaInputViewController = {
        let viewController = FormulaInputViewController {
            [unowned self]  button in
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 2)) as! FormulaTextViewCell
            cell.textView.insertKeyButtonTitle(button)
        }
        return viewController
    }()

   
}

// MARK: - UITableViewDelegate&dataSource
extension AddNewFormulaViewController: UITableViewDataSource, UITableViewDelegate {
    
    enum Section: Int {
        case Name = 0
        case Category
        case Formulas
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionHeaderTitles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        switch section {
        case .Name:
            return 1
        case .Category:
            return categoryPickViewIsShow ? 2 : 1
        case .Formulas:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        var cell = UITableViewCell()
        
        switch section {
        case .Name:
            cell = tableView.dequeueReusableCellWithIdentifier(NameTextViewCellIdentifier, forIndexPath: indexPath) as! NameTextViewCell
        case .Category:
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier(CategorySeletedCellIdentifier, forIndexPath: indexPath) as! CategorySeletedCell
            }
            if indexPath.row == 1 {
                cell = tableView.dequeueReusableCellWithIdentifier(CategotryPickViewCellIdentifier, forIndexPath: indexPath) as! CategoryPickViewCell
            }
        case .Formulas:
            cell = tableView.dequeueReusableCellWithIdentifier(FormulaTextViewCellIdentifier, forIndexPath: indexPath) as! FormulaTextViewCell
            formulaInputViewController.view.frame.size = keyboardFrame.size
            (cell as! FormulaTextViewCell).textView.inputView = formulaInputViewController.view
        }
        return cell
    }
    

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let headerView = AddSectionHeaderView.creatHeaderView()
        headerView.titleLabel.text = sectionHeaderTitles[section]
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        scrollViewWillBeginDragging(tableView)
        switch section {
        case .Name:
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! NameTextViewCell
            cell.textField.userInteractionEnabled = true
            cell.textField.becomeFirstResponder()
            break
        case .Category:
            categoryPickViewIsShow ? dismissCategoryPickViewCell(tableView) : showCategoryPickViewCell(tableView)
            break
        case .Formulas:
            dismissCategoryPickViewCell(tableView)
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! FormulaTextViewCell
            cell.textView.becomeFirstResponder()
            break
        }
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    
       

     
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        switch section {
        case .Name:
            break
        case .Category:
            if indexPath.row == 1 {return 130}
        case .Formulas:
            break
        }
        return 40
    }
    
    private func showCategoryPickViewCell(tableView: UITableView) {
        if !categoryPickViewIsShow {
            tableView.beginUpdates()
            let newIndexPath = NSIndexPath(forRow: 1, inSection: 1)
            categoryPickViewIsShow = true
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
    }
    
    private func dismissCategoryPickViewCell(tableView: UITableView) {
        if categoryPickViewIsShow {
            tableView.beginUpdates()
            let newIndexPath = NSIndexPath(forRow: 1, inSection: 1)
            categoryPickViewIsShow = false
            tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
    }
    
    
    
}

// MARK: - UIScrollerDelegate
extension AddNewFormulaViewController: UIScrollViewDelegate {
    //设置Header的方法缩小
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
   
        if scrollView.contentOffset.y > 0 { return }
        let offsetY = abs(scrollView.contentOffset.y) - tableView.contentInset.top
        if offsetY > 0 {
            headerViewHeightConstraint.constant = headerViewHeight + offsetY
            headerView.layoutIfNeeded()
        }
        
    }
}
