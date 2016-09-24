//
//  BaseCollectionViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

private let CardCellIdentifier = "CardFormulaCell"
private let NormalCellIdentifier = "NormalFormulaCell"
private let NoResultCellIdentifier = "NoResultCell"
private let HeaderViewIdentifier = "HeaderReusableView"

class BaseCollectionViewController: UICollectionViewController, SegueHandlerType {
    
    // MARK: - Properties
    
    enum SegueIdentifier: String {
        case showFormulaDetail = "ShowFormulaDetail"
    }
    
    fileprivate var formulasData: [[Formula]] = []
    fileprivate var searchResult: [Formula] = []
    
    var uploadMode: UploadFormulaMode = .my
    
    /// 当前控制器所选择显示的公式种类
    var seletedCategory: Category = .x3x3
    
    
    fileprivate var searchBarActive = false
    fileprivate var haveSearchResult: Bool {
        return searchResult.count > 0
    }
    
    private var searchBarOriginY: CGFloat = 64 + Config.TopControl.height + 5
    
    fileprivate lazy var searchBar: FormulaSearchBar = {
        let rect = CGRect(x: 0, y: self.searchBarOriginY, width: UIScreen.main.bounds.width, height: 44)
        let searchBar = FormulaSearchBar(frame: rect)
        searchBar.delegate = self
    
        // 添加属性观察
        self.collectionView?.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
        return searchBar
    }()
    
    
    /// 缓存进入搜索模式前的UserMode
    var cacheBeforeSearchUserMode: FormulaUserMode?
    
    var userMode: FormulaUserMode = .card {
        
        didSet {
            
            switch userMode {
                
            case .card:
                view.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1.0)

            case .normal:
                view.backgroundColor = UIColor.white
            }
            
            collectionView?.reloadData()
        }
    }
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.frame.origin = CGPoint(x: (UIScreen.main.bounds.width - indicator.frame.width) * 0.5, y: 64 + 120)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    
    // MARK: - Left Cycle
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(collectionViewLayout: layout)
        
        // 在这里添加 Searchbar 工作正常， 如果在 ViewDidLoad中添加不正常
        view.addSubview(searchBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        makeUI()
    }
    
    private func makeUI() {
        
//        view.addSubview(searchBar)
        collectionView?.addSubview(activityIndicator)
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(UINib(nibName: CardCellIdentifier, bundle: nil), forCellWithReuseIdentifier: CardCellIdentifier)
        collectionView?.register(UINib(nibName: NormalCellIdentifier, bundle: nil), forCellWithReuseIdentifier: NormalCellIdentifier)
        collectionView?.register(UINib(nibName: NoResultCellIdentifier, bundle: nil), forCellWithReuseIdentifier: NoResultCellIdentifier)
        collectionView?.register(UINib(nibName: HeaderViewIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: HeaderViewIdentifier)

        
        
        // TODO:
        activityIndicator.startAnimating()
    }

    deinit {
        collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    // MARK: - Action & Target & Observer
    
    /// 在 collectionView 的 offset Y 发生变化的时候， 即时更新 searchBar 的位置
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let key = keyPath,
              key == "contentOffset",
              let collectionView = object as? UICollectionView  else {
            return
        }
        
        searchBar.frame = CGRect(x: searchBar.frame.origin.x, y: searchBarOriginY + ((-1 * collectionView.contentOffset.y) - searchBarOriginY - searchBar.frame.size.height), width: searchBar.frame.width, height: searchBar.frame.height)
        
    }

    
    fileprivate func changeLayoutButton(enable: Bool) {
        
        if let layoutButtonItem = parent?.navigationItem.leftBarButtonItem {
            layoutButtonItem.isEnabled = enable
        }
    }
    
    func changeLayoutButtonStatus() {
        
        if let layoutButton = parent?.navigationItem.leftBarButtonItem?.customView as? LayoutButton {
            layoutButton.userMode = userMode
        }
    }
    
    
    fileprivate var isUploadingFormula: Bool = false
    
    func uploadingFormulas(with mode: UploadFormulaMode = .library, category: Category, finish: (() -> Void)? ) {
        
        
        if isUploadingFormula {
            finish?()
            return
        }
        
        isUploadingFormula = true
        
        self.activityIndicator.startAnimating()
        
        /// 网络请求失败 -> 闭包
        let failureHandler: (_ error: NSError) -> Void = {
            error in
            
            DispatchQueue.main.async {
                [unowned self] in
                
                
                CubeAlert.alertSorry(message: "加载失败，请检查您的网络连接或稍后再试。", inViewController: self)
                
                // TODO: 这里目前没有重试的入口
                
                self.activityIndicator.stopAnimating()
                finish?()
            }
        }
        
        
        let completion: ([Formula]) -> Void = {
            
            formulas in
            
            
            DispatchQueue.main.async {
                
                [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.isUploadingFormula = false
                strongSelf.searchBar.isHidden = false
                
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
                            
                        case .F2L:
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
                    
                    strongSelf.searchBar.isHidden = true
                    strongSelf.formulasData = resultFormula
                    
                }
                
                strongSelf.activityIndicator.stopAnimating()
                
                printLog(strongSelf.formulasData)
                
                
                finish?()
                
            }
        }
        
       
        fetchFormulaWithMode(uploadingFormulaMode: mode, category: category, completion: completion, failureHandler: failureHandler)
        
         
     }
    

}

extension BaseCollectionViewController: UISearchBarDelegate {
    
    func cancelSearch() {
        
        searchResult.removeAll()
        
        searchBar.resignFirstResponder()
        searchBar.dismissCancelButton()
        searchBar.text = ""
        searchBarActive = false
        
        printLog(self.searchBar)
        printLog(self)
        
        if let _ = cacheBeforeSearchUserMode {
            userMode = cacheBeforeSearchUserMode!
            cacheBeforeSearchUserMode = nil
        }
        
        changeLayoutButton(enable: true)
        collectionView?.reloadData()
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            searchResult.removeAll()
        }
        
        searchBarActive = true
        
        // FIXME: 搜索公式
//        searchResult = 
        
        collectionView?.reloadData()
    
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        printLog(searchBar)
        cancelSearch()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let searchBar = searchBar as? FormulaSearchBar {
            searchBar.showCancelButton()
        }
        searchBarActive = true
        cacheBeforeSearchUserMode = userMode
        if cacheBeforeSearchUserMode != .normal {
            userMode = .normal
        }
        changeLayoutButton(enable: false)
        collectionView?.reloadData()
        
    }
    
}


// MARK: - CollectionView Delegate & Layout

extension BaseCollectionViewController: UICollectionViewDelegateFlowLayout {
   
    
    
     override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if searchBarActive {
            return 1
        }
        
        return formulasData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        switch section {
            
        case 0:
            
            if searchBarActive {
                return haveSearchResult ? searchResult.count : 1
            }
            
            return formulasData[section].count
            
        
        default:
            
            return formulasData[section].count
            
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if  searchBarActive && !haveSearchResult {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoResultCellIdentifier, for: indexPath)
            
            return cell
        }
        
        switch userMode {
            
        case .normal:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NormalCellIdentifier, for: indexPath)
            
            return cell
            
        case .card:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCellIdentifier, for: indexPath)
            
            return cell
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if searchBarActive && !haveSearchResult {
            return
        }
        
        var formula: Formula!
        
        switch indexPath.section {
            
        case 0:
            
            if searchBarActive && haveSearchResult {
                
                formula = searchResult[indexPath.item]
            } else {
                formula = formulasData[indexPath.section][indexPath.item]
            }
            
        default:
            
            formula = formulasData[indexPath.section][indexPath.item]
        }
        
        
        if searchBarActive && !haveSearchResult {
            return
        }
        
        switch userMode {
            
        case .normal:
            
            guard let cell = cell as? NormalFormulaCell else {
                
                return
            }
            
            cell.configerCell(with: formula)
            
        case .card:
            
            guard let cell = cell as? CardFormulaCell else {
                
                return
            }
            
            cell.configerCell(with: formula)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch userMode {
        case .normal:
            
            return Config.FormulaCell.normalCellSize
            
        case .card:
            
            return  Config.FormulaCell.cardCellSize
        
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        switch userMode {
            
        case .normal:
            return Config.FormulaCell.normalCellEdgeInsets
            
        case .card:
            return Config.FormulaCell.cardCellEdgeInsets
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        printLog("Did Seleted one Formula")
        
        let seletedFormula = formulasData[indexPath.section][indexPath.row]
        let formulas = formulasData[indexPath.section]
        
        let dict: [String: Any] = ["formuls": formulas, "seletedFormula" : seletedFormula]
        self.parent?.performSegue(withIdentifier: SegueIdentifier.showFormulaDetail.rawValue, sender: dict)
    }
    
    
    
    
    
    
}






















