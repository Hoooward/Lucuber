//
//  BaseCollectionViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift

private let cardCellIdentifier = "CardFormulaCell"
private let normalCellIdentifier = "NormalFormulaCell"
private let noResultCellIdentifier = "NoResultCell"
private let headerViewIdentifier = "HeaderReusableView"

class BaseCollectionViewController: UICollectionViewController, SegueHandlerType {
    
    // MARK: - Properties
    
    enum SegueIdentifier: String {
        case showFormulaDetail = "ShowFormulaDetail"
    }
    
    fileprivate var realm: Realm! = try! Realm()
    
    fileprivate var searchResult: [Formula] = []
    
    public lazy var vistorView = MyFormulaVisitorView(frame: UIScreen.main.bounds)
    
    public var uploadMode: UploadFormulaMode = .my
    
    public var seletedCategory: Category = .x3x3
    
    public var formulasData: Results<Formula> {
        return formulasWith(self.uploadMode, category: self.seletedCategory, inRealm: self.realm)
    }
    
    fileprivate var formulas: [[Formula]] {
        var formulas = [[Formula]]()
        
        var types = Set<Type>()
        self.formulasData.forEach {
            if !types.contains($0.type) {
                types.insert($0.type)
            }
        }
        
        types.sorted { $0.sortIndex > $1.sortIndex }.forEach {
            
            let predicate = NSPredicate(format: "typeString = %@", $0.rawValue)
            let fromulasType = self.formulasData.filter(predicate)
            
            if !fromulasType.isEmpty {
                formulas.append(fromulasType.map{$0})
            }
        }
        
        return formulas
    }
    
    
    
    /// 缓存进入搜索模式前的UserMode
    fileprivate var cacheBeforeSearchUserMode: FormulaUserMode?
    
    public var userMode: FormulaUserMode = .card {
        
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
    
    
    fileprivate var searchBarActive = false
    fileprivate var haveSearchResult: Bool {
        return searchResult.count > 0
    }
    
    private var searchBarOriginY: CGFloat = 64 + Config.TopControl.height + 5
    
    public lazy var searchBar: FormulaSearchBar = {
        let rect = CGRect(x: 0, y: self.searchBarOriginY, width: UIScreen.main.bounds.width, height: 44)
        let searchBar = FormulaSearchBar(frame: rect)
        searchBar.delegate = self
    
        /// add KVO
        self.collectionView?.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
        return searchBar
    }()
    
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
        
        collectionView?.addSubview(activityIndicator)
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(UINib(nibName: cardCellIdentifier, bundle: nil), forCellWithReuseIdentifier: cardCellIdentifier)
        collectionView?.register(UINib(nibName: normalCellIdentifier, bundle: nil), forCellWithReuseIdentifier: normalCellIdentifier)
        collectionView?.register(UINib(nibName: noResultCellIdentifier, bundle: nil), forCellWithReuseIdentifier: noResultCellIdentifier)
        collectionView?.register(UINib(nibName: headerViewIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader , withReuseIdentifier: headerViewIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView?.reloadData()
    }

    deinit {
        collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    // MARK: - Action & Target & Observer
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        /// 在 collectionView 的 offset Y 发生变化的时候， 即时更新 searchBar 的位置
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
    
    fileprivate func changeLayoutButtonStatus() {
        
        if let layoutButton = parent?.navigationItem.leftBarButtonItem?.customView as? LayoutButton {
            layoutButton.userMode = userMode
        }
    }
    
    
    // MARK: - Network
    
    public var isUploadingFormula: Bool = false
   

}

// MARK: - SearhBarDelegate

extension BaseCollectionViewController: UISearchBarDelegate {
    
//    func pareseTwoDimensionalToOne() -> [Formula] {
//        
//        var resultArray: [Formula] = []
//        
//        _ = formulasData.map {
//            
//            $0.map {
//                
//                resultArray.append($0) }
//        }
//        return resultArray
//        
//    }
    
    func searchFormulas(with searchText: String?) -> [Formula] {
        
        guard let text = searchText, text.characters.count > 0 else {
            return []
        }
        
        return formulasData.filter {
            $0.name.trimmingSearchtext().contains(text.trimmingSearchtext())
        }
    }
    
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
        
        changeLayoutButton(enable: true)
        collectionView?.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            searchResult.removeAll()
        }
        
        searchBarActive = true
        
        // FIXME: 搜索公式
        searchResult = searchFormulas(with: searchText)
        
        collectionView?.reloadData()
    
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
        
        return formulas.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        switch section {
        case 0:
            if searchBarActive {
                return haveSearchResult ? searchResult.count : 1
            }
            return formulas[section].count
        
        default:
            
            return formulas[section].count
            
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if  searchBarActive && !haveSearchResult {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: noResultCellIdentifier, for: indexPath)
            
            return cell
        }
        
        switch userMode {
            
        case .normal:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: normalCellIdentifier, for: indexPath)
            
            return cell
            
        case .card:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cardCellIdentifier, for: indexPath)
            
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
                formula = formulas[indexPath.section][indexPath.item]
            }
            
        default:
            
            formula = formulas[indexPath.section][indexPath.item]
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
        
        var selectedFormula: Formula!
        
        if searchBarActive {
            selectedFormula = searchResult[indexPath.row]
        } else {
            selectedFormula = formulas[indexPath.section][indexPath.item]
        }
        
        self.parent?.performSegue(withIdentifier: SegueIdentifier.showFormulaDetail.rawValue, sender: selectedFormula)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerViewIdentifier, for: indexPath) as! HeaderReusableView
        
        let types = formulas.map { $0.first?.type }
        let counts = formulas.map { $0.count }
        
        reusableView.configerView(with: types[indexPath.section], count: counts[indexPath.section])
        
        return reusableView
        
    }
    
    
    
    
}






















