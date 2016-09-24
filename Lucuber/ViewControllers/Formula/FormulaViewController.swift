//
//  FormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/17.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FormulaViewController: UIViewController, SegueHandlerType {
    
    // MARK: - Properties
    
    @IBOutlet weak var newFormulaButton: UIButton!
    var topControlSeletedButton: UIButton?
    var containerScrollerOffsetX: CGFloat = 0
    
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
        
        view.insertSubview(containerScrollerView, at: 0)
        containerScrollerView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(childViewControllers.count), height: 0)
        
        scrollViewDidEndScrollingAnimation(containerScrollerView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        printLog("\(self) is Dead")
    }
    
    
    // MARK: - Action & Target
    
    
    @IBAction func newFormulaButtonClicked(_ sender: AnyObject) {
//        let storyboard = UIStoryboard(name: "NewFormula", bundle: nil)
//        
//        let navigationController = storyboard.instantiateInitialViewController()
        
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
            
            
            let category = presentingVC.seletedCategory
            
            var categorys = getCategoryMenusAtRealm(mode: presentingVC.uploadMode)
            
            if categorys.isEmpty {
                
                categorys.append(.x3x3)
            }
            
            let menuHeight = Config.CategoryMenu.rowHeight * CGFloat(categorys.count) + 20 + 10
            
            menuAnimator.presentedFrame = CGRect(x: Config.CategoryMenu.menuOrignX, y: 60, width: Config.CategoryMenu.menuWidth, height: menuHeight)
            
            menuVC.transitioningDelegate = self.menuAnimator
            
            menuVC.modalPresentationStyle = UIModalPresentationStyle.custom
            
            
            
            menuVC.seletedCateogry = category
            menuVC.categorys = categorys
            
            menuVC.categoryDidChanged = {
                
                category in
                
                presentingVC.uploadingFormulas(with: presentingVC.uploadMode, category: category) {
                    
                    presentingVC.collectionView?.reloadData()
                }
                
                presentingVC.seletedCategory = category
                
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
            
        case .showFormulaDetail:
            
            break
            
        default:
            break
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
    
    /// 滚动结束触发
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        containerScrollerOffsetX = scrollView.contentOffset.x
        
        let index = Int(scrollView.contentOffset.x / UIScreen.main.bounds.width)
        let vc = childViewControllers[index] as! UICollectionViewController
        
        vc.view.frame = CGRect(x: CGFloat(index) * UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let topEdge = 64 + Config.TopControl.height + 44
        let bottomEdge: CGFloat = 49
        
        
        vc.collectionView?.contentInset = UIEdgeInsets(top: topEdge, left: 0, bottom: bottomEdge, right: 0)
        vc.collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: topEdge - 44, left: 0, bottom: bottomEdge, right: 0)
        
        scrollView.addSubview(vc.view)
        
        
        
        updateNavigationBarButtonItemStatus()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        topControl.updateIndicaterPozition(scrollerViewOffsetX: scrollView.contentOffset.x)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollViewDidEndScrollingAnimation(scrollView)
        
        topControl.updateButtonStatus(scrollerViewOffsetX: scrollView.contentOffset.x)
        
    }
    
}












