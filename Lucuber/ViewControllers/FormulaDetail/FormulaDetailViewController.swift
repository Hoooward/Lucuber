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

fileprivate let detailCellIdentifier = "DetailCollectionViewCell"
fileprivate let masterCellIdentifier = "DetailMasterCell"
fileprivate let formulasCellIdentifier = "DetailFormulasCell"
fileprivate let separatorCellIdentifier = "DetailSeparatorCell"
fileprivate let detailCommentCellIdentifier = "DetailCommentCell"
fileprivate let detailContentCellIdentifier = "DetailContentCell"

class FormulaDetailViewController: UIViewController, SegueHandlerType {
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    enum SegueIdentifier: String {
        case comment = "showCommentVC"
        case edit = "showAddFormula"
    }
    
    public var formula: Formula! {
        didSet {
            
            headerView.configView(with: formula, withUploadMode: self.uploadMode)
            
        }
    }
    
    var oldMasterList: [String] = []
    
    public var uploadMode: UploadFormulaMode = .library
    
    lazy var headerView: DetailHeaderView = {
        let view = DetailHeaderView()
        return view
    }()
    
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
    
    let titles = ["编辑此公式", "删除此公式", "取消"]
    private func creatActionSheetViewItems() -> [ActionSheetView.Item] {
        
        let editItem = ActionSheetView.Item.Option(
            
            title: "编辑此公式",
            titleColor: UIColor.cubeTintColor(),
            
            action: { [weak self] in
                guard let strongSelf = self else { return }
                
                let sb = UIStoryboard(name: "NewFormula", bundle: nil)
                let navigationVC = sb.instantiateInitialViewController() as! MainNavigationController
                let viewController = navigationVC.viewControllers.first as! NewFormulaViewController
                viewController.editType = .editFormula
                viewController.view.alpha = 1
                viewController.formula = strongSelf.formula
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
                    confirmAction: {
                        // TODO: - 删除公式
                    },
                    cancelAction: {
                        strongSelf.dismiss(animated: true, completion: nil)
                })
                
            })
        
        let copyToMy = ActionSheetView.Item.Option(
            
            title: "编辑并添加到公式",
            titleColor: UIColor.cubeTintColor(),
            
            action: { [weak self] in
                guard let strongSelf = self else { return }
                
                let sb = UIStoryboard(name: "NewFormula", bundle: nil)
                let navigationVC = sb.instantiateInitialViewController() as! MainNavigationController
                let viewController = navigationVC.viewControllers.first as! NewFormulaViewController
                viewController.editType = .addToMy
                viewController.view.alpha = 1
                
                viewController.formula = strongSelf.formula
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
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        tableView.register(UINib(nibName: masterCellIdentifier, bundle: nil), forCellReuseIdentifier: masterCellIdentifier)
        tableView.register(UINib(nibName: formulasCellIdentifier,bundle: nil), forCellReuseIdentifier: formulasCellIdentifier)
        tableView.register(UINib(nibName: separatorCellIdentifier,bundle: nil), forCellReuseIdentifier: separatorCellIdentifier)
        tableView.register(UINib(nibName: detailCommentCellIdentifier,bundle: nil), forCellReuseIdentifier: detailCommentCellIdentifier)
        tableView.register(DetailContentCell.self, forCellReuseIdentifier: detailContentCellIdentifier)
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.tableHeaderView = headerView
        self.automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(customNavigationBar)
        view.backgroundColor = UIColor.white
        
        if let currentUser = AVUser.current(), let list = currentUser.masterList()  {
            oldMasterList = list
        }
        
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
        printLog(#function)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: headerView.headerHeight )
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        printLog(#function)
        navigationController?.setNavigationBarHidden(true, animated: true)
        customNavigationBar.alpha = 1
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    deinit {
        printLog("\(self) 死掉喽")
    }
    
    // MARK: - Action & Target
    
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
//            let vc = segue.destination as! CommentViewController
//            
//            if let formula = sender as? Formula, let realm = try? Realm() {
//                
//                vc.formula = formula
//                
//                realm.beginWrite()
//                let formulaConversation = vc.prepareConversation(withFromula: formula, inRealm: realm)
//                try? realm.commitWrite()
//                
//                vc.conversation = formulaConversation
//            
//            }
            
            
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
        case comment = 3
//        case master = 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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
            return 0
        case .comment:
            return 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {

        case .separator:
            return Config.FormulaDetail.separatorRowHeight
        case .separatorTwo:
            return Config.FormulaDetail.separatorRowHeight
        case .formulas:
//            return formula.contentMaxCellHeight
            return 200
        case .comment:
            return Config.FormulaDetail.commentRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .separator, .separatorTwo:
            let cell = tableView.dequeueReusableCell(withIdentifier: separatorCellIdentifier, for: indexPath)
            return cell
            
        case .formulas:
            let cell = tableView.dequeueReusableCell(withIdentifier: detailContentCellIdentifier, for: indexPath) as! DetailContentCell
            cell.configCell(with: formula)
            return cell
            
        case .comment:
            let cell = tableView.dequeueReusableCell(withIdentifier: detailCommentCellIdentifier, for: indexPath)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .comment:
            
            self.performSegue(identifier: .comment, sender: formula)
            
            break
        default:
            return
        }
        
    }
}
















