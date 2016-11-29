//
//  NewFormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import AVFoundation
import RealmSwift
import PKHUD

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
            headerView.configView(with: formula)
        }
    }
    
    var realm: Realm = try! Realm()
    
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
    
   
    fileprivate let nameTextViewCellIdentifier = "NameTextViewCell"
    fileprivate let categorySeletedCellIdentifier = "CategorySeletedCell"
    fileprivate let categoryPickViewCellIdentifier = "CategoryPickViewCell"
    fileprivate let starRatingCellIdentifier = "StarRatingCell"
    fileprivate let formulaTextViewCellIdentifier = "FormulaTextViewCell"
    fileprivate let newFormulaTextCellIdentifier = "NewFormulaTextCell"
    fileprivate let typePickViewCellIdentifier = "TypePickViewCell"
    fileprivate let typeSelectedCellIdentifier = "TypeSelectedCell"
    
    // MARK: - Life Cycle
    
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
        
        self.navigationItem.rightBarButtonItem?.isEnabled = self.formula.isReadyToPush()
        
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
        self.navigationItem.rightBarButtonItem?.isEnabled = self.formula.isReadyToPush()
    }
    

    deinit {
        printLog("NewFormula死了")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Action & Target
    
    
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        return imagePicker
    }()
    
    private lazy var actionSheetView: ActionSheetView = {
        
        let actionSheetView = ActionSheetView(items: [
            
            .Option(title: "拍摄", titleColor: UIColor.cubeTintColor(), action: {
                [weak self] in
                
                guard
                    let strongSelf = self,
                    UIImagePickerController.isSourceTypeAvailable(.camera) else {
                        self?.alertCanNotAccessCameraRoll()
                        return
                }
                
                DispatchQueue.main.async {
                    
                    if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.authorized {
                        
                        strongSelf.modalPresentationStyle = .currentContext
                        strongSelf.imagePicker.sourceType = .camera
                        
                        /*
                         bug :  Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.
                         http://cocoadocs.org/docsets/DKCamera/1.2.9/index.html
                         可以选择使用这个开源项目解决问题
                         
                         */
                        delay(0.3) {
                            strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                        }
                        
                    } else {
                        
                        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {
                            success in
                            
                            if success {
                                delay(0.3) {
                                    strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                                }
                            }
                            
                        })
                    }
                }
                
            }),
            
            .Option(title: "相册", titleColor: UIColor.cubeTintColor(), action: {
                [weak self] in
                
                guard
                    let strongSelf = self,
                    UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                        self?.alertCanNotOpenPhotoLibrary()
                        return
                }
                
                //这个方法是在其他线程执行的
                PHPhotoLibrary.requestAuthorization { authorization in
                    if authorization ==  PHAuthorizationStatus.authorized {
                        
                        DispatchQueue.main.async {
                            
                            //strongSelf.performSegue(withIdentifier: "ShowPickPhotoView", sender: nil)
                            
                            strongSelf.modalPresentationStyle = .currentContext
                            strongSelf.imagePicker.sourceType = .photoLibrary
                            
                            delay(0.3) {
                                strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                            }
                        }
                        
                    } else {
                        strongSelf.alertCanNotOpenPhotoLibrary()
                        
                    }
                }
                
            }),
            
            ])
        return actionSheetView
    }()
    
  
    
    @IBAction func pickPhoto(_ sender: Any) {
        
        if let window = view.window {
            actionSheetView.showInView(view: window)
        }
        
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        
        try? realm.write {
            self.formula.cascadeDelete(inRealm: realm)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private var isSaveing: Bool = false
    
    func save(_ sender: UIBarButtonItem) {
        
        if isSaveing { return }
        
        self.formula.cleanBlankContent(inRealm: realm)
        
        if self.formula.isReadyToPush() {
            
            isSaveing = true
            
            HUD.show(HUDContentType.label("公式保存中..."))
            pushToLeancloud(with: formula, inRealm: realm, completion: {
                HUD.flash(.label("保存成功"), delay: 1)
                self.dismiss(animated: true, completion: nil)
                self.isSaveing = false
                 
            }, failureHandler: { error in
                self.isSaveing = false
                HUD.flash(.label("保存失败, 请重试"), delay: 1)
            })
            
            
        }
        
    }
    
    private var isReadyForSave: Bool {
        let isReady = true
        return isReady
    }
    
    func next(_ sender: UIBarButtonItem) {
        
        view.endEditing(true)
        
        if isReadyForSave {
//        
//            let vc = UIStoryboard(name: "NewFeed", bundle: nil).instantiateViewController(withIdentifier: "NewFeedViewController") as! NewFeedViewController
//            vc.attachment = NewFeedViewController.Attachment.formula
//            vc.attachmentFormula = formula
//            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            
            CubeAlert.alertSorry(message: "请正确填写公式信息", inViewController: self)
            
        }
        
    // TODO: 分别处理多个Edit的方法。
        
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let rect = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
           keyboardFrame = rect.cgRectValue
        }
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
            tableView.insertRows(at: [categoryPickViewIndexPath], with: .fade)
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
        case detail
        case content
        case addFormula
    }
    
    ///详情Section 第一行、第二行、第三行
    enum DetailRow: Int {
        case category = 0
        case categoryPickView = 1
        case typeDetail = 2
//        case typePickView = 3
        case starRating = 3
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
        case .detail:
            return categoryPickViewIsShow || typePickViewIsShow ? 4 : 3
        case .content:
            return formula.contents.count
        case .addFormula:
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .name:
            
            guard let cell = cell as? NameTextViewCell else {
               return
            }
            
            if !formula.name.isEmpty {
                cell.textField.text = formula.name
                cell.textField.placeholdTextLabel.isHidden = true
            }
            
            cell.nameDidChanged = { [weak self] name in
                
                guard let strongSelf = self else { return }
                
                try? strongSelf.realm.write {
                    strongSelf.formula.name = name
                }
                strongSelf.navigationItem.rightBarButtonItem?.isEnabled = self?.formula.isReadyToPush() ?? false
                
                strongSelf.headerView.configView(with: strongSelf.formula)
            }
            
            
        case .detail:
            
            guard let row = DetailRow(rawValue: indexPath.row) else {
                return
            }
            
            switch row {
                
            case .category:
                
                guard let cell = cell as? CategorySeletedCell else {
                    return
                }

                cell.configCell(with: self.formula)
                
                
            case .categoryPickView:
                
                if categoryPickViewIsShow {
                    guard let cell = cell as? CategoryPickViewCell else {
                        return
                    }
                    
                    cell.configCell(with: self.formula)
                    
                    cell.categoryDidChanged = { [weak self] categoryItem in
                        
                        guard let strongSelf = self else { return }
                        
                        try? strongSelf.realm.write {
                            strongSelf.formula.categoryString = categoryItem.chineseText
                        }
                        
                        let cell = strongSelf.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! CategorySeletedCell
                        
                        cell.configCell(with: strongSelf.formula)
                        
                        strongSelf.headerView.configView(with: strongSelf.formula)
                        
                    }
                
                } else {
                    
                    guard let cell = cell as? TypeSelectedCell else {
                        return
                    }
                    
                    cell.configCell(with: self.formula)
                    
                }


            case .typeDetail:
                
                if typePickViewIsShow {
                    
                    guard let cell = cell as? TypePickViewCell else {
                        return
                    }
                    
                    cell.configCell(with: self.formula)
                    
                    cell.typeDidChanged = { [weak self] type in
                        
                        guard let strongSelf = self else {
                            return
                        }
                        
                        try? strongSelf.realm.write {
                            strongSelf.formula.typeString = type.rawValue
                        }
                        
                        if let cell = strongSelf.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as?  TypeSelectedCell {
                            
                            cell.configCell(with: strongSelf.formula)
                        }
                        
                        strongSelf.headerView.configView(with: strongSelf.formula)
                    }
                    
                }
                
                if categoryPickViewIsShow {
                    
                    guard let cell = cell as? TypeSelectedCell else {
                        return
                    }
                    
                    cell.configCell(with: self.formula)
                }
                
                
                guard let cell = cell as? StarRatingCell else {
                    return
                }
                
                cell.ratingDidChanged = { [weak self] rating in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    try? strongSelf.realm.write {
                        strongSelf.formula.rating = rating
                    }
                    strongSelf.headerView.configView(with: strongSelf.formula)
                }
                
                
            case .starRating:
                
                guard let cell = cell as? StarRatingCell else {
                    return
                }
                
                
                cell.ratingDidChanged = { [weak self] rating in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    try? strongSelf.realm.write {
                        strongSelf.formula.rating = rating
                    }
                    strongSelf.headerView.configView(with: strongSelf.formula)
                }
         
            }
            
        case .content:
            
            guard let cell = cell as? FormulaTextViewCell else {
                return
            }
            
            formulaInputViewController.view.frame.size = keyboardFrame.size
            
            cell.configCell(with: self.formula, indexPath: indexPath, inRealm: realm)
            
            cell.textView.inputView = formulaInputViewController.view
            cell.textView.inputAccessoryView = formulaInputAccessoryView
            
            cell.updateInputAccessoryView = { [weak self] content in
                
                guard let strongSelf = self else {
                    return
                }
                strongSelf.formulaInputAccessoryView.configView(with: content, inRealm: strongSelf.realm)
            }
            
            cell.didEndEditing = { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.navigationItem.rightBarButtonItem?.isEnabled = strongSelf.formula.isReadyToPush()
                strongSelf.tableView.reloadRows(at: [indexPath], with: .automatic)
                
            }
            
            
        case .addFormula:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
      
        switch section {
            
        case .name:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: nameTextViewCellIdentifier, for: indexPath) as! NameTextViewCell
    
            return cell
            
        case .detail:
            
            guard let row = DetailRow(rawValue: indexPath.row) else {
                fatalError()
            }
            
            switch row {
                
            case .category:
                
                return tableView.dequeueReusableCell(withIdentifier: categorySeletedCellIdentifier, for: indexPath) as! CategorySeletedCell
                
            case .categoryPickView:
                
                if categoryPickViewIsShow {
                    
                    return tableView.dequeueReusableCell(withIdentifier: categoryPickViewCellIdentifier, for: indexPath) as! CategoryPickViewCell
                    
                } else {
                    
                    return tableView.dequeueReusableCell(withIdentifier: typeSelectedCellIdentifier, for: indexPath) as! TypeSelectedCell
                    
                }
                
            case .typeDetail:
                
                if typePickViewIsShow {
                    
                    return tableView.dequeueReusableCell(withIdentifier: typePickViewCellIdentifier, for: indexPath) as! TypePickViewCell
                    
                }
                
                if categoryPickViewIsShow {
                    
                    return tableView.dequeueReusableCell(withIdentifier: typeSelectedCellIdentifier, for: indexPath) as! TypeSelectedCell
                    
                }
                
                return tableView.dequeueReusableCell(withIdentifier: starRatingCellIdentifier, for: indexPath) as! StarRatingCell

            case .starRating:
                
                return tableView.dequeueReusableCell(withIdentifier: starRatingCellIdentifier, for: indexPath) as! StarRatingCell
 
            }
      
        case .content:
            
            return tableView.dequeueReusableCell(withIdentifier: formulaTextViewCellIdentifier, for: indexPath) as! FormulaTextViewCell
            
        case .addFormula:
            
            return tableView.dequeueReusableCell(withIdentifier: newFormulaTextCellIdentifier, for: indexPath)
            
        }
        
        return UITableViewCell()
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
            
        case .detail:
            

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
            
        case .content:
            
            dismissCategoryPickViewCell()
            let cell = tableView.cellForRow(at: indexPath) as! FormulaTextViewCell
            
            cell.configCell(with: self.formula, indexPath: indexPath, inRealm: realm)
            activeFormulaTextCellIndexPath = indexPath
            
            let _ = cell.textView.becomeFirstResponder()
            
            newFormulaTextIsActive = false
            
            formulaInputAccessoryView.contentDidChanged = { [weak self] content in
                guard
                    let strongSelf = self,
                    let rotation = Rotation(rawValue: content.rotation) else {
                    return
                }
                
                let cell = strongSelf.tableView.cellForRow(at: indexPath) as! FormulaTextViewCell
                
                cell.rotationButton.updateButtonStyle(with: RotationButton.Style.square, rotation: rotation, animation: true)
                
            }
            
        case .addFormula:
    
            try? realm.write {
                _ = Content.new(with: self.formula, inRealm: realm)
            }
            printLog(self.formula)
           
            tableView.beginUpdates()
            let newIndex = IndexPath(row: formula.contents.count - 1, section: Section.content.rawValue)
            tableView.insertRows(at: [newIndex], with: .fade)
            tableView.endUpdates()
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
        case .detail:
            
            if indexPath.row == 1 {
                return categoryPickViewIsShow ? 130 : 40
            }
            
            if indexPath.row == 2 {
                return typePickViewIsShow ? 130 : 40
            }
            
        case .content:
             return  CGFloat(formula.contents[indexPath.row].cellHeight)
          
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
            
        case .content:
            
            switch editType {
            case .editFormula:
                
                tableView.beginUpdates()
                try? realm.write {
                    realm.delete(formula.contents[indexPath.row])
                }
                tableView.deleteRows(at: [indexPath], with: .left)
                tableView.endUpdates()
                
            default:
                break
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
            
        case .content:
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

extension NewFormulaViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            switch mediaType {
                
            case String(kUTTypeImage):
                
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    formula.image = image
                }
                
                
                
            default:
                break
            }
            self.headerView.configView(with: self.formula)
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
    }
    
}





























