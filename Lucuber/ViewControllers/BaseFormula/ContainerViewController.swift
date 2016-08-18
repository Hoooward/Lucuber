//
//  FormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit


class CategoryBarButtonItem: UIBarButtonItem {
    var seletedCategory: Category? {
        willSet {
            self.title = (newValue?.rawValue)! + " ▾"
        }
    }
    
}


class ContainerViewController: UIViewController, SegueHandlerType {
    
    
    // MARK: - Properties
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var layoutButton: UIButton!
    let topControl = UIView()
    let topIndicater = UIView()
    var topControlSeletedButton: UIButton?
    var containerScrollerView = UIScrollView()
    
    
    /// Right category barButtonItems
    var categoryItems = [Category]()
    
    ///记录containerScrollerView的偏移量,用来判断左右被移动的距离,决定是否发送通知取消searchBar的第一响应
    var containerScrollerOffsetX: CGFloat = 0 {
        didSet {
        }
    }
    
    enum SegueIdentifier: String{
        case ShowFormulaDetail = "ShowFormulaDetailSegue"
        case ShowAddFormula = "ShowAddFormulaSegue"
    }
    
    
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segueIdentifierForSegue(segue) {
            
        case .ShowFormulaDetail:
            
            let vc = segue.destinationViewController as! FormulaDetaiViewlController
            
            if let dict = sender as? [String: AnyObject] {
                
                vc.seletedFormula = dict["seletedFormula"] as? Formula
                vc.formulas = dict["formulas"] as? [Formula]
                vc.hidesBottomBarWhenPushed = true
                
            }
        case .ShowAddFormula:
            
            
            
            let nvc = segue.destinationViewController as! UINavigationController
            let vc = nvc.viewControllers[0] as! NewFormulaViewController
            
            vc.editType = NewFormulaViewController.EditType.NewFormula
            
            vc.view.alpha = 1
            
            if let presentingVC = childViewControllers[Int(containerScrollerOffsetX / screenWidth)] as? BaseFormulaViewController {
                
                let formula = Formula.creatNewDefaultFormula()
               
                formula.category = presentingVC.seletedCategory ?? Category.x3x3
                
                vc.formula = formula
                
                vc.afterSaveNewFormula = {
                    
                    presentingVC.collectionView?.reloadData()
                }
            }
            
            
            break
        }
        
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        hidesBottomBarWhenPushed = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
 
    // MARK: - Make UI
    private func makeUI() {
        setupNavigationbar()
        addChileViewController()
        addTopControl()
        setupScrollerView()
    }
    
    
    func setupNavigationbar() {
        
        navigationItem.title = "复原大法"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.creatLayoutButtonItem(self, action: #selector(ContainerViewController.layoutButtonClick(_:)))
     
        navigationItem.rightBarButtonItem = CategoryBarButtonItem(title: "", style: .Plain, target: self, action: #selector(ContainerViewController.categoryButtonClick(_:)))
        
    }
    
    private func addChileViewController() {
        
        let myFormulaLayout = BaseFormulaLayout()
        let myFormulaVC = MyFormulaViewController(collectionViewLayout: myFormulaLayout)
        myFormulaVC.title = "我的公式"
        addChildViewController(myFormulaVC)
        let libraryLayout = BaseFormulaLayout()
        let formulaLibraryVC = LibraryFormulaViewController(collectionViewLayout: libraryLayout)
        formulaLibraryVC.title = "公式库"
        addChildViewController(formulaLibraryVC)
    }
    
    
    private func addTopControl() {
        topControl.frame = CGRect(x: 0, y: 64, width: UIScreen.mainScreen().bounds.width, height: 36)
        topControl.backgroundColor = UIColor.clearColor()
        view.addSubview(topControl)
        
        topIndicater.backgroundColor = UIColor.cubeTintColor()
        topIndicater.height = 2.0
        topIndicater.y = topControl.height - topIndicater.height
        topIndicater.tag = -1
        
        let buttonWidth: CGFloat = screenWidth / CGFloat(childViewControllers.count)
        let buttonHeight: CGFloat = topControl.height
        var buttonX: CGFloat = 0
        for index in 0..<childViewControllers.count {
            let button = UIButton(type: .Custom)
            button.tag = index
            button.setTitle(childViewControllers[index].title, forState: .Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(16)
            button.setTitleColor(UIColor ( red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0 ) , forState: .Normal)
            button.setTitleColor(UIColor.cubeTintColor(), forState: .Disabled)
            buttonX = buttonWidth * CGFloat(index)
            button.frame = CGRectMake(buttonX, 0, buttonWidth, buttonHeight)
            button.addTarget(self, action: #selector(ContainerViewController.topControlBtnClick(_:)), forControlEvents: .TouchUpInside)
            topControl.addSubview(button)
            if index == 0 {
                topControlSeletedButton = button
                button.enabled = false
                button.layoutIfNeeded()
                topIndicater.x = button.width * 0.3
                topIndicater.width = button.width * 0.4
            }
        }
        let backView = UIImageView(image: UIImage(named: navigationBarImage))
        backView.frame = topControl.bounds
        topControl.insertSubview(backView, atIndex: 0)
        topControl.addSubview(topIndicater)
    }
    
    func topControlBtnClick(button: UIButton) {
        topControlSeletedButton!.enabled = true
        button.enabled = false
        topControlSeletedButton = button
        
        let index = button.tag
        let offsetX = CGFloat(index) * screenWidth
        containerScrollerView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    private func setupScrollerView() {
        
        containerScrollerView.frame = screenBounds
        containerScrollerView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        containerScrollerView.pagingEnabled = true
        containerScrollerView.contentSize = CGSize(width: screenWidth * CGFloat(childViewControllers.count), height: 0)
        
        view.insertSubview(containerScrollerView, atIndex: 0)
        scrollViewDidEndScrollingAnimation(containerScrollerView)
    }
    
    
    // MARK: - Target
    func layoutButtonClick(button: UIButton) {
        
        button.selected = !button.selected
        
        if let vc = childViewControllers[Int(containerScrollerOffsetX / screenWidth)] as? BaseFormulaViewController {
            vc.userMode = vc.userMode == .Card ? .Normal : .Card
        }
        
    }
    
    func categoryButtonClick(button: UIBarButtonItem) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        if
            let menuVC = sb.instantiateViewControllerWithIdentifier("CategoryMenuViewController") as? CategoryMenuViewController,
            let presentingVC = childViewControllers[Int(containerScrollerOffsetX / screenWidth)] as? BaseFormulaViewController,
            let category = presentingVC.seletedCategory {
            
            
            var categorys = getCategoryMenusAtRealm(presentingVC.uploadMode)
            
            if categorys.isEmpty { categorys.append(.x3x3) }
            
            
            let menuHeight = CubeConfig.CagetoryMenu.rowHeight * CGFloat(categorys.count ) + 20 + 10
            
            menuAnimator.presentedFrmae = CGRect(x: CubeConfig.CagetoryMenu.menuOrignX, y: 60, width: CubeConfig.CagetoryMenu.menuWidth, height: menuHeight)
            menuVC.transitioningDelegate = menuAnimator
            menuVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            menuVC.seletedCategory = category
            menuVC.cubeCategorys = categorys
            
            menuVC.categoryDidChanged = {
                category in
        
                presentingVC.uploadFormulas( presentingVC.uploadMode, category: category) {
                    
                    presentingVC.collectionView?.reloadData()
                    
                }
               
                presentingVC.seletedCategory = category
                
                button.title = category.rawValue + " ▾"
                
                UserDefaults.setSelectedCategory(category, mode: presentingVC.uploadMode)
                    
                
            }
 
            presentViewController(menuVC, animated: true, completion: nil)
            
        }
    }
    
    private lazy var menuAnimator: PopMenuAnimator = {
        let animator = PopMenuAnimator()
        //指定出现视图的Rect
        return animator
    }()
    
   
    
    
    func updateNavigationBarButtonItemStatus() {
        
        guard
            let layoutButton = navigationItem.leftBarButtonItem?.customView as? LayoutButton,
            let categoyButton = navigationItem.rightBarButtonItem as? CategoryBarButtonItem
            else {
            fatalError()
        }
        
        if let vc = childViewControllers[Int(containerScrollerOffsetX / screenWidth)] as? BaseFormulaViewController {
            layoutButton.userMode = vc.userMode
            categoyButton.seletedCategory = vc.seletedCategory
        }
        
        childViewControllers.forEach {
            vc in
            if let vc = vc as? BaseFormulaViewController {
                vc.cancelSearch()
            }
        }
    }
    
   
    
}


// MARK: - SrollerViewDelegate
extension ContainerViewController: UIScrollViewDelegate {
    
    //滚动结束触发
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        
        containerScrollerOffsetX = scrollView.contentOffset.x
        
        let index = Int(scrollView.contentOffset.x / screenWidth)
        let vc = childViewControllers[index] as! UICollectionViewController
        vc.view.frame = CGRect(x: CGFloat(index) * screenWidth, y: 0, width: screenWidth, height: screenHeight)
        
        let topEdge = 64 + topControl.height + 44
        let bottomEdge: CGFloat = 49
        
        vc.collectionView?.contentInset = UIEdgeInsets(top: topEdge, left: 0, bottom: bottomEdge, right: 0)
        vc.collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: topEdge - 44, left: 0, bottom: bottomEdge, right: 0)
        scrollView.addSubview(vc.view)
        
        updateNavigationBarButtonItemStatus()
        
//        NSNotificationCenter.defaultCenter().postNotificationName(ContainerDidScrollerNotification, object: containerScrollerOffsetX, userInfo: nil)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let buttonCount = childViewControllers.count
        let buttonW = screenWidth / CGFloat(buttonCount)
        
        let scale = (CGFloat(buttonCount - 1) * screenWidth) / (screenWidth - buttonW)
        let offsetX = scrollView.contentOffset.x
        topIndicater.center.x = offsetX / scale + (buttonW * 0.5)
       
        //如果滚动超过屏幕三分之一
        if abs(offsetX - containerScrollerOffsetX) > screenWidth * 0.3 {
//             NSNotificationCenter.defaultCenter().postNotificationName(ContainerDidScrollerNotification, object: nil, userInfo: nil)
        }
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
        
        let index = scrollView.contentOffset.x / screenWidth
        
        var buttonArray = [UIButton]()
        topControl.subviews.forEach {
            view in
            if view.isKindOfClass(UIButton.classForCoder()) {
                buttonArray.append(view as! UIButton)
            }
        }
        
        let tageter = buttonArray[Int(index)]
        topControlBtnClick(tageter)
    }
}
