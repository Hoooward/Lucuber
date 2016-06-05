//
//  ShowFormulaontroller.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

private let ShowDetialCellIdentifier = "ShowDetailCell"
class ShowFormulaDetailController: UIViewController {

    private let layout = ShowFormulaDetailLayout()
    var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView = UICollectionView(frame: screenBounds, collectionViewLayout: layout)
        collectionView.registerNib(UINib(nibName: ShowDetialCellIdentifier, bundle: nil), forCellWithReuseIdentifier: ShowDetialCellIdentifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        view.addSubview(customNavigationBar)
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        customNavigationBar.alpha = 1
        
        self.setNeedsStatusBarAppearanceUpdate()
        collectionView!.setContentOffset(CGPoint(x: CGFloat(parentSeleteIndexPath.item) * screenWidth, y: 0), animated: false)
        collectionView.reloadData()
        
    }
    

    private lazy var customNavigationItem: UINavigationItem = UINavigationItem(title: "Detail")
    private lazy var customNavigationBar: UINavigationBar = {
        let bar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 64))
        bar.tintColor = UIColor.whiteColor()
        bar.tintAdjustmentMode = .Normal
        bar.alpha = 0
        bar.setItems([self.customNavigationItem], animated: false)
        bar.backgroundColor = UIColor.clearColor()
        bar.translucent = true
        bar.shadowImage = UIImage()
        bar.barStyle = UIBarStyle.BlackTranslucent
        bar.setBackgroundImage(UIImage(named:"navigationbar_backgroud"), forBarMetrics: UIBarMetrics.Default)
        
        let textAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(),
                              NSFontAttributeName: UIFont.navigationBarTitleFont()]
        bar.titleTextAttributes = textAttributes
        return bar
    }()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    /// 公式数据
    var formulasData = [Formula]()
    /// 跳转到此界面时的被传值
    var parentSeleteIndexPath: NSIndexPath = NSIndexPath(forItem: 0, inSection: 0) {
        didSet {
            print(parentSeleteIndexPath)
            formulasData = FormulaManager.shardManager().Alls[parentSeleteIndexPath.section]
        }
    }
    
}

extension ShowFormulaDetailController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return formulasData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ShowDetialCellIdentifier, forIndexPath: indexPath) as! ShowDetailCell
        cell.updateNavigatrionBar = {
            [weak self] formula in
            self?.customNavigationBar.items?.first?.title = formula!.name
        }
        cell.formula = formulasData[indexPath.item]
        return cell
    }
}
