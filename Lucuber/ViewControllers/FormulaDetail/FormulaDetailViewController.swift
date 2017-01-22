//
//  FormulaDetailViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/30.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import RealmSwift
import PKHUD

fileprivate let detailCellIdentifier = "DetailCollectionViewCell"
fileprivate let masterCellIdentifier = "DetailMasterCell"
fileprivate let formulasCellIdentifier = "DetailFormulasCell"
fileprivate let separatorCellIdentifier = "DetailSeparatorCell"
fileprivate let detailCommentCellIdentifier = "DetailCommentCell"
fileprivate let detailContentCellIdentifier = "DetailContentCell"

class FormulaDetailViewController: UIViewController, SegueHandlerType {
    
    @IBOutlet weak var tableView: UITableView!
    
    enum SegueIdentifier: String {
        case comment = "showCommentVC"
        case edit = "showAddFormula"
    }
    
    public var formula: Formula! {
        didSet {
            try? realm.write {
                formula.isNewVersion = false
            }
        }
    }
    
    public var previewFormulaStyle: PreviewFormulaStyle = .many
    
    fileprivate var realm = try! Realm()
    
    public var uploadMode: UploadFormulaMode = .library
    
    fileprivate lazy var headerView: DetailHeaderView = DetailHeaderView()
    
    fileprivate lazy var commentCellIndexPath: IndexPath = IndexPath(item: 0, section: Section.comment.rawValue)
    
    fileprivate var lastSeletedFormulaContentCellHeight: CGFloat = 0
    
    private lazy var customNavigationItem: UINavigationItem = {
        
        let item = UINavigationItem(title: "Detail")
        item.titleView = self.titleView
        
        item.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain, target: self, action: #selector(FormulaDetailViewController.popViewController))
        
        item.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_settings"), style: .plain, target: self, action: #selector(FormulaDetailViewController.editFormula))
        
        return item
    }()
    
    fileprivate lazy var titleView: DetailTitleView = {
        
        let titleView = DetailTitleView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 44)))
        
        titleView.nameLabel.text = "测试"
        titleView.stateInfoLabel.text = "当前21个公式"
            
        return titleView
    }()
    
    fileprivate lazy var customNavigationBar: UINavigationBar = {
        let bar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64))
        bar.tintColor = UIColor.black
        bar.tintAdjustmentMode = .normal
        bar.alpha = 0
        bar.setItems([self.customNavigationItem], animated: false)
        bar.backgroundColor = UIColor.clear
        bar.isTranslucent = true
        bar.shadowImage = UIImage()
        bar.barStyle = UIBarStyle.blackTranslucent
        bar.setBackgroundImage(UIImage(named:"navigationbar_backgroud"), for: UIBarMetrics.default)
    
        
        let textAttributes = [NSForegroundColorAttributeName: UIColor.black,
                              NSFontAttributeName: UIFont.navigationBarTitle()]
        bar.titleTextAttributes = textAttributes
        return bar
    }()
    
    private lazy var editFormulaSheetView: ActionSheetView = {
        var items = self.creatActionSheetViewItems()
        items.append(ActionSheetView.Item.Cancel)
        let sheetView = ActionSheetView(items: items)
        return sheetView
    }()
    
    private let titles = ["编辑此公式", "删除此公式", "取消"]
    private func creatActionSheetViewItems() -> [ActionSheetView.Item] {
        
        let editItem = ActionSheetView.Item.Option(
            
            title: "编辑此公式",
            titleColor: UIColor.cubeTintColor(),
            
            action: { [weak self] in
                guard let strongSelf = self else { return }
                
                let sb = UIStoryboard(name: "NewFormula", bundle: nil)
                let navigationVC = sb.instantiateInitialViewController() as! MainNavigationController
                let viewController = navigationVC.viewControllers.first as! NewFormulaViewController
                
                guard let realm = try? Realm() else {
                    return
                }
                
                viewController.realm = realm
                viewController.editType = .editFormula
                viewController.view.alpha = 1
                viewController.formula = strongSelf.formula
                
                
                viewController.updateCurrentSelectedFormulaUI = {
                    [weak self] in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    strongSelf.headerView.reloadDataAfterDelete()
                }
                
                viewController.updateSeletedCategory = { [weak self] _ in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    try? realm.write {
                        
                        createOrUpdateRCategory(with: strongSelf.formula, uploadMode: UploadFormulaMode.my, inRealm: realm)
                    }
                    
                }
//                viewController.savedNewFormulaDraft = {
//                    // 暂时不处理草稿, 直接将取消的 Formula 删除
//                    try? realm.write {
//                        strongSelf.formula.cascadeDelete(inRealm: realm)
//                    }
//                }
                
                strongSelf.present(navigationVC, animated: true, completion: nil)
                
            })
        
        let deleteItem = ActionSheetView.Item.Option(
            title: "删除此公式",
            titleColor: UIColor.red,
            action: { [weak self] in
                guard let strongSelf = self else { return }
                
                CubeAlert.confirmOrCancel(
                    title: "删除",
                    message: "删除之后将不能恢复,确定要删除吗?",
                    confirmTitle: "删除",
                    cancelTitles: "取消",
                    inViewController: strongSelf,
                    confirmAction: { [weak self] in
                        
                        // TODO: - 删除公式
                        guard let strongSelf = self else {
                            return
                        }
                        
                        // 删除公式时, 将其标记为已被删除, 同时将 content 也标记为已删除. 
                        // 等进入后台时, 将删除信息推送到服务器
                        
                        try? strongSelf.realm.write {
                            strongSelf.formula.deletedByCreator = true
                            strongSelf.formula.contents.forEach {
                                $0.deleteByCreator = true
                            }
                        }
                        
                        deleteEmptyRCategory(with: UploadFormulaMode.my, inRealm: strongSelf.realm)
                        
                        strongSelf.headerView.reloadDataAfterDelete()
                    },
                    cancelAction: {
                        strongSelf.dismiss(animated: true, completion: nil)
                })
                
            })
        
        let copyToMy = ActionSheetView.Item.Option(
            
            title: "编辑并复制到我的公式",
            titleColor: UIColor.cubeTintColor(),
            
            action: { [weak self] in
                guard let strongSelf = self else { return }
                
                let sb = UIStoryboard(name: "NewFormula", bundle: nil)
                let navigationVC = sb.instantiateInitialViewController() as! MainNavigationController
                let viewController = navigationVC.viewControllers.first as! NewFormulaViewController
                
                guard let realm = try? Realm() else {
                    return
                }
                
                viewController.editType = .addToMy
                viewController.view.alpha = 1
                
                viewController.realm = realm
                
                realm.beginWrite()
                let newFormula = Formula()
                
                if let currentUser = currentUser(in: realm) {
                    
                    newFormula.localObjectID = Formula.randomLocalObjectID()
                    newFormula.lcObjectID = ""
                    
                    for content in strongSelf.formula.contents {
                        
                        let newContent = Content()
                        newContent.localObjectID = Content.randomLocalObjectID()
                        newContent.lcObjectID = ""
                        newContent.atFomurlaLocalObjectID = newFormula.localObjectID
                        newContent.rotation = content.rotation
                        newContent.text = content.text
                        newContent.creator = currentUser
                        newContent.atFormula = newFormula
                        newContent.deleteByCreator = false
                        newContent.indicatorImageName = content.indicatorImageName
                        newContent.isPushed = false
                        
                        realm.add(newContent)
                        
                    }
                    
                    newFormula.name = strongSelf.formula.name
                    newFormula.imageName = strongSelf.formula.imageName
                    newFormula.imageURL = strongSelf.formula.imageURL
                    newFormula.favorate = false
                    newFormula.categoryString = strongSelf.formula.categoryString
                    newFormula.typeString = strongSelf.formula.typeString
                    newFormula.deletedByCreator = false
                    newFormula.rating = strongSelf.formula.rating
                    newFormula.isNewVersion = true
                    newFormula.creator = currentUser
                    newFormula.isLibrary = false
                    newFormula.isPushed = false
                    
                    realm.add(newFormula)
                    
                }
                try? realm.commitWrite()
                
                
                viewController.formula = newFormula
                
                viewController.updateSeletedCategory = { _ in
                 
                    try? realm.write {
                        
                        createOrUpdateRCategory(with: newFormula, uploadMode: UploadFormulaMode.my, inRealm: realm)
                    }
                    
                }
                
                viewController.savedNewFormulaDraft = {
                    // 暂时不处理草稿, 直接将取消的 Formula 删除
                    try? realm.write {
                        newFormula.cascadeDelete(inRealm: realm)
                    }
                }
                
                strongSelf.present(navigationVC, animated: true, completion: nil)
                
                
        })
        
        switch uploadMode {
            
        case .my:
            return [editItem, deleteItem]
            
        case .library:
            return [copyToMy]
        }
        
    }
    
    // MARK: - Life Cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        configureHeaderView()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(FormulaDetailViewController.configureHeaderView), name: Config.NotificationName.updateMyFormulas, object: nil)
        
        tableView.register(UINib(nibName: masterCellIdentifier, bundle: nil), forCellReuseIdentifier: masterCellIdentifier)
        tableView.register(UINib(nibName: formulasCellIdentifier,bundle: nil), forCellReuseIdentifier: formulasCellIdentifier)
        tableView.register(UINib(nibName: separatorCellIdentifier,bundle: nil), forCellReuseIdentifier: separatorCellIdentifier)
        tableView.register(UINib(nibName: detailCommentCellIdentifier,bundle: nil), forCellReuseIdentifier: detailCommentCellIdentifier)
        tableView.register(UINib(nibName: detailContentCellIdentifier,bundle: nil), forCellReuseIdentifier: detailContentCellIdentifier)
        
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.tableHeaderView = headerView
        self.automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(customNavigationBar)
        view.backgroundColor = UIColor.white
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        
        self.titleView.nameLabel.text = formula.name
        self.titleView.stateInfoLabel.text = formula.type.sectionText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        customNavigationBar.alpha = 1
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: headerView.headerHeight )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 保证滑动返回取消后 navigationbar 的正确
        navigationController?.setNavigationBarHidden(true, animated: true)
        customNavigationBar.alpha = 1
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    deinit {
        printLog("\(self) 正确释放了")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Action & Target
    @objc fileprivate func configureHeaderView() {
        
        headerView.configView(with: formula, withUploadMode: self.uploadMode, withPreviewStyle: self.previewFormulaStyle)
        
        headerView.updateNavigationBar = { [weak self] formula in
            guard let strongSelf = self else {
                return
            }
            strongSelf.titleView.nameLabel.text = formula.name
            strongSelf.titleView.stateInfoLabel.text = formula.type.sectionText
        }
        
        headerView.updateCurrentShowFormula  = { [weak self] formula in
            guard let strongSelf = self else {
                return
            }
            strongSelf.formula = formula
            
            // 重新计算 contentCell 高度
            let indexPath = IndexPath(row: 0, section: Section.formulas.rawValue)
            
            strongSelf.tableView.beginUpdates()
            strongSelf.tableView.reloadSections(IndexSet(indexPath), with: .none)
            strongSelf.tableView.reloadSections(IndexSet(strongSelf.commentCellIndexPath), with: .none)
            strongSelf.tableView.endUpdates()
        }
        
        headerView.afterDeleteFormulaDataIsEmpty = { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.popViewController()
        }
    }
    
    
    func popViewController() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func editFormula() {
        if let window = view.window {
            editFormulaSheetView.showInView(view: window)
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifier(for: segue) {
            
        case .comment: break
            
        case .edit:
            
            let editVC = segue.destination as! NewFormulaViewController
            editVC.view.alpha = 1
            editVC.editType = NewFormulaViewController.EditType.editFormula
            
            if let formula = sender as? Formula {
                editVC.formula = formula
            }
        }
    }
}


extension FormulaDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int {
        case separator = 0
        case formulas = 1
        case separatorTwo = 2
        case master = 3
        case comment = 4
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .separator:
            return 1
        case .formulas:
            return 1
        case .separatorTwo:
            return 1
        case .master:
           return previewFormulaStyle == .single ? 0 : 1
        case .comment:
//            return formula.isBelongToFeed ? 1 : 0
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {

        case .separator:
            return Config.FormulaDetail.separatorRowHeight
        case .formulas:
            let newHeight = formula.maxContentCellHeight + Config.FormulaDetail.totalContentLayoutMargin
            if newHeight > lastSeletedFormulaContentCellHeight {
                lastSeletedFormulaContentCellHeight = newHeight
            }
            return lastSeletedFormulaContentCellHeight
        case .separatorTwo:
            return 40
        case .master :
            return Config.FormulaDetail.masterRowHeight
        case .comment:
            return Config.FormulaDetail.commentRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case  .separator, .separatorTwo:
            let cell = tableView.dequeueReusableCell(withIdentifier: separatorCellIdentifier, for: indexPath)
            return cell
            
        case .formulas:
            let cell = tableView.dequeueReusableCell(withIdentifier: detailContentCellIdentifier, for: indexPath) as! DetailContentCell
            cell.configCell(with: formula)
            return cell
            
        case .master:
            let cell = tableView.dequeueReusableCell(withIdentifier: masterCellIdentifier, for: indexPath) as! DetailMasterCell
            
            cell.configCell(with: formula, withRealm: realm)
            return cell
            
        case .comment:
            let cell = tableView.dequeueReusableCell(withIdentifier: detailCommentCellIdentifier, for: indexPath)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .formulas:
            guard let cell = cell as? DetailContentCell else {
               return
            }
            
            headerView.updateFormulaContentCell = { formula in
                cell.configCell(with: formula)
            }
            
        case .master:
            
            guard let cell = cell as? DetailMasterCell else {
               return
            }
            
            headerView.updateMasterCell = { [weak self] formula in
                
                guard let strongSelf = self else {
                    return
                }
                
                cell.configCell(with: formula, withRealm: strongSelf.realm)
            }
        default: break
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .master:
            
            guard let cell = tableView.cellForRow(at: indexPath) as? DetailMasterCell else {
                return
            }
            
            cell.changeMasterStatus(with: self.formula)
            
        case .comment:
            
            self.cube_performSegue(with: .comment, sender: formula)
            
            break
        default:
            return
        }
        
    }
}
















