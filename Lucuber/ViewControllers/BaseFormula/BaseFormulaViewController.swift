//
//  BaseFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 6/4/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import RealmSwift

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
        view.addSubview(activityIndicator)
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
    
    var uploadMode = UploadFormulaMode.My
    
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
    
    
    lazy var activityIndicator: UIActivityIndicatorView =  {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicator.frame.origin = CGPoint(x: (screenWidth - indicator.frame.width) / 2, y: 64 + 120)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
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
                printLog("我是第二个视图")
                changeLayoutButtonSeletedStatus()
            }
            //代表进入第一个集合视图
            if offsetX == 0 && self.isKindOfClass(MyFormulaViewController) {
                printLog("我是第一个视图")
                changeLayoutButtonSeletedStatus()
            }
            cancelSearch()
        }
    }
    
    private func makeUI() {
//        view.addSubview(searchBar)
        collectionView!.addSubview(activityIndicator)
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
    
    var isUploadingFormula = false
    
    func uploadFormulas(mode: UploadFormulaMode = .Library, category: Category, finfish: (() -> Void)? ) {
        
        //0.1 从本地获取是否需要重新加载数据的标记,需要不需要更新就执行1
        
        //1. 从本地数据库加载
        if isUploadingFormula {
            finfish?()
            return
        }
      
        isUploadingFormula = true
        
        self.activityIndicator.startAnimating()
        
        
//        CubeHUD.showActivityIndicator()
      
        
        
        let failureHandler: (error: NSError) -> Void = {
            error in
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                
                CubeAlert.alertSorry(message: "加载失败,请重试", inViewController: self)
                 self?.activityIndicator.stopAnimating()
                
                finfish?()
            }
        }
        
        let completion: ([Formula]) -> Void = {
            
            formulas in
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.isUploadingFormula = false
                strongSelf.searchBar.hidden = false
                
                var resultFormula = [[Formula]]()
                
                if !formulas.isEmpty {
                    
                    var types = Set<Type>()
                    
                    formulas.forEach {
                        
                        if types.contains($0.type) {
                            return
                        }
                        types.insert($0.type)
                    }
                    
                    
                }
                
                
                if !formulas.isEmpty {
                    var crossFormulas = [Formula]()
                    var f2lFormulas = [Formula]()
                    var ollFormulas = [Formula]()
                    var pllFormulas = [Formula]()
                    
                    formulas.forEach {
                        
                        
                        switch $0.type {
                        case .CROSS:
                            crossFormulas.append($0)
                        case.F2L:
                            f2lFormulas.append($0)
                        case .OLL:
                            ollFormulas.append($0)
                        case .PLL:
                            pllFormulas.append($0)
                        }
                        
                    }
                    
                    if !crossFormulas.isEmpty {
                        resultFormula.append(crossFormulas)
                    }
                    
                    if !ollFormulas.isEmpty {
                        resultFormula.append(ollFormulas)
                    }
                    
                    if !pllFormulas.isEmpty {
                        resultFormula.append(pllFormulas)
                    }
                    if !f2lFormulas.isEmpty {
                        resultFormula.append(f2lFormulas)
                    }
                    
                    strongSelf.formulasData = resultFormula
             
                   
                    
                } else {
                    
                   strongSelf.searchBar.hidden = true
                   strongSelf.formulasData = resultFormula
                }
                
                strongSelf.activityIndicator.stopAnimating()
                
                CubeHUD.hideActivityIndicator()
                
                finfish?()
                
            }
        }
        
       
  
            
        fetchFormulaWithMode(mode, category:category, completion: completion, failureHandler: failureHandler)
            
    
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
        
        
        /// formulaData 是一个二维数组, 按照公式的不同 type 进行分类. 拿到数组的第一个元素就组成新的type数组. 用来设置section Header 的 Lable Text
        var formulaTypes = formulasData.map { $0.first?.type }
        reusableView.type = formulaTypes[indexPath.section]
        
        
        var counts = formulasData.map { $0.count }
        
        reusableView.count = counts[indexPath.section]
        
        
        
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
            return formulasData[section].count
        case 1:
            return formulasData[section].count
        case 2:
            return formulasData[section].count
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
                formula = formulasData[indexPath.section][indexPath.item]
            }
        case 1:
            formula = formulasData[indexPath.section][indexPath.item]
        case 2:
            formula = formulasData[indexPath.section][indexPath.item]
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
        printLog(#function)
    
        let seletedFormula = formulasData[indexPath.section][indexPath.row]
        let formulas = formulasData[indexPath.section]
        
        let dict = ["formulas": formulas, "seletedFormula": seletedFormula]
        self.parentViewController!.performSegueWithIdentifier(SegueIdentifier.ShowFormulaDetail.rawValue, sender: dict)
    }
    
 
    

}
