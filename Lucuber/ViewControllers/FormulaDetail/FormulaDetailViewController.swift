//
//  FormulaDetailViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/30.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

fileprivate let detailCellIdentifier = "DetailCollectionViewCell"

class FormulaDetailViewController: UIViewController, SegueHandlerType {
    
    // MARK: - Properties
    
    enum SegueIdentifier: String {
        case comment = "showCommentVC"
        case edit = "showAddFormula"
    }
    
    fileprivate let layout = DetailLayout()
    var collectionView: UICollectionView!
    
    var formulaDatas: [Formula] = []
    
    var seletedFormula: Formula?
    
    var seletedFormulaIndexPatchItem: Int? {
        
        if let formula = seletedFormula {
            
            return formulaDatas.index(of: formula)
        }
        return nil
    }
    
    
    private lazy var customNavigationItem: UINavigationItem = {
        
        let item = UINavigationItem(title: "Detail")
        
        item.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain, target: self, action: #selector(FormulaDetailViewController.popViewController))
        
        item.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_settings"), style: .plain, target: self, action: #selector(FormulaDetailViewController.editFormula))
        
        return item
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
                viewController.view.alpha = 1
                viewController.editType = NewFormulaViewController.EditType.editFormula
                viewController.formula = strongSelf.seletedFormula!
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
        
        
        
        return [editItem, deleteItem]
    }
    
    // MARK: - Life Cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        collectionView?.register(UINib(nibName: detailCellIdentifier, bundle: nil), forCellWithReuseIdentifier: detailCellIdentifier)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(collectionView)
        view.addSubview(customNavigationBar)
        view.backgroundColor = UIColor.white
        collectionView.backgroundColor = UIColor.white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        customNavigationBar.alpha = 1
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        if let index = seletedFormulaIndexPatchItem {
            collectionView.setContentOffset(CGPoint(x: CGFloat(index) * UIScreen.main.bounds.width, y: 0), animated: false)
        }
        collectionView.reloadData()
        
    }
    
    deinit {
        printLog("\(self) is dead")
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
            
        case .comment:
//            let commentVC = segue.destinationViewController as! CommentTableViewController
//            commentVC.formula = sender as? Formula
            
            break
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

extension FormulaDetailViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        printLog(formulaDatas.count)
        return formulaDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: detailCellIdentifier, for: indexPath) as! DetailCollectionViewCell
        
        cell.pushCommentViewController = {
            [unowned self] formula in
            self.performSegue(withIdentifier: SegueIdentifier.comment.rawValue, sender: formula)
        }
        
        let formula = formulaDatas[indexPath.item]
        cell.formula = formula
//        self.customNavigationBar.items?.first?.title = formula.name
        self.seletedFormula = formula
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let formula = formulaDatas[indexPath.item]
        self.customNavigationBar.items?.first?.title = formula.name
    }
    
}
