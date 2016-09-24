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
    }
    
    var editType: EditType = .newFormula
    
    var savedNewFormula: (() -> Void)?
    
   
    var formula = Formula() {
        didSet {
            headerView.formula = formula
        }
    }
    
    private let headerViewHeight: CGFloat = 170
    private var keyboardFrame = CGRect.zero
    private var categoryPickViewIsShow = false
    private var typePickViewIsShow = false
    
    private var activeFormulaTextCellIndexPath = IndexPath(item: 0, section: 2)
    private var categoryPickViewIndexPath = IndexPath(row: 1, section: 1)
    private var typePickViewIndexPath = IndexPath(row: 2, section: 1)
    private var addFormulaTextIndexPath = IndexPath(row: 0, section: 3)
    
    private let sectionHeaderTitles = ["名称", "详细", "复原公式", ""]
    
    private lazy var formulaInputAccessoryView: InputAccessoryView = InputAccessoryView()
    
//    private lazy var formulaInputViewController: FormulaInputViewController = {
//        
//        let viewController = FormulaInputViewController { [unowned self]  button in
//            
//            if let cell = self.tableView.cellForRowAtIndexPath(self.activeFormulaTextCellIndexPath) as? FormulaTextViewCell {
//                cell.textView.insertKeyButtonTitle(button)
//            }
//            
//        }
//        return viewController
//    }()
//
//    
//    private var newFormulaTextIsActive = true {
//        
//        didSet {
//            if let newCell = tableView.cellForRowAtIndexPath(addFormulaTextIndexPath) as? AddFormulaTextCell {
//                Addcell.changeIndicaterLabelStatus(addFormulaTextIsActive)
//            }
//        }
//    }
//    
    
    
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
