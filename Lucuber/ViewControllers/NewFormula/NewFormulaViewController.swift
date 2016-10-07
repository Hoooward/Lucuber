//
//  NewFormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class NewFormulaViewController: UIViewController {
    
    // MARK: - Properties
        
    @IBOutlet weak var headerView: NewFormulaHeadView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    enum EditType {
        case newFormula
        case newAttchment
        case editFormula
        case addToMy
    }
    
    var editType: EditType = .newFormula
    
    var savedNewFormula: (() -> Void)?
    
   
    var formula = Formula() {
        didSet {
            headerView.formula = formula
        }
    }
    
    fileprivate let headerViewHeight: CGFloat = 170
    fileprivate var keyboardFrame = CGRect.zero
    fileprivate var categoryPickViewIsShow = false
    fileprivate var typePickViewIsShow = false
    
    fileprivate var activeFormulaTextCellIndexPath = IndexPath(item: 0, section: 2)
    fileprivate var categoryPickViewIndexPath = IndexPath(row: 1, section: 1)
    fileprivate var typePickViewIndexPath = IndexPath(row: 2, section: 1)
    fileprivate var newFormulaTextIndexPath = IndexPath(row: 0, section: 3)
    
    fileprivate let sectionHeaderTitles = ["名称", "详细", "复原公式", ""]
    
    fileprivate lazy var formulaInputAccessoryView: InputAccessoryView = InputAccessoryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))

    
    fileprivate lazy var formulaInputViewController: FormulaInputViewController = {
        
        let viewController = FormulaInputViewController { [unowned self]  button in
            
            if let cell = self.tableView.cellForRow(at: self.activeFormulaTextCellIndexPath) as? FormulaTextViewCell {
                cell.textView.insertKeyButtonTitle(keyButtn: button)
            }
            
        }
        return viewController
    }()
    
    fileprivate var newFormulaTextIsActive = true {
        
        didSet {
            if let cell = tableView.cellForRow(at: newFormulaTextIndexPath) as? NewFormulaTextCell {
                cell.changeIndicaterLabelStatus(active: newFormulaTextIsActive)
            }
        }
    }
    
   
    
    // MARK: - Life Cycle
    
    fileprivate let nameTextViewCellIdentifier = "NameTextViewCell"
    fileprivate let categorySeletedCellIdentifier = "CategorySeletedCell"
    fileprivate let categoryPickViewCellIdentifier = "CategoryPickViewCell"
    fileprivate let starRatingCellIdentifier = "StarRatingCell"
    fileprivate let formulaTextViewCellIdentifier = "FormulaTextViewCell"
    fileprivate let newFormulaTextCellIdentifier = "NewFormulaTextCell"
    fileprivate let typePickViewCellIdentifier = "TypePickViewCell"
    fileprivate let typeSelectedCellIdentifier = "TypeSelectedCell"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        switch editType {
            
        case .newFormula:
            
            navigationItem.title = "新公式"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(NewFormulaViewController.save(_:)))
            
        case .newAttchment:
            
            navigationItem.title = "创建公式(1/2)"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "下一步", style: .plain, target: self, action: #selector(NewFormulaViewController.next(_:)))
            
        case .editFormula:
            
            navigationItem.title = "编辑公式"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(NewFormulaViewController.save(_:)))
            
        case .addToMy:
            
            navigationItem.title = "添加至我的公式"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加", style: .plain, target: self, action: #selector(NewFormulaViewController.save(_:)))
            
        }
 
        
        self.navigationItem.rightBarButtonItem?.isEnabled = self.formula.isReadyforPushToLeanCloud()
        
        tableView.contentInset = UIEdgeInsets(top: 64 + headerViewHeightConstraint.constant, left: 0, bottom: UIScreen.main.bounds.height - headerViewHeight - 64 - 44 - 25, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 64 + headerViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        tableView.setContentOffset(CGPoint(x: 0, y: -(64 + headerViewHeightConstraint.constant)), animated: false)
        
        tableView.register(UINib(nibName: nameTextViewCellIdentifier, bundle: nil), forCellReuseIdentifier: nameTextViewCellIdentifier)
        tableView.register(UINib(nibName: categorySeletedCellIdentifier, bundle: nil), forCellReuseIdentifier: categorySeletedCellIdentifier)
        tableView.register(UINib(nibName: categoryPickViewCellIdentifier, bundle: nil), forCellReuseIdentifier: categoryPickViewCellIdentifier)
        tableView.register(UINib(nibName: typeSelectedCellIdentifier, bundle: nil), forCellReuseIdentifier: typeSelectedCellIdentifier)
        tableView.register(UINib(nibName: typePickViewCellIdentifier, bundle: nil), forCellReuseIdentifier: typePickViewCellIdentifier)
        tableView.register(UINib(nibName: formulaTextViewCellIdentifier, bundle: nil), forCellReuseIdentifier: formulaTextViewCellIdentifier)
        tableView.register(UINib(nibName: starRatingCellIdentifier, bundle: nil), forCellReuseIdentifier: starRatingCellIdentifier)
        tableView.register(UINib(nibName: newFormulaTextCellIdentifier, bundle: nil), forCellReuseIdentifier: newFormulaTextCellIdentifier)
        
        addChildViewController(formulaInputViewController)

        //TODO: 键盘布局有问题
        childViewControllers.first!.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width
            
            , height: 226)
        NotificationCenter.default.addObserver(self, selector: #selector(NewFormulaViewController.keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.rightBarButtonItem?.isEnabled = self.formula.isReadyforPushToLeanCloud()
    }
    

    deinit {
        printLog("NewFormula死了")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Action & Target
    
    @IBAction func dismiss(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    private var isSaveing: Bool = false
    func save(_ sender: UIBarButtonItem) {
        
        if isSaveing { return }
        
        
        if self.formula.isReadyforPushToLeanCloud() {
            
            isSaveing = true
            
            let completion: (() -> Void) = {
                
                DispatchQueue.main.async {
                    
                    self.dismiss(animated: true, completion: nil)
                    self.isSaveing = false
                    self.savedNewFormula?()
                }
                
            }
            
            let failureHandler: (NSError) -> Void = { error in
                
                DispatchQueue.main.async {
                    self.isSaveing = false
                    CubeAlert.alertSorry(message: error.domain, inViewController: self)
                }
                
            }
            
            saveNewFormulaToRealmAndPushToLeanCloud(newFormula: self.formula, completion: completion, failureHandler: failureHandler)
            
            
        } else {
            
        }
        
    }
    
    private var isReadyForSave: Bool {
        
        let isReady = true
        // TODO: - 判断是否信息被正确填写
        return isReady
    }
    
    func next(_ sender: UIBarButtonItem) {
        
        view.endEditing(true)
        
//        if isReadyForSave {
        
//            let vc = UIStoryboard(name: "AddFeed", bundle: nil).instantiateViewControllerWithIdentifier("NewFeedViewController") as! NewFeedViewController
//            vc.attachment = NewFeedViewController.Attachment.Formula
//            vc.attachmentFormula = formula
//            self.navigationController?.pushViewController(vc, animated: true)
//            
//        } else {
//            
//            CubeAlert.alertSorry(message: "请正确填写公式信息", inViewController: self)
//            
//        }
        
    // TODO: 分别处理多个Edit的方法。
        
    }
    
    func keyboardDidShow(notification: NSNotification) {
        
        if let rect = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
           keyboardFrame = rect.cgRectValue
        }
        
    }

    
    fileprivate func addFormulaTextCellAtLast() {
        tableView.beginUpdates()
        let newIndex = IndexPath(row: formula.contents.count, section: Section.formulas.rawValue)
        tableView.insertRows(at: [newIndex], with: .fade)
        formula.contents.append(FormulaContent())
        tableView.endUpdates()
    }
    
    fileprivate func showTypePickViewCell() {
        if !typePickViewIsShow {
            tableView.beginUpdates()
            typePickViewIsShow = true
            tableView.insertRows(at: [typePickViewIndexPath], with: UITableViewRowAnimation.fade)
            tableView.endUpdates()
        }
    }
    
    fileprivate func dismissTypePickViewCell() {
        if typePickViewIsShow {
            tableView.beginUpdates()
            typePickViewIsShow = false
            tableView.deleteRows(at: [typePickViewIndexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
    fileprivate func showCategoryPickViewCell() {
        if !categoryPickViewIsShow {
            tableView.beginUpdates()
            categoryPickViewIsShow = true
            tableView.insertRows(at: [categoryPickViewIndexPath], with: UITableViewRowAnimation.fade)
            tableView.endUpdates()
        }
    }
    
    fileprivate func dismissCategoryPickViewCell() {
        if categoryPickViewIsShow {
            tableView.beginUpdates()
            categoryPickViewIsShow = false
            tableView.deleteRows(at: [categoryPickViewIndexPath], with: .fade)
            tableView.endUpdates()
        }
    }
    
}


// MARK: - UITableViewDelegate&dataSource
extension NewFormulaViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// Section Name
    enum Section: Int {
        case name = 0
        case category
        case formulas
        case addFormula
    }
    
    ///类型Section 第一行、第二行、第三行
    enum DetailRow: Int {
        case categoryDetailRow = 0
        case categoryPickViewRow = 1
        case typeDetailRow = 2
        case typePickViewRow = 3
        case starRatingRow = 4
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .name:
            return 1
        case .category:
            return categoryPickViewIsShow || typePickViewIsShow ? 4 : 3
        case .formulas:
            return formula.contents.count
        case .addFormula:
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
      
        switch section {
            
        case .name:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: nameTextViewCellIdentifier, for: indexPath) as! NameTextViewCell
            
            if !formula.name.isEmpty {
                
                cell.textField.text = formula.name
                cell.textField.placeholdTextLabel.isHidden = true
            }
            /// update formula's name
            cell.nameDidChanged = { [weak self] newText in
                
                self?.formula.name = newText
                self?.navigationItem.rightBarButtonItem?.isEnabled = self?.formula.isReadyforPushToLeanCloud() ?? false
                
                /// update headerView
                self?.headerView.formula = self?.formula
            }
          
            return cell
            
        case .category:
            
            // row 0 caategory
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: categorySeletedCellIdentifier, for: indexPath) as! CategorySeletedCell
                
//                printLog(formula.categoryString)
                cell.primaryCategory = formula.category
                
                return cell

            }
            
            // row 1 categoryPickViewCell || TypeSeletedCell
            if indexPath.row == 1 {
                
                if categoryPickViewIsShow {
                    let cell = tableView.dequeueReusableCell(withIdentifier: categoryPickViewCellIdentifier, for: indexPath) as! CategoryPickViewCell
                    
                    
                    cell.primaryCategory = formula.category
                    
                    // update formula's category
                    cell.categoryDidChanged = { [weak self] categoryString in
                        
                        let newCategory = Category(rawValue: categoryString.chineseText)!
                        
                        self?.formula.category = newCategory
                        
                        let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! CategorySeletedCell
                        cell.categoryLabel.text = categoryString.englishText
                        
                        /// update the headerView
                        self?.headerView.formula = self?.formula
                        
                    }
                    
                    return cell
 
                } else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: typeSelectedCellIdentifier, for: indexPath) as! TypeSelectedCell
                    cell.primaryType = formula.type
                    return cell
                }
            }
            
            // row 2 TypePickViewCell || TypeSeletedCell || StarRatingCell
            if indexPath.row == 2 {
                
                if typePickViewIsShow {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: typePickViewCellIdentifier, for: indexPath) as! TypePickViewCell
                    
                    cell.primaryType = formula.type
                    
                    
                    /// update formula's type
                    cell.typeDidChanged = { [weak self] type in
                        
                        self?.formula.type = type
                        if let cell = self?.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as?  TypeSelectedCell {
                            cell.primaryType = type
                        }
                        
                    }
                    
                    return cell
                    
                }
                
                if categoryPickViewIsShow {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: typeSelectedCellIdentifier, for: indexPath) as! TypeSelectedCell
                    cell.primaryType = formula.type
                    
                    return cell
                }
            
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: starRatingCellIdentifier, for: indexPath) as! StarRatingCell
            
            /// update formula's rating
            cell.ratingDidChanged = { [weak self] ratring in
                self?.formula.rating = ratring
            }
            
            return cell
            
        case .formulas:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: formulaTextViewCellIdentifier, for: indexPath) as! FormulaTextViewCell
            formulaInputViewController.view.frame.size = keyboardFrame.size
            cell.formulaContent = formula.contents[indexPath.row]
            
            cell.textView.inputView = formulaInputViewController.view
            cell.textView.inputAccessoryView = formulaInputAccessoryView
            
            
            cell.updateInputAccessoryView = { [weak self] content in
                self?.formulaInputAccessoryView.selectedContent = content
            }
            
            cell.saveFormulaContent = { [weak self] content in
                
                guard let strongSelf = self else {
                    return
                }
                
                let index = indexPath.row
                var catchContents = strongSelf.formula.contents
                
                catchContents.remove(at: index)
                catchContents.insert(content, at: index)
                
                strongSelf.formula.contents = catchContents
                
                strongSelf.navigationItem.rightBarButtonItem?.isEnabled = strongSelf.formula.isReadyforPushToLeanCloud()
                
            }
            
            
            cell.didEndEditing = { [weak self] in
                
//                let cell = tableView.cellForRowAtIndexPath(indexPath) as! FormulaTextViewCell
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                
            }
            
            return cell
            
        case .addFormula:
            
           let cell = tableView.dequeueReusableCell(withIdentifier: newFormulaTextCellIdentifier, for: indexPath)
           
            return cell
        }
        
    }
 

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = NewSectionHeaderView.creatHeaderView()
        headerView.titleLabel.text = sectionHeaderTitles[section]
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        view.endEditing(true)
        
        switch section {
            
        case .name:
            
            let cell = tableView.cellForRow(at: indexPath) as! NameTextViewCell
            cell.textField.isUserInteractionEnabled = true
            
             _ = cell.textField.becomeFirstResponder()
            
        case .category:
            

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

            
        case .formulas:
            
            dismissCategoryPickViewCell()
            let cell = tableView.cellForRow(at: indexPath) as! FormulaTextViewCell
            
            cell.formulaContent = formula.contents[indexPath.row]
            activeFormulaTextCellIndexPath = indexPath
            let _ = cell.textView.becomeFirstResponder()
            newFormulaTextIsActive = false
            
            /// update formula's content
            formulaInputAccessoryView.contentDidChanged = { [weak self] content in
                
                guard let strongSelf = self else {
                    return
                }
                // get cell frome tableView
                let cell = strongSelf.tableView.cellForRow(at: indexPath) as! FormulaTextViewCell
                cell.rotationButton.updateButtonStyle(with: RotationButton.Style.square, rotation: content.rotation, animation: true)
                
                // Because the formula's content is a 计算 property, so I must found some way
                let index = indexPath.row
                var catchContents = strongSelf.formula.contents
                
                catchContents.remove(at: index)
                catchContents.insert(content, at: index)

                strongSelf.formula.contents = catchContents
                
                // update cell placeholder.
                cell.formulaContent = strongSelf.formula.contents[indexPath.row]
                
            }
            
        case .addFormula:
    
            addFormulaTextCellAtLast()
            return
        }
        
        
        if indexPath.row == 2 && typePickViewIsShow {
            
            let indexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            
        } else {
            
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .category:
            
            if indexPath.row == 1 {
                return categoryPickViewIsShow ? 130 : 40
            }
            
            if indexPath.row == 2 {
                return typePickViewIsShow ? 130 : 40
            }
            
        case .formulas:
             return  formula.contents[indexPath.row].cellHeight
          
        default:
            return 40
        }
        return 40
    }
    

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
            
        case .addFormula:
            return 50
        default:
            return 30
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .formulas:
            if editingStyle == .delete {
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .left)
                formula.contents.remove(at: indexPath.row)
                tableView.endUpdates()
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .formulas:
            return formula.contents.count > 1 ? .delete : .none
        default:
            return .none
        }
    }
    
  
 
    
}

// MARK: - UIScrollerDelegate
extension NewFormulaViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        newFormulaTextIsActive = true
        dismissCategoryPickViewCell()
        dismissTypePickViewCell()
        view.endEditing(true)
//        printLog(formula)
    }
    
    //设置Header的方法缩小
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 { return }
        let offsetY = abs(scrollView.contentOffset.y) - tableView.contentInset.top
        if offsetY > 0 {
            headerViewHeightConstraint.constant = headerViewHeight + offsetY
            headerView.layoutIfNeeded()
        }
        
    }
}





























