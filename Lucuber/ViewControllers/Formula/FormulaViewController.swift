//
//  FormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/17.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift

class FormulaViewController: UIViewController, SegueHandlerType {
    
    // MARK: - Properties
    
    @IBOutlet weak var newFormulaButton: UIButton!
    var topControlSeletedButton: UIButton?
    var containerScrollerOffsetX: CGFloat = 0
    @IBOutlet weak var newFormulaButtonTrailing: NSLayoutConstraint!
    
    private lazy var containerScrollerView: UIScrollView  = {
        let scrollerView = UIScrollView(frame: UIScreen.main.bounds)
        scrollerView.delegate = self
        scrollerView.isPagingEnabled = true
        return scrollerView
    }()
    
    private lazy var layoutBarButtonItem: UIBarButtonItem = {
        
        let button = LayoutButton()
        button.addTarget(self, action: #selector(FormulaViewController.layoutButtonClicked(button:)), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
        
    }()
    
    private lazy var categoryBarButtonItem: CategoryButton = {
    
        let buttonItem = CategoryButton(title: "", style: .plain, target: self, action: #selector(FormulaViewController.categoryButtonClicked(buttonItem:)))
        buttonItem.seletedCategory = .x3x3
        return buttonItem
        
    }()
    
    fileprivate lazy var topControl: TopControl = {
        
        let view = TopControl(childViewControllers: self.childViewControllers)
        view.frame = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: Config.TopControl.height)
        view.backgroundColor = UIColor.clear
        return view
        
    }()
    
    // MARK: - Life Cycle
   
    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        
        title = "复原大法"
        navigationItem.leftBarButtonItem = layoutBarButtonItem
        navigationItem.rightBarButtonItem = categoryBarButtonItem
        
        addChileViewControllers()
        makeUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        hidesBottomBarWhenPushed = false
        
    }
    
    private func addChileViewControllers() {
        
        
        let myFormulaLayout = BaseFormulaLayout()
        let myFormula = MyFormulaViewController(collectionViewLayout: myFormulaLayout)
        myFormula.title = "我的公式"
        
        let libraryFormulaLayout = BaseFormulaLayout()
        let LibraryFormula = LibraryFormulaViewController(collectionViewLayout: libraryFormulaLayout)
        LibraryFormula.title = "公式库"
        
        addChildViewController(myFormula)
        addChildViewController(LibraryFormula)
    }
    
    
    private func makeUI() {
        
        view.addSubview(topControl)
        
        topControl.buttonClickedUpdateIndicaterPoztion = { [unowned self] buttonTag in
            
            let index = buttonTag - Config.TopControl.buttonTagBaseValue
            let offsetX =  CGFloat(index) * UIScreen.main.bounds.width
            self.containerScrollerView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)

        }
        
        let defaultConstat = self.newFormulaButtonTrailing.constant
        topControl.updateNewFormulaButtonPoztion = { [unowned self] in
            
            // NewFormulaButton tranfrom X
            let maxDistance: CGFloat = 80
            let maxOffsetX = UIScreen.main.bounds.width
            let scale =  maxOffsetX / maxDistance
            
            self.newFormulaButtonTrailing.constant = defaultConstat - (self.containerScrollerView.contentOffset.x / scale)
            self.newFormulaButton.layoutIfNeeded()
            
            self.newFormulaButton.alpha = 1 - (self.containerScrollerView.contentOffset.x / 100)
            
        }
        
        view.insertSubview(containerScrollerView, at: 0)
        containerScrollerView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(childViewControllers.count), height: 0)
        
        scrollViewDidEndScrollingAnimation(containerScrollerView)
        
    }
    
    
    // MARK: - Action & Target
    
    @IBAction func newFormulaButtonClicked(_ sender: AnyObject) {
        
        performSegue(identifier: .showNewFormula, sender: nil)
    }
    
    
    @objc private func layoutButtonClicked(button: UIView) {
        
        if let button = button as? LayoutButton {
            
            button.isSelected = !button.isSelected
            
            if let vc = childViewControllers[Int(containerScrollerOffsetX / UIScreen.main.bounds.width)] as? BaseCollectionViewController {
                vc.userMode = vc.userMode == .card ? .normal : .card
            }
            
        }
        
    }
    
    private lazy var menuAnimator: CategoryMenuAnimator = CategoryMenuAnimator()
    
    @objc private func categoryButtonClicked(buttonItem: UIBarButtonItem) {
        
        guard let button = buttonItem as? CategoryButton else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Formula", bundle: nil)
        
        if
            let menuVC = storyboard.instantiateViewController(withIdentifier: "CategoryMenuController") as? CategoryMenuController,
            let presentingVC = childViewControllers[Int(containerScrollerOffsetX / UIScreen.main.bounds.width)] as? BaseCollectionViewController {
            
            guard let realm = try? Realm() else {
                return
            }
            
            let category = presentingVC.seletedCategory
            let RCategorys = categorysWith(presentingVC.uploadMode, inRealm: realm)
            
            var categorys: [Category] = RCategorys.map({ Category(rawValue:$0.name)! })
            
            categorys.append(Category.all)
            
            let menuHeight = Config.CategoryMenu.rowHeight * CGFloat(categorys.count) + 20 + 10
            
            menuAnimator.presentedFrame = CGRect(x: Config.CategoryMenu.menuOrignX, y: 60, width: Config.CategoryMenu.menuWidth, height: menuHeight)
            
            menuVC.transitioningDelegate = self.menuAnimator
            menuVC.modalPresentationStyle = UIModalPresentationStyle.custom
            
            
            menuVC.seletedCateogry = category
            menuVC.categorys = categorys
            
            menuVC.categoryDidChanged = {
                category in
                
                printLog("已选择的\(category)")
                presentingVC.seletedCategory = category
                
                presentingVC.collectionView?.reloadData()
                
                UserDefaults.setSelected(category: category, mode: presentingVC.uploadMode)
                
                button.seletedCategory = category
            }
            
            present(menuVC, animated: true, completion: nil)
            
        }
    }
    
    // MARK: - Segue
    
    enum SegueIdentifier: String {
        case showFormulaDetail = "ShowFormulaDetail"
        case showNewFormula = "ShowNewFormula"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifier(for: segue) {
            
        // TODO: - 重要
        case .showFormulaDetail:
            
            let vc = segue.destination as! FormulaDetailViewController
            
            if let formula = sender as? Formula {
                
                vc.formula = formula
                
                let index = Int(containerScrollerView.contentOffset.x / UIScreen.main.bounds.width)
                
                vc.uploadMode = index == 0 ? .my : .library
                
            }
            break
            
        case .showNewFormula:
            
            let nvc = segue.destination as! UINavigationController
            let vc = nvc.viewControllers[0] as! NewFormulaViewController
            
            vc.editType = .newFormula
            vc.view.alpha = 1
            
            if let presentingVC = childViewControllers[Int(containerScrollerOffsetX / UIScreen.main.bounds.width)] as? BaseCollectionViewController {
                
                guard let realm = try? Realm() else {
                    return
                }
                
                var formula: Formula!
                
                try? realm.write {
                    
                    formula = Formula.new(false, inRealm: realm)
                    formula.categoryString = presentingVC.seletedCategory.rawValue
                    
                    if Category.all == presentingVC.seletedCategory {
                        formula.categoryString = Category.x3x3.rawValue
                    }
                    
                }
                
                vc.formula = formula
                vc.realm = realm
                
                
                vc.updateSeletedCategory = { [weak self] seletedCategory in
                    
                        guard
                            let strongSelf = self,
                            let seletedCategory = seletedCategory,
                            let button = strongSelf.navigationItem.rightBarButtonItem as? CategoryButton else {
                           return
                        }
                        
                        UserDefaults.setSelected(category: seletedCategory, mode: presentingVC.uploadMode)
                        
                        button.seletedCategory = seletedCategory
                        presentingVC.seletedCategory = seletedCategory
                }
                
             
                
                vc.savedNewFormulaDraft = {
                    // 暂时不处理草稿, 直接将取消的 Formula 删除
                    try? realm.write {
                        formula.isPushed = false
                        formula.cascadeDelete(inRealm: realm)
                    }
                    
                }
                
                
            }
        }
        
    }
    
    fileprivate func updateNavigationBarButtonItemStatus() {
        
        guard
            let layoutButton = navigationItem.leftBarButtonItem?.customView as? LayoutButton,
            let categoryButton = navigationItem.rightBarButtonItem as? CategoryButton else {
                
            return
        }
        
        if let vc = childViewControllers[Int(containerScrollerOffsetX / UIScreen.main.bounds.width)] as? BaseCollectionViewController {
            
            layoutButton.userMode = vc.userMode
            categoryButton.seletedCategory = vc.seletedCategory
        }
        
        childViewControllers.forEach {
            vc in
            if let vc = vc as? BaseCollectionViewController {
                
                vc.cancelSearch()
            }
        }
        
    }
    
}

extension FormulaViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        containerScrollerOffsetX = scrollView.contentOffset.x
        
        let index = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
        let vc = childViewControllers[index] as! BaseCollectionViewController
        
        vc.view.frame = CGRect(x: CGFloat(index) * UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        
        let topEdge = 64 + Config.TopControl.height + 44
        let bottomEdge: CGFloat = 49
        
        
        vc.collectionView?.contentInset = UIEdgeInsets(top: topEdge, left: 0, bottom: bottomEdge, right: 0)
        vc.collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: topEdge - 44, left: 0, bottom: bottomEdge, right: 0)
        

        scrollView.addSubview(vc.view)
        
        
        if index > 0 {
            
            NotificationCenter.default.post(name: Notification.Name.needReloadFormulaFromRealmNotification, object: nil)
        }
        
        updateNavigationBarButtonItemStatus()
        
        newFormulaButton.isEnabled = true
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        topControl.updateIndicaterPozition(scrollerViewOffsetX: scrollView.contentOffset.x)
        
        
        newFormulaButton.isEnabled = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollViewDidEndScrollingAnimation(scrollView)
        
        topControl.updateButtonStatus(scrollerViewOffsetX: scrollView.contentOffset.x)
        
    }
    
}












