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

    
    @IBOutlet weak var formulaSectionHeaderView: FormulaSectionHeaderView!
    var formula = Formula()
    var formulas: [String] = []
    private var categoryPickViewDismiss = true
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationbar()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddFormulaViewController.pickViewDidSeletedRow(_:)), name: CategotyPickViewDidSeletedRowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddFormulaViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        print(notification)
    }
    
    func pickViewDidSeletedRow(notification: NSNotification) {
        print(":被选了")
        
    }
    
    deinit {
        print("\(self)被释放")
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CategotyPickViewDidSeletedRowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    }

    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func setupNavigationbar() {
        let titleView = UILabel()
        titleView.text = "创建新公式"
        titleView.sizeToFit()
        navigationItem.titleView = titleView
        
        
        addChildViewController(formulaInputViewController)
        formulaInputViewController.keyButtonDidClickedCallBack = {
            button in
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 2)) as! FormulasTextTableViewCell
            cell.textView.insertKeyButtonTitle(button)
//            let currentText = cell.textView.text
//            
//            var newText = button.titleLabel?.text ?? ""
//            switch type {
//            case .Default:
//                newText += " "
//                cell.textView.attributedText = (currentText + newText).setAttributesFitDetailLayout()
//            case .Bracket:
//                if newText == "(" {
//                cell.textView.attributedText = (currentText + newText).setAttributesFitDetailLayout()
//                } else {
//                    newText += " "
//                    cell.textView.attributedText = (currentText.trimming(.Whitespace) + newText).setAttributesFitDetailLayout()
//                    
//                }
//            case .Number:
//                newText += " "
//                cell.textView.attributedText = (currentText.trimming(.Whitespace) + newText).setAttributesFitDetailLayout()
//            default:
//                break
//            }
//            print(cell.textView.text)
        }
        childViewControllers.first!.view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 226)
    }
//    
//    private lazy var formulaTextViewInputViewController: FormulaInputViewController = {
//        [unowned self] in
//        let viewController = FormulaInputViewController { button in
//            let buttonType = button.item!.type
//            switch buttonType {
//                case .
//            }
//
//            
//            if let newText = newText {
//                print(newText)
//                if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)) as? FormulasTextTableViewCell {
//                    let currentText = cell.textView.text
//                    let resultText = currentText + newText
//                    cell.textView.attributedText = resultText.setAttributesFitDetailLayout()
//                    
//                }
//
//            }
//        }
//        return viewController
//    }()
    
    private lazy var formulaInputViewController: FormulaInputViewController = {
        let viewController = FormulaInputViewController { button in
            
        }
        return viewController
    }()
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
            let cell = tableView.dequeueReusableCellWithIdentifier(FormulasCellIdentifier, forIndexPath: indexPath) as! FormulasTextTableViewCell
            cell.textView.inputView = formulaInputViewController.view
            return cell
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
        case .Formulas:
            return "公式"
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
        case .Formulas:
            return 60
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
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        switch section {
        case .Formulas:
            return formulaSectionHeaderView
        default:
            return nil
        }
    }
}
