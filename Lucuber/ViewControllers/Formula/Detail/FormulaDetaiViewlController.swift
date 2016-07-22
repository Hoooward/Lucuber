//
//  ShowFormulaontroller.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

private let DetailCellIdetifier = "DetailCollectionViewCell"
class FormulaDetaiViewlController: UIViewController, SegueHandlerType{
    
    // MARK: - Segue Enum
    enum SegueIdentifier: String {
        case CommentViewController = "ShowCommentVC"
        case EditFormulaViewController = "ShowAddFormulaSegue"
    }

    // MARK: - Propreties
    private let layout = ShowFormulaDetailLayout()
    var collectionView: UICollectionView!
    
    var formulas: [Formula]?
    
    var seletedFormulaIndexAtFormulasData: Int? {
        return formulas!.indexOf { $0 === seletedFormula }
    }
    
    var seletedFormula: Formula? 
    
    // MARK: - Life Cycle
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        collectionView = UICollectionView(frame: screenBounds, collectionViewLayout: layout)
        collectionView.registerNib(UINib(nibName: DetailCellIdetifier, bundle: nil), forCellWithReuseIdentifier: DetailCellIdetifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(collectionView)
        view.addSubview(customNavigationBar)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        customNavigationBar.alpha = 1
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        if let index = seletedFormulaIndexAtFormulasData {
            collectionView!.setContentOffset(CGPoint(x: CGFloat(index) * screenWidth, y: 0), animated: false)
        }
        collectionView.reloadData()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
       
    }
    
    deinit {
        print("公式详情视图死了")
    }
    
    
    // MARK: - Notification & Targert
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        switch segueIdentifierForSegue(segue) {
            
        case .CommentViewController:
            let commentVC = segue.destinationViewController as! CommentTableViewController
            commentVC.formula = sender as? Formula
            
        case .EditFormulaViewController:
            let editVC = segue.destinationViewController as! AddNewFormulaViewController
            if let formula = sender as? Formula {
                editVC.formula = formula
            }
        }
    }
    
    
    func popViewController() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func editFormula() {
        if let window = view.window {
            editFormulaSheetView.showInView(window)
        }
        
    }

    let titles = ["编辑此公式", "删除此公式", "取消"]
    private func creatEditActionSheetViewItem() -> ActionSheetView.Item {
        return ActionSheetView.Item.Option(
            title: "编辑此公式",
            titleColor: UIColor.cubeTintColor(),
            action: { [weak self] in
                guard let strongSelf = self else { return }
                
                let sb = UIStoryboard(name: "AddFormula", bundle: nil)
                let navigationVC = sb.instantiateInitialViewController() as! MainNavigationController
                let viewController = navigationVC.viewControllers.first as! AddNewFormulaViewController
                viewController.formula = strongSelf.seletedFormula!
                strongSelf.presentViewController(navigationVC, animated: true, completion: nil)
                
        })
    }
    
    private func crearDeleteActionSheetViewItem() -> ActionSheetView.Item {
        return ActionSheetView.Item.Option(
            title: "删除此公式",
            titleColor: UIColor.redColor(),
            action: { [weak self] in
                guard let strongSelf = self else { return }
             
                CubeAlert.confirmOrCancel(
                    title: "删除",
                    message: "删除之后将不能恢复,确定要删除吗?",
                    confirmTitle: "删除",
                    cancelTitles: "取消",
                    inViewController: strongSelf,
                    withConfirmAction: {
                       // TODO: - 删除公式
                    },
                    cancelAction: {
                        strongSelf.dismissViewControllerAnimated(true, completion: nil)
                })
        
        })
        
    }
    
    private lazy var editFormulaSheetView: ActionSheetView = {
       let item1 = self.creatEditActionSheetViewItem()
       let item2 = self.crearDeleteActionSheetViewItem()
       let item3 = ActionSheetView.Item.Cancel
       let sheetView = ActionSheetView(items: [item1, item2, item3])
        return sheetView
    }()
    
    private lazy var customNavigationItem: UINavigationItem = {
        
        let item = UINavigationItem(title: "Detail")
        
        item.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .Plain, target: self, action: #selector(FormulaDetaiViewlController.popViewController))
        
        item.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_settings"), style: .Plain, target: self, action: #selector(FormulaDetaiViewlController.editFormula))
        
        return item
    }()
    
    
    private lazy var customNavigationBar: UINavigationBar = {
        let bar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 64))
        bar.tintColor = UIColor.blackColor()
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
    
   
    
}

// MARK: - CollectionViewDelegate & DataSource
extension FormulaDetaiViewlController:  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return formulas?.count ?? 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DetailCellIdetifier, forIndexPath: indexPath) as! DetailCollectionViewCell

        cell.pushCommentViewController = {
            [unowned self] formula in
            self.performSegueWithIdentifier(SegueIdentifier.CommentViewController, sender: formula)
        }
        
        if let formula = formulas?[indexPath.item] {
            cell.formula = formula
            self.customNavigationBar.items?.first?.title = formula.name
            self.seletedFormula = formula
        }
        
        return cell
    }
    
}
