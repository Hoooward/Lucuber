//
//  BaseCollectionViewController.swift
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

enum FormulaUserMode: Int {
    case Normal = 0
    case Card
}

class BaseCollectionViewController: UICollectionViewController, SegueHandlerType {
    
    // ref http://stackoverflow.com/questions/19483511/uirefreshcontrol-with-uicollectionview-in-ios7
    
    enum SegueIdentifier: String{
        case ShowFormulaDetail = "ShowFormulaDetailSegue"
    }
    
    var formulaManager = FormulaManager.shardManager()
    var searchResult: [Formula] = []
    
    var searchBarActive = false
    var haveSearchResult: Bool { return searchResult.count > 0 }
    
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
    
    // MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        userMode = .Card
        formulaManager.loadNewFormulas { [weak self] in
            self?.collectionView?.reloadData()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseCollectionViewController.cancelSearch), name: ContainerDidScrollerNotification, object: nil)
        
    }
    
    private func makeUI() {
        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView!.registerNib(UINib(nibName: CardCellIdentifier, bundle: nil), forCellWithReuseIdentifier: CardCellIdentifier)
        collectionView!.registerNib(UINib(nibName: NormalCellIdentifier, bundle: nil), forCellWithReuseIdentifier: NormalCellIdentifier)
        collectionView!.registerNib(UINib(nibName: DetailCellIdentifier, bundle: nil), forCellWithReuseIdentifier: DetailCellIdentifier)
        collectionView?.registerNib(UINib(nibName: NoResultCellIdentifier, bundle: nil), forCellWithReuseIdentifier: NoResultCellIdentifier)
        view.addSubview(searchBar)
    }
    
    private var searchBarFrameY: CGFloat = 64 + topControlHeight + 5
    lazy var searchBar: FormulaSearchBar = {
        [weak self] in
        let rect = CGRect(x: 0, y: self!.searchBarFrameY , width: screenWidth, height: 44)
        let searchBar = FormulaSearchBar(frame: rect)
        searchBar.delegate = self
       
        self!.collectionView?.addObserver(self!, forKeyPath: "contentOffset", options: [.New, .Old], context: nil)
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
                searchBar.frame = CGRect(x: searchBar.frame.origin.x, y: searchBarFrameY + ((-1 * collectionView.contentOffset.y) - searchBarFrameY), width: searchBar.frame.width, height: searchBar.frame.height)
            }
        }
    }
    

}
// MARK: - SearchBar Delegate
extension BaseCollectionViewController: UISearchBarDelegate {
    
    func cancelSearch() {
        searchResult.removeAll()
        searchBar.resignFirstResponder()
        searchBar.dismissCancelButton()
        searchBar.text = ""
        searchBarActive = false
        collectionView?.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            searchResult.removeAll()
        }
        searchBarActive = true
        searchResult = formulaManager.searchFormulasWithSearchText(searchText)
        collectionView?.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        cancelSearch()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        (searchBar as! FormulaSearchBar).showCancelButton()
        searchBarActive = true
        collectionView?.reloadData()
    }
}

// MARK - CollectionView Delegate
extension BaseCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if searchBarActive {
            return 1
        }
        return formulaManager.Alls.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            if searchBarActive {
                return haveSearchResult ? searchResult.count : 1
            }
            return formulaManager.OLLs.count
        case 1:
            return formulaManager.PLLs.count
        case 2:
            return formulaManager.F2Ls.count
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
                formula = formulaManager.OLLs[indexPath.item]
            }
        case 1:
            formula = formulaManager.PLLs[indexPath.item]
        case 2:
            formula = formulaManager.F2Ls[indexPath.item]
        default:
            break
        }
        
        
        if searchBarActive && !haveSearchResult {
            return
        }
        
        switch userMode {
        case .Normal:
            let cell = cell as! NormalFormulaCell
            cell.formulaLabel.text = formula.formulaText.first
            cell.formulaNameLabel.text = formula.name
            cell.formulaImageView.image = UIImage(named: formula.imageName)
        case .Card:
            let cell = cell as! CardFormulaCell
            cell.formulaLabel.text = formula.formulaText.first!
            cell.formulaNameLabel.text = formula.name
            cell.formulaImageView.image = UIImage(named: formula.imageName)
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
            return UIEdgeInsets(top: self.searchBar.frame.size.height, left: 0, bottom: 0, right: 0)
        case .Card:
            return UIEdgeInsets(top: self.searchBar.frame.size.height, left: 10, bottom: 10, right: 10)
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(#function)
        
        self.parentViewController!.performSegueWithIdentifier(SegueIdentifier.ShowFormulaDetail.rawValue, sender: indexPath)
    }
}
