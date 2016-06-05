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
        
//        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        view.addSubview(customNavigationBar)
        
         collectionView.alwaysBounceVertical = false
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        customNavigationBar.alpha = 1
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return UIStatusBarStyle.LightContent
//    }

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
        bar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        
        let textAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),
                              NSFontAttributeName: UIFont.navigationBarTitleFont()]
        bar.titleTextAttributes = textAttributes
        return bar
    }()
    
}

extension ShowFormulaDetailController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ShowDetialCellIdentifier, forIndexPath: indexPath)
        return cell
    }
}
