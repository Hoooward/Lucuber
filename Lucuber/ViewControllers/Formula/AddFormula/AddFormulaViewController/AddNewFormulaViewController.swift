//
//  AddNewFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit


class AddNewFormulaViewController: UIViewController {
    private let NameTextViewCellIdentifier = "NameTextViewCell"
    private let CategorySeletedCellIdentifier = "CategorySeletedCell"
    private let CategotryPickViewCellIdentifier = "CategoryPickViewCell"
    private let StarRatingCellIdentifier = "StarRatingCell"
    private let FormulaTextViewCellIdentifier = "FormulaTextViewCell"
    private let AddFormulaTextCellIdentifier = "AddFormulaTextCell"

    private let headerViewHeight: CGFloat = 170
    @IBOutlet var headerView: HeaderFormulaView!
    @IBOutlet var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    private let sectionHeaderTitles = ["名称", "类型", "公式", ""]
    
    private var keyboardFrame = CGRectZero
    private var categoryPickViewIsShow = false
    private var addFormulaTextIsActive = true {
        didSet {
            let Addcell = tableView.cellForRowAtIndexPath(addFormulaTextIndexPath) as! AddFormulaTextCell
            Addcell.changeIndicaterLabelStatus(addFormulaTextIsActive)
        }
    }
    
    var newFormula = Formula(name: "公式名称", formula: [], imageName: "placeholder", level: 3, favorate: false, modifyDate: "", category: .x3x3, type: .F2L)
    
    var categoryPickViewIndexPath = NSIndexPath(forRow: 1, inSection: 1)
    var addFormulaTextIndexPath = NSIndexPath(forRow: 0, inSection: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO: 
        //测试设置headerView的Image
        headerView.formulaImageName = "cube_Placehold_image_1"

        makeUI()
        setupNavigationbar()
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddNewFormulaViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddNewFormulaViewController.addFormulaDetailDidChanged(_:)), name: CategotyPickViewDidSeletedRowNotification, object: nil)
    }
    
    func keyboardDidShow(notification: NSNotification) {
//        print(notification)
        if let rect = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {
            keyboardFrame = rect
            
        }
        
    }
    
    
    func addFormulaDetailDidChanged(notification: NSNotification) {
        guard let dict = notification.userInfo as? [String: AnyObject] else {
            return
        }
        if  let item = dict[AddFormulaNotification.CategoryChanged.rawValue] as? CategoryItem {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! CategorySeletedCell
            cell.categoryLabel.text = item.englishText
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
        tableView.registerNib(UINib(nibName: StarRatingCellIdentifier, bundle: nil), forCellReuseIdentifier: StarRatingCellIdentifier)
        tableView.registerNib(UINib(nibName: AddFormulaTextCellIdentifier, bundle: nil), forCellReuseIdentifier: AddFormulaTextCellIdentifier)
        
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
    
    /// Section Name
    enum Section: Int {
        case Name = 0
        case Category
        case Formulas
        case AddFormula
    }
    
    ///类型Section 第一行、第二行、第三行
    enum DetailRow: Int {
        case CategoryDetailRow = 0
        case CategoryPickViewRow = 1
        case StarRatingRow = 2
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        switch section {
        case .Name:
            return 1
        case .Category:
            return categoryPickViewIsShow ? 3 : 2
        case .Formulas:
            return 1
        case .AddFormula:
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
            guard let row = DetailRow(rawValue: indexPath.row) else {
                fatalError()
            }
            switch row {
                
            case .CategoryDetailRow:
                cell = tableView.dequeueReusableCellWithIdentifier(CategorySeletedCellIdentifier, forIndexPath: indexPath) as! CategorySeletedCell
                
            case .CategoryPickViewRow:
                
                if categoryPickViewIsShow {
                    cell = tableView.dequeueReusableCellWithIdentifier(CategotryPickViewCellIdentifier, forIndexPath: indexPath) as! CategoryPickViewCell
                } else {
                    cell = tableView.dequeueReusableCellWithIdentifier(StarRatingCellIdentifier, forIndexPath: indexPath) as! StarRatingCell
                }
                
            case .StarRatingRow:
                    cell = tableView.dequeueReusableCellWithIdentifier(StarRatingCellIdentifier, forIndexPath: indexPath) as! StarRatingCell
            }
            
        case .Formulas:
            
            cell = tableView.dequeueReusableCellWithIdentifier(FormulaTextViewCellIdentifier, forIndexPath: indexPath) as! FormulaTextViewCell
            formulaInputViewController.view.frame.size = keyboardFrame.size
            (cell as! FormulaTextViewCell).textView.inputView = formulaInputViewController.view
            
        case .AddFormula:
           cell = tableView.dequeueReusableCellWithIdentifier(AddFormulaTextCellIdentifier, forIndexPath: indexPath)
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
        
        view.endEditing(true)
        switch section {
        case .Name:
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! NameTextViewCell
            cell.textField.userInteractionEnabled = true
            cell.textField.becomeFirstResponder()
            
        case .Category:
            
            guard let row = DetailRow(rawValue: indexPath.row) else {
                fatalError()
            }
            switch row {
            case .CategoryDetailRow:
                categoryPickViewIsShow ? dismissCategoryPickViewCell() : showCategoryPickViewCell()
            default:
                break
            }
            
        case .Formulas:
            dismissCategoryPickViewCell()
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! FormulaTextViewCell
            cell.textView.becomeFirstResponder()
            addFormulaTextIsActive = false
        case .AddFormula:
            return
        }
        
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        switch section {
        case .Category:
            guard let row = DetailRow(rawValue: indexPath.row) else {
                fatalError()
            }
            switch row {
            case .CategoryPickViewRow:
                return categoryPickViewIsShow ? 130 : 40
            default:
                break
            }
        default:
            return 40
        }
        return 40
    }
    

    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        switch section {
        case .AddFormula:
            return 100
        default:
            return 30
        }
        
    }
    
    
    
    private func showCategoryPickViewCell() {
        if !categoryPickViewIsShow {
            tableView.beginUpdates()
            categoryPickViewIsShow = true
            tableView.insertRowsAtIndexPaths([categoryPickViewIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
    }
    
    private func dismissCategoryPickViewCell() {
        if categoryPickViewIsShow {
            tableView.beginUpdates()
            categoryPickViewIsShow = false
            tableView.deleteRowsAtIndexPaths([categoryPickViewIndexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
    }
 
    
}

// MARK: - UIScrollerDelegate
extension AddNewFormulaViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        addFormulaTextIsActive = true
        dismissCategoryPickViewCell()
        view.endEditing(true)
    }
    
    //设置Header的方法缩小
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 { return }
        let offsetY = abs(scrollView.contentOffset.y) - tableView.contentInset.top
        if offsetY > 0 {
            headerViewHeightConstraint.constant = headerViewHeight + offsetY
            headerView.layoutIfNeeded()
        }
        
    }
}
