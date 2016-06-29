//
//  FormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit


class ContainerViewController: UIViewController, SegueHandlerType {
    
    
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var layoutButton: UIButton!
    let topControl = UIView()
    let topIndicater = UIView()
    var topControlSeletedButton: UIButton?
    var containerScrollerView = UIScrollView()
    
    
    ///记录containerScrollerView的偏移量,用来判断左右被移动的距离,决定是否发送通知取消searchBar的第一响应
    var containerScrollerOffsetX: CGFloat = 0
    
    enum SegueIdentifier: String{
        case ShowFormulaDetail = "ShowFormulaDetailSegue"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segueIdentifierForSegue(segue) {
        case .ShowFormulaDetail:
            let vc = segue.destinationViewController as!ShowFormulaDetailController
            vc.parentSeleteIndexPath = sender as! NSIndexPath
            break
        }
        
    }

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
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
//          navigationController?.setNavigationBarHidden(true, animated: true)
    }
 
    private func makeUI() {
        addChileViewController()
        addTopControl()
//        addAddButton()
        setupScrollerView()
        setupNavigationbar()
    }
    
    let buttonWindow = UIWindow()
    private func addAddButton() {
        let button = UIButton(type: .Custom)
        button.setBackgroundImage(UIImage(named: "addButton_backgroundImage"), forState: .Normal)
        button.size = CGSize(width: 40, height: 40)
        buttonWindow.bounds = button.bounds
        buttonWindow.x = screenWidth - buttonWindow.width - 20
        buttonWindow.y = screenHeight - 49 - buttonWindow.height - 20
        buttonWindow.windowLevel = UIWindowLevelStatusBar
        buttonWindow.addSubview(button)
        buttonWindow.backgroundColor = UIColor.clearColor()
        
        buttonWindow.hidden = false
    }
    
    
    func setupNavigationbar() {
        let titleView = UILabel()
        titleView.text = "复原大法"
//        titleView.font = UIFont(name: "AvenirNext-Heavy", size: 19)
        titleView.textColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0 )
        titleView.sizeToFit()
        navigationItem.titleView = titleView
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "布局", style: .Plain, target: self, action: #selector(ContainerViewController.leftBarButtonClick(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "分类 ▾", style: .Plain, target: self, action: #selector(ContainerViewController.rightBarButtonClick(_:)))
    }
    
    func leftBarButtonClick(button: UIButton) {
        let index = containerScrollerView.contentOffset.x / screenWidth
        let childViewController = childViewControllers[Int(index)] as! BaseCollectionViewController
        childViewController.userMode = childViewController.userMode == .Card ? .Normal : .Card
    }
    func rightBarButtonClick(button: UIBarButtonItem) {
        
        print(#function)
    }
    
    private func addChileViewController() {
        
        let layout1 = NormalCollectionViewLayout()
        let myFormulaVC = MyFormulaViewController(collectionViewLayout: layout1)
        myFormulaVC.title = "我的公式"
        addChildViewController(myFormulaVC)
           let layout2 = CardCollectionViewLayout()
        let formulaLibraryVC = FormulaLibraryViewController(collectionViewLayout: layout2)
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
    
}

extension ContainerViewController: UIScrollViewDelegate {
    
    func postDidScrollNotification() {
       
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
         containerScrollerOffsetX = scrollView.contentOffset.x
        
        let index = Int(scrollView.contentOffset.x / screenWidth)
        let vc = childViewControllers[index] as! UICollectionViewController
        vc.view.frame = CGRect(x: CGFloat(index) * screenWidth, y: 0, width: screenWidth, height: screenHeight)
        
        let topEdge = 64 + topControl.height
        let bottomEdge: CGFloat = 49
        
        vc.collectionView?.contentInset = UIEdgeInsets(top: topEdge, left: 0, bottom: bottomEdge, right: 0)
        vc.collectionView?.scrollIndicatorInsets = vc.collectionView!.contentInset
        scrollView.addSubview(vc.view)
        
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let buttonCount = childViewControllers.count
        let buttonW = screenWidth / CGFloat(buttonCount)
        
        let scale = (CGFloat(buttonCount - 1) * screenWidth) / (screenWidth - buttonW)
        let offsetX = scrollView.contentOffset.x
        topIndicater.center.x = offsetX / scale + (buttonW * 0.5)
       
        print(abs(offsetX - containerScrollerOffsetX))
        
        //如果滚动超过屏幕三分之一
        if abs(offsetX - containerScrollerOffsetX) > screenWidth * 0.3 {
             NSNotificationCenter.defaultCenter().postNotificationName(ContainerDidScrollerNotification, object: nil, userInfo: nil)
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
































