//
//  NewFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit


class NewFormulaViewController: UIViewController {
    
    let formulaInputAccessoryView = FormulaInputAccessoryView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
    
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
    
    var afterSaveNewFormula:(() -> Void)?
    

   
    private let headerViewHeight: CGFloat = 170
    private var keyboardFrame = CGRectZero
    private var categoryPickViewIsShow = false
    private var typePickViewIsShow = false
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
    
    var formula = Formula() {
        
        didSet {
            
            headerView.formula = formula
        }
    }
    
    
    var categoryPickViewIndexPath = NSIndexPath(forRow: 1, inSection: 1)
    var typePickViewIndexPath = NSIndexPath(forRow: 2, inSection: 1)
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
      
        
        makeUI()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFormulaViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewFormulaViewController.addFormulaDetailDidChanged(_:)), name: CategotyPickViewDidSeletedRowNotification, object: nil)
    }
    
    deinit {
        printLog("NewFormula死了")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
// MARK: - Observer&Target Funcation
    
    var isSaveing: Bool = false
    
    func save(sender: UIBarButtonItem) {
        
        if isSaveing { return }
        
        
        if self.formula.isReadyforPushToLeanCloud() {
            
            isSaveing = true
            
            let completion: (() -> Void) = {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.isSaveing = false
                    self.afterSaveNewFormula?()
                    
                }
                
            }
            
            let failureHandler: (NSError) -> Void = { error in
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.isSaveing = false
                    CubeAlert.alertSorry(message: error.domain, inViewController: self)
                }
                
            }
            
            
            saveNewFormulaToRealmAndPushToLeanCloud(self.formula, completion: completion, failureHandler: failureHandler)
          
           
            
        } else {
            
        }
        
        
        
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
    private let TypePickViewCellIdentifier = "TypePickViewCell"
    private let TypeSelectedCellIdentifier = "TypeSelectedCell"
    
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
        
        self.navigationItem.rightBarButtonItem?.enabled = self.formula.isReadyforPushToLeanCloud()
        
        tableView.contentInset = UIEdgeInsets(top: 64 + headerViewHeightConstraint.constant, left: 0, bottom: screenHeight - headerViewHeight - 64 - 44 - 25, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 64 + headerViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        tableView.setContentOffset(CGPoint(x: 0, y: -(64 + headerViewHeightConstraint.constant)), animated: false)
        
        tableView.registerNib(UINib(nibName: NameTextViewCellIdentifier, bundle: nil), forCellReuseIdentifier: NameTextViewCellIdentifier)
        tableView.registerNib(UINib(nibName: CategorySeletedCellIdentifier, bundle: nil), forCellReuseIdentifier: CategorySeletedCellIdentifier)
        tableView.registerNib(UINib(nibName: CategotryPickViewCellIdentifier, bundle: nil), forCellReuseIdentifier: CategotryPickViewCellIdentifier)
        tableView.registerNib(UINib(nibName: TypeSelectedCellIdentifier, bundle: nil), forCellReuseIdentifier: TypeSelectedCellIdentifier)
        tableView.registerNib(UINib(nibName: TypePickViewCellIdentifier, bundle: nil), forCellReuseIdentifier: TypePickViewCellIdentifier)
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
        case TypeDetailRow = 2
        case TypePickViewRow = 3
        case StarRatingRow = 4
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
            
            return categoryPickViewIsShow || typePickViewIsShow ? 4 : 3
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
      
        switch section {
            
        case .Name:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(NameTextViewCellIdentifier, forIndexPath: indexPath) as! NameTextViewCell
            
            /// update formula's name
            cell.nameDidChanged = { [weak self] newText in
                self?.formula.name = newText
                self?.navigationItem.rightBarButtonItem?.enabled = self?.formula.isReadyforPushToLeanCloud() ?? false
            }
          
            return cell
            
        case .Category:
            
            
            // row 0 caategory
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCellWithIdentifier(CategorySeletedCellIdentifier, forIndexPath: indexPath) as! CategorySeletedCell
                
                cell.primaryCategory = formula.category
                
                return cell

            }
            
            // row 1 categoryPickViewCell || TypeSeletedCell
            if indexPath.row == 1 {
                
                if categoryPickViewIsShow {
                    let cell = tableView.dequeueReusableCellWithIdentifier(CategotryPickViewCellIdentifier, forIndexPath: indexPath) as! CategoryPickViewCell
                    
                    
                    cell.primaryCategory = formula.category
                    
                    // update formula's category
                    cell.categoryDidChanged = { [weak self] categoryString in
                        
                        let newCategory = Category(rawValue: categoryString.chineseText)!
                        
                        self?.formula.category = newCategory
                        
                        let cell = self?.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as! CategorySeletedCell
                        cell.categoryLabel.text = categoryString.englishText
                        
                        
                    }
                    
                    return cell
 
                } else {
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier(TypeSelectedCellIdentifier, forIndexPath: indexPath) as! TypeSelectedCell
                    cell.primaryType = formula.type
                    return cell
                }
            }
            
            // row 2 TypePickViewCell || TypeSeletedCell || StarRatingCell
            if indexPath.row == 2 {
                
                if typePickViewIsShow {
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier(TypePickViewCellIdentifier, forIndexPath: indexPath) as! TypePickViewCell
                    
                    cell.primaryType = formula.type
                    
                    
                    /// update formula's type
                    cell.typeDidChanged = { [weak self] type in
                        
                        self?.formula.type = type
                        if let cell = self?.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 1)) as?  TypeSelectedCell {
                            cell.primaryType = type
                        }
                        
                    }
                    
                    return cell
                    
                }
                
                if categoryPickViewIsShow {
                    
                    let cell = tableView.dequeueReusableCellWithIdentifier(TypeSelectedCellIdentifier, forIndexPath: indexPath) as! TypeSelectedCell
                    cell.primaryType = formula.type
                    
                    return cell
                }
                
                
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(StarRatingCellIdentifier, forIndexPath: indexPath) as! StarRatingCell
            
            /// update formula's rating
            cell.ratingDidChanged = { [weak self] ratring in
                self?.formula.rating = ratring
            }
            
            return cell
            
        case .Formulas:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(FormulaTextViewCellIdentifier, forIndexPath: indexPath) as! FormulaTextViewCell
            formulaInputViewController.view.frame.size = keyboardFrame.size
            cell.formulaContent = formula.contents[indexPath.row]
            
            cell.textView.inputView = formulaInputViewController.view
            cell.textView.inputAccessoryView = formulaInputAccessoryView
            
            
            cell.updateInputAccessoryView = { [weak self] content in
                self?.formulaInputAccessoryView.seletedContent = content
                
            }
            
            cell.saveFormulaContent = { [weak self] content in
                
                guard let strongSelf = self else {
                    return
                }
                
                let index = indexPath.row
                var catchContents = strongSelf.formula.contents
                
                catchContents.removeAtIndex(index)
                catchContents.insert(content, atIndex: index)
                
                strongSelf.formula.contents = catchContents
                
                
                strongSelf.navigationItem.rightBarButtonItem?.enabled = strongSelf.formula.isReadyforPushToLeanCloud()
                
            }
            
            
            cell.didEndEditing = { [weak self] in
                
//                let cell = tableView.cellForRowAtIndexPath(indexPath) as! FormulaTextViewCell
                self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                
            }
            
            return cell
            
        case .AddFormula:
            
           let cell = tableView.dequeueReusableCellWithIdentifier(AddFormulaTextCellIdentifier, forIndexPath: indexPath)
            
            return cell
        }
        
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
            

            if indexPath.row == 0 {
               categoryPickViewIsShow ? dismissCategoryPickViewCell() : showCategoryPickViewCell()
            }
            
            if indexPath.row == 1  &&  !categoryPickViewIsShow {
                
                typePickViewIsShow ? dismissTypePickViewCell() : showTypePickViewCell()
            }
            
            if indexPath.row == 2  {
               
                if !categoryPickViewIsShow && !typePickViewIsShow {
                  
                } else {
                    
                    if categoryPickViewIsShow {
                        dismissCategoryPickViewCell()
                    }
                    
                    typePickViewIsShow ? dismissTypePickViewCell() : showTypePickViewCell()
                }
                
            }

            
        case .Formulas:
            
            dismissCategoryPickViewCell()
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! FormulaTextViewCell
            
            cell.formulaContent = formula.contents[indexPath.row]
            activeFormulaTextCellIndexPath = indexPath
            cell.textView.becomeFirstResponder()
            addFormulaTextIsActive = false
            
            /// update formula's content
            formulaInputAccessoryView.contentDidChanged = { [weak self] content in
                
                guard let strongSelf = self else {
                    return
                }
                // get cell frome tableView
                let cell = strongSelf.tableView.cellForRowAtIndexPath(indexPath) as! FormulaTextViewCell
                cell.rotationButton.upDateButtonStyleWithRotation(RotationButton.Style.Square, rotation: content.rotation, animation: true)
                
                // Because the formula's content is a 计算 property, so I must found some way
                let index = indexPath.row
                var catchContents = strongSelf.formula.contents
                
                catchContents.removeAtIndex(index)
                catchContents.insert(content, atIndex: index)

                strongSelf.formula.contents = catchContents
                
                // update cell placeholder.
                cell.formulaContent = strongSelf.formula.contents[indexPath.row]
                
            }
            
        case .AddFormula:
    
            addFormulaTextCellAtLast()
            return
        }
        
        
        if indexPath.row == 2 && typePickViewIsShow {
            
            let indexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            
        } else {
            
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }
        

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        switch section {
        case .Category:

            
            if indexPath.row == 1 {
                return categoryPickViewIsShow ? 130 : 40
            }
            
            if indexPath.row == 2 {
                return typePickViewIsShow ? 130 : 40
            }
            

            
        case .Formulas:
             return  formula.contents[indexPath.row].cellHeight
          
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
    
    private func showTypePickViewCell() {
        if !typePickViewIsShow {
            tableView.beginUpdates()
            typePickViewIsShow = true
            tableView.insertRowsAtIndexPaths([typePickViewIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
    }
    
    private func dismissTypePickViewCell() {
        if typePickViewIsShow {
            tableView.beginUpdates()
            typePickViewIsShow = false
            tableView.deleteRowsAtIndexPaths([typePickViewIndexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
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
extension NewFormulaViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        addFormulaTextIsActive = true
        dismissCategoryPickViewCell()
        dismissTypePickViewCell()
        view.endEditing(true)
//        printLog(formula)
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
