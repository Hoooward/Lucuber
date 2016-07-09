//
//  FormulaInputViewController.swift
//  Lucuber
//
//  Created by Howard on 16/7/9.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class SubTitle: NSObject {
    
    var isDeleteButton = false
    
    var capitalLetter = ""
    var lowerLetter = ""
}

private let KeyboardButtonCellIdentifier = "KeyboardButtonCellIdentifier"
class FormulaInputViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(keyboardCollectionView)
        view.addSubview(tabBar)
        
        keyboardCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        let tabbarBottom = NSLayoutConstraint(item: tabBar, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        let tabbarLeading = NSLayoutConstraint(item: tabBar, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
        let tabbarTrailing = NSLayoutConstraint(item: tabBar, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([tabbarBottom, tabbarLeading, tabbarTrailing])
        
        let keyboardTop = NSLayoutConstraint(item: keyboardCollectionView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let keyboardLeading = NSLayoutConstraint(item: keyboardCollectionView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
        let keyboardTrailing = NSLayoutConstraint(item: keyboardCollectionView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
        let keyboardBottom = NSLayoutConstraint(item: keyboardCollectionView, attribute: .Bottom, relatedBy: .Equal, toItem: tabBar, attribute: .Bottom, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([keyboardTop, keyboardLeading, keyboardTrailing, keyboardBottom])

    }

    private lazy var keyboardCollectionView: UICollectionView = {
        [unowned self] in
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: InputCollectionViewLayout())
        collectionView.registerClass(KeyboardButtonCell.self, forCellWithReuseIdentifier: KeyboardButtonCellIdentifier)
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var tabBar: UITabBar = {
        let tabbar = UITabBar()
        return tabbar
    }()

}

extension FormulaInputViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("KeyboardButtonCellIdentifier", forIndexPath: indexPath) as! KeyboardButtonCell
        cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.redColor() : UIColor.greenColor()
        return cell
    }
}

class KeyboardButtonCell: UICollectionViewCell {
    
    
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.userInteractionEnabled = false
        let title = "R"
        button.setTitle(title, forState: .Normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI() {
        button.frame = CGRectInset(self.contentView.bounds, 4, 4)
        contentView.addSubview(button)
    }
}

 //键盘布局
private class InputCollectionViewLayout: UICollectionViewFlowLayout {
    override func prepareLayout() {
        super.prepareLayout()
        let width = screenWidth / 7
        itemSize = CGSize(width: width, height: width)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0 
    }
}