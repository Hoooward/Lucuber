//
//  BaseFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

private let CardCellIdentifier = "CardFormulaCell"
private let NormalCellIdentifier = "NormalFormulaCell"
private let DetailCellIdentifier = "DetailFormulaCell"
private let NoResultCellIdentifier = "NoResultCell"
private let HeaderViewIdentifier = "HeaderReusableView"

enum FormulaUserMode: Int {
    case Normal = 0
    case Card
}

class BaseFormulaViewController: UICollectionViewController, SegueHandlerType {
    
    // ref http://stackoverflow.com/questions/19483511/uirefreshcontrol-with-uicollectionview-in-ios7
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        view.addSubview(searchBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum SegueIdentifier: String{
        case ShowFormulaDetail = "ShowFormulaDetailSegue"
    }
    
//    var formulaManager = FormulaManager.shardManager()
    var formulasData: [[Formula]] = []
    var searchResult: [Formula] = []
    
    var searchBarActive = false
    var haveSearchResult: Bool {
        return searchResult.count > 0
    }
    ///用来缓存进入搜索模式时当前的UserMode
    var cacheBeforeSearchUserMode: FormulaUserMode?
    
    var userMode: FormulaUserMode = .Card {
        didSet {
            
            switch userMode {
            case .Card:
                view.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1.0)
            case .Normal:
                view.backgroundColor = UIColor.whiteColor()
            }
            
            collectionView?.reloadData()
        }
    }
    
    /// 当前控制器所选择显示的公式种类
    var seletedCategory: Category?
    
    // MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseFormulaViewController.containerFormulaViewDidChanged(_:)), name: ContainerDidScrollerNotification, object: nil)
    }
    
    func changeLayoutButtonSeletedStatus() {
        if let layoutButton = parentViewController?.navigationItem.leftBarButtonItem?.customView as? LayoutButton {
            layoutButton.userMode = userMode
        }
    }
    
    func changeLayoutButtonEnable(enable: Bool) {
        if let layoutButton = parentViewController?.navigationItem.leftBarButtonItem {
            layoutButton.enabled = enable
        }
    }
    
    func containerFormulaViewDidChanged(notification: NSNotification) {
        if let offsetX = notification.object as? CGFloat {
            //代表进入第二个集合视图
            if offsetX == screenWidth && self.isKindOfClass(LibraryFormulaViewController) {
                print("我是第二个视图")
                changeLayoutButtonSeletedStatus()
            }
            //代表进入第一个集合视图
            if offsetX == 0 && self.isKindOfClass(MyFormulaViewController) {
                print("我是第一个视图")
                changeLayoutButtonSeletedStatus()
            }
            cancelSearch()
        }
    }
    
    private func makeUI() {
//        view.addSubview(searchBar)
        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView!.registerNib(UINib(nibName: CardCellIdentifier, bundle: nil), forCellWithReuseIdentifier: CardCellIdentifier)
        collectionView!.registerNib(UINib(nibName: NormalCellIdentifier, bundle: nil), forCellWithReuseIdentifier: NormalCellIdentifier)
        collectionView!.registerNib(UINib(nibName: DetailCellIdentifier, bundle: nil), forCellWithReuseIdentifier: DetailCellIdentifier)
        collectionView?.registerNib(UINib(nibName: NoResultCellIdentifier, bundle: nil), forCellWithReuseIdentifier: NoResultCellIdentifier)
        collectionView?.registerNib(UINib(nibName:HeaderViewIdentifier, bundle: nil ), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: HeaderViewIdentifier)
    }
    
    private var searchBarFrameY: CGFloat = 64 + topControlHeight + 5
    lazy var searchBar: FormulaSearchBar = {
        [unowned self] in
        let rect = CGRect(x: 0, y: self.searchBarFrameY , width: screenWidth, height: 44)
        let searchBar = FormulaSearchBar(frame: rect)
        searchBar.delegate = self
       
        self.collectionView?.addObserver(self, forKeyPath: "contentOffset", options: [.New, .Old], context: nil)
        return searchBar
    }()
    
    deinit {
        collectionView?.removeObserver(self, forKeyPath: "contentOffset")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - KVO 
    //collectionView的ContentOffset改变的时候刷新searchbar的位置
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath! == "contentOffset" {
            if let collectionView = object as? UICollectionView {
                searchBar.frame = CGRect(x: searchBar.frame.origin.x, y: searchBarFrameY + ((-1 * collectionView.contentOffset.y) - searchBarFrameY - searchBar.frame.size.height), width: searchBar.frame.width, height: searchBar.frame.height)
            }
        }
    }

}
// MARK: - SearchBar Delegate
extension BaseFormulaViewController: UISearchBarDelegate {
    
    func cancelSearch() {
        searchResult.removeAll()
        searchBar.resignFirstResponder()
        searchBar.dismissCancelButton()
        searchBar.text = ""
        searchBarActive = false
        if let _ = cacheBeforeSearchUserMode {
            userMode = cacheBeforeSearchUserMode!
            cacheBeforeSearchUserMode = nil
        }
        changeLayoutButtonEnable(true)
        collectionView?.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            searchResult.removeAll()
        }
        searchBarActive = true
        searchResult = FormulaManager.shardManager().searchFormulasWithSearchText(searchText)
        collectionView?.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
       
        cancelSearch()
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        (searchBar as! FormulaSearchBar).showCancelButton()
        searchBarActive = true
        cacheBeforeSearchUserMode = userMode
        if cacheBeforeSearchUserMode != .Normal { userMode = .Normal }
        changeLayoutButtonEnable(false)
        collectionView?.reloadData()
    }
}

// MARK - CollectionView Delegate
extension BaseFormulaViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderViewIdentifier, forIndexPath: indexPath) as! HeaderReusableView
        return reusableView
    }

    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if searchBarActive {
            return 1
        }
        return formulasData.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            if searchBarActive {
                return haveSearchResult ? searchResult.count : 1
            }
            return formulasData[0].count
        case 1:
            return formulasData[1].count
        case 2:
            return formulasData[2].count
        default:
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if searchBarActive && !haveSearchResult {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NoResultCellIdentifier, forIndexPath: indexPath) as! NoResultCell
            return cell
        }
        
        switch userMode {
        case .Card:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CardCellIdentifier, forIndexPath: indexPath) as! CardFormulaCell
            return cell
        case .Normal:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NormalCellIdentifier, forIndexPath: indexPath) as! NormalFormulaCell
            return cell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        // 设置cell要显示数据
        
        var formula: Formula!
        switch indexPath.section {
        case 0:
            if searchBarActive && haveSearchResult {
                formula = searchResult[indexPath.item]
            } else {
                formula = formulasData[0][indexPath.item]
            }
        case 1:
            formula = formulasData[1][indexPath.item]
        case 2:
            formula = formulasData[2][indexPath.item]
        default:
            break
        }
        
        
        if searchBarActive && !haveSearchResult {
            return
        }
        
        switch userMode {
        case .Normal:
            let cell = cell as! NormalFormulaCell
            cell.formula = formula
        case .Card:
            let cell = cell as! CardFormulaCell
            cell.formula = formula
           
        }
    }
    
    ///每个cell的Size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch userMode {
        case .Normal:
            return CGSize(width: screenWidth, height: 80)
        case .Card:
            return CGSize(width: (screenWidth - (10 + 10 + 10)) * 0.5, height: 280)
        }
    }
    
    ///返回每个section的EdgeInset
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        switch userMode {
        case .Normal:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .Card:
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }

    }
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(#function)
    
        let seletedFormula = formulasData[indexPath.section][indexPath.row]
        let formulas = formulasData[indexPath.section]
        
        let dict = ["formulas": formulas, "seletedFormula": seletedFormula]
        self.parentViewController!.performSegueWithIdentifier(SegueIdentifier.ShowFormulaDetail.rawValue, sender: dict)
    }
    
 
    

}
