//
//  FormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FormulaViewController: UIViewController {
    
    
    let topControl = UIView()
    let topIndicater = UIView()
    var topControlSeletedButton: UIButton?
    var containerScrollerView = UIScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
    }
 
    private func makeUI() {
        addChileViewController()
        addTopControl()
        addAddButton()
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
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.itemWithCustomButton(UIImage(named: "navigationbar_left_heng"), seletedImage: UIImage(named: "navigationbar_left_jing"), targer: self, action: #selector(FormulaViewController.barButtonClick(_:)))
    }
    
    func barButtonClick(button: UIButton) {
            button.selected = !button.selected
    }
    
    private func addChileViewController() {
        
        let layout = FormulaCollectionLayout()
        let myFormulaVC = MyFormulaViewController(collectionViewLayout: layout)
        myFormulaVC.title = "我的公式"
        addChildViewController(myFormulaVC)
        let formulaLibraryVC = FormulaLibraryViewController(collectionViewLayout: layout)
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
            button.addTarget(self, action: #selector(FormulaViewController.topControlBtnClick(_:)), forControlEvents: .TouchUpInside)
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

extension FormulaViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
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
































