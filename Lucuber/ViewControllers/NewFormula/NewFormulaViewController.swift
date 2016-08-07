//
//  NewFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class InputAccessoryView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("InputAccessoryView 正常死亡")
    }
    
    func makeUI() {
        
        addSubview(switchButton)
    }
    
    lazy var switchButton: UISwitch = {
        let button = UISwitch(frame: CGRectZero)
        return button
    }()
}


class NewFormulaViewController: UIViewController {
    
    let testInputAccessoryView = FormulaInputAccessoryView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
    

    enum EditType {
        /// 新公式
        case NewFormula
        /// 新话题的公式附件
        case NewAttchment
        /// 编辑公式
        case EditFormula
    }

// MARK: - Properties
    
    var editType: EditType = .NewFormula
   
    private let headerViewHeight: CGFloat = 170
    private var keyboardFrame = CGRectZero
    private var categoryPickViewIsShow = false
    private var activeFormulaTextCellIndexPath = NSIndexPath(forItem: 0, inSection: 2)
    
    private var addFormulaTextIsActive = true {
        
        didSet {
            if let Addcell = tableView.cellForRowAtIndexPath(addFormulaTextIndexPath) as? AddFormulaTextCell {
                Addcell.changeIndicaterLabelStatus(addFormulaTextIsActive)
            }
        }
    }
   
    @IBOutlet weak var headerView: HeaderFormulaView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    private let sectionHeaderTitles = ["名称", "详细", "复原公式", ""]
    
    var formula = Formula.creatNewDefaultFormula()
    
    
    var categoryPickViewIndexPath = NSIndexPath(forRow: 1, inSection: 1)
    var addFormulaTextIndexPath = NSIndexPath(forRow: 0, inSection: 3)
    
    private lazy var formulaInputViewController: FormulaInputViewController = {
        
        let viewController = FormulaInputViewController { [unowned self]  button in
            
            if let cell = self.tableView.cellForRowAtIndexPath(self.activeFormulaTextCellIndexPath) as? FormulaTextViewCell {
                cell.textView.insertKeyButtonTitle(button)
            }
            
        }
        return viewController
    }()


   
// MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
      
        //TODO:
        var testContents = [FormulaContent]()
        for index in 0...3 {
            let content = FormulaContent()
            content.rotation = defaultRotations[index]
            testContents.append(content)
        }
        
        formula.contents = testContents
        headerView.formula = formula

        makeUI()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFormulaViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFormulaViewController.addFormulaDetailDidChanged(_:)), name: CategotyPickViewDidSeletedRowNotification, object: nil)
    }
    
    deinit {
        print("NewFormula死了")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
// MARK: - Observer&Target Funcation
    
    func save(sender: UIBarButtonItem) {
        
        //保存公式. 
        //条件判断. 什么情况下可以保存
        
        //1 保存到本地
        
        //2 保存到服务器
        
    }
    
    func next(sender: UIBarButtonItem) {
        
        
        view.endEditing(true)
        if isReadyForSave {
            
            let vc = UIStoryboard(name: "AddFeed", bundle: nil).instantiateViewControllerWithIdentifier("NewFeedViewController") as! NewFeedViewController
            vc.attachment = NewFeedViewController.Attachment.Formula
            vc.attachmentFormula = formula
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            
            CubeAlert.alertSorry(message: "请正确填写公式信息", inViewController: self)
            
        }
        
    }
    
    private var isReadyForSave: Bool {
       
        let isReady = true
      
        // TODO: - 判断是否信息被正确填写
        
        return isReady
    }
    
    func keyboardDidShow(notification: NSNotification) {
        
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
//            cell.categoryLabel.text = item.englishText
        }
        
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

// MARK: - MakeUI
    
    private let NameTextViewCellIdentifier = "NameTextViewCell"
    private let CategorySeletedCellIdentifier = "CategorySeletedCell"
    private let CategotryPickViewCellIdentifier = "CategoryPickViewCell"
    private let StarRatingCellIdentifier = "StarRatingCell"
    private let FormulaTextViewCellIdentifier = "FormulaTextViewCell"
    private let AddFormulaTextCellIdentifier = "AddFormulaTextCell"
    
    private func makeUI() {
        
        switch editType {
            
        case .NewFormula:
            
            navigationItem.title = "新公式"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: #selector(NewFormulaViewController.save(_:)))
            
        case .NewAttchment:
            
            navigationItem.title = "创建公式(1/2)"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "下一步", style: .Plain, target: self, action: #selector(NewFormulaViewController.next(_:)))
            
        case .EditFormula:
            
            navigationItem.title = "编辑公式"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: #selector(NewFormulaViewController.save(_:)))
            
        }
        
        tableView.contentInset = UIEdgeInsets(top: 64 + headerViewHeightConstraint.constant, left: 0, bottom: screenHeight - headerViewHeight - 64 - 44 - 25, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 64 + headerViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        tableView.setContentOffset(CGPoint(x: 0, y: -(64 + headerViewHeightConstraint.constant)), animated: false)
        
        tableView.registerNib(UINib(nibName: NameTextViewCellIdentifier, bundle: nil), forCellReuseIdentifier: NameTextViewCellIdentifier)
        tableView.registerNib(UINib(nibName: CategorySeletedCellIdentifier, bundle: nil), forCellReuseIdentifier: CategorySeletedCellIdentifier)
        tableView.registerNib(UINib(nibName: CategotryPickViewCellIdentifier, bundle: nil), forCellReuseIdentifier: CategotryPickViewCellIdentifier)
        tableView.registerNib(UINib(nibName: FormulaTextViewCellIdentifier, bundle: nil), forCellReuseIdentifier: FormulaTextViewCellIdentifier)
        tableView.registerNib(UINib(nibName: StarRatingCellIdentifier, bundle: nil), forCellReuseIdentifier: StarRatingCellIdentifier)
        tableView.registerNib(UINib(nibName: AddFormulaTextCellIdentifier, bundle: nil), forCellReuseIdentifier: AddFormulaTextCellIdentifier)
        
        
        addChildViewController(formulaInputViewController)
        //TODO: 键盘布局有问题
        childViewControllers.first!.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 226)
        
    }

   
}

// MARK: - UITableViewDelegate&dataSource
extension NewFormulaViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            return formula.contents.count
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
            let cell = tableView.dequeueReusableCellWithIdentifier(NameTextViewCellIdentifier, forIndexPath: indexPath) as! NameTextViewCell
            
            
            /// 修改公式名字
            cell.nameDidChanged = { [weak self] newText in
                self?.formula.name = newText
            }
          
            return cell
        case .Category:
            
            guard let row = DetailRow(rawValue: indexPath.row) else {
                fatalError()
            }
            
            switch row {
                
            case .CategoryDetailRow:
                let cell = tableView.dequeueReusableCellWithIdentifier(CategorySeletedCellIdentifier, forIndexPath: indexPath) as! CategorySeletedCell
                
                
                
                return cell
                
            case .CategoryPickViewRow:
                
                if categoryPickViewIsShow {
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier(CategotryPickViewCellIdentifier, forIndexPath: indexPath) as! CategoryPickViewCell
                   
                    
                    cell.categoryDidChanged = { [weak self] category in
                        
                        self?.formula.category = Category(rawValue: category.chineseText)!
                        
                        let cell = self?.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! CategorySeletedCell
                        cell.categoryLabel.text = category.englishText
                    }
                    
                    return cell
                    
                } else {
                    
                    let  cell = tableView.dequeueReusableCellWithIdentifier(StarRatingCellIdentifier, forIndexPath: indexPath) as! StarRatingCell
                    
                    cell.ratingDidChanged = { [weak self] ratring in
                        self?.formula.rating = ratring
                    }
                    
                    return cell
                }
                
            case .StarRatingRow:
                
                    let cell = tableView.dequeueReusableCellWithIdentifier(StarRatingCellIdentifier, forIndexPath: indexPath) as! StarRatingCell
                
                    cell.ratingDidChanged = { [weak self] ratring in
                        self?.formula.rating = ratring
                    }
                    return cell
            }
            
        case .Formulas:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(FormulaTextViewCellIdentifier, forIndexPath: indexPath) as! FormulaTextViewCell
            formulaInputViewController.view.frame.size = keyboardFrame.size
            cell.formulaContent = formula.contents[indexPath.row]
            cell.textView.inputView = formulaInputViewController.view
            cell.textView.inputAccessoryView = testInputAccessoryView
            
            return cell
            
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
            
            cell.formulaContent = formula.contents[indexPath.row]
            activeFormulaTextCellIndexPath = indexPath
            cell.textView.becomeFirstResponder()
            addFormulaTextIsActive = false
            
        case .AddFormula:
    
            addFormulaTextCellAtLast()
            
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
            
        case .Formulas:
            return 50
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
            return 80
        default:
            return 30
        }
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .Formulas:
            if editingStyle == .Delete {
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                formula.contents.removeAtIndex(indexPath.row)
                tableView.endUpdates()
            }
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        switch section {
        case .Formulas:
            return formula.contents.count > 1 ? .Delete : .None
        default:
            return .None
        }
    }
    
    
    
    private func  addFormulaTextCellAtLast() {
        tableView.beginUpdates()
        let newIndex = NSIndexPath(forRow: formula.contents.count, inSection: Section.Formulas.rawValue)
        tableView.insertRowsAtIndexPaths([newIndex], withRowAnimation: .Fade)
        formula.contents.append(FormulaContent())
        tableView.endUpdates()
        
       
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
extension NewFormulaViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        addFormulaTextIsActive = true
        dismissCategoryPickViewCell()
        view.endEditing(true)
        print(formula)
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
