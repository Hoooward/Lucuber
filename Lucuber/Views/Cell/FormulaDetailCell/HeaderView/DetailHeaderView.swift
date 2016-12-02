//
//  DetailHeaderView.swift
//  Lucuber
//
//  Created by Howard on 7/19/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVOSCloud
import RealmSwift

class DetailHeaderView: UIView {

    // MARK: - Properties
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        return dateFormatter
    }()
    //外界读取方便设置自己的frame
    public var headerHeight: CGFloat {
        return creatTimeLabel.frame.maxY
    }

    public var updateFormulaContentCell: ((Formula) -> Void)?
    public var updateCurrentShowFormula: ((Formula) -> Void)?
    public var updateNavigationBar: ((Formula) -> Void)?
    public var updateMasterCell: ((Formula) -> Void)?
    public var afterDeleteFormulaDataIsEmpty: (() -> Void)?
    
    fileprivate let realm = try! Realm()
    
    fileprivate var selectedType: Type = .Cross
    fileprivate var selectedCategory: Category = .x3x3
    fileprivate var uploadMode: UploadFormulaMode = .library
    
    fileprivate var formulasData: Results<Formula> {
        return formulasWith(self.uploadMode, category: self.selectedCategory, type: self.selectedType, inRealm: self.realm)
    }
    
    public func reloadDataAfterDelete() {
        
        if formulasData.count == 0 {
           
            afterDeleteFormulaDataIsEmpty?()
        } else {
            
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            print(collectionView.contentOffset)
            
            scrollViewDidEndScrollingAnimation(collectionView)
            
            updateUI(with: formulasData[currentIndex])

            let point = CGPoint(x: CGFloat(currentIndex) * scrollDistance - Config.DetailHeaderView.screenMargin , y: 0)
            
            
            // 滚两次是为了触发中心卡片放大.
            collectionView.setContentOffset(CGPoint.zero, animated: false)
            collectionView.setContentOffset(point, animated: false)
            
            
            
        }
        
        
    }
    
    public func configView(with formula: Formula?, withUploadMode uploadMode: UploadFormulaMode) {
        
        guard let formula = formula else {
            return
        }
        
        self.selectedType = formula.type
        self.selectedCategory = formula.category
        self.uploadMode = uploadMode
        
        if let index = formulasData.index(of: formula) {
            
            let point = CGPoint(x: CGFloat(index) * scrollDistance - Config.DetailHeaderView.screenMargin , y: 0)
            
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            collectionView.setContentOffset(point, animated: true)
            
            updateUI(with: formula)
        }
        
    }
    
    fileprivate func updateUI(with formula: Formula) {
        
        updateCurrentShowFormula?(formula)
        updateNavigationBar?(formula)
        updateFormulaContentCell?(formula)
        updateMasterCell?(formula)
        
        starRatingView.rating = formula.rating
        starRatingView.maxRating = formula.rating
        
        categoryIndicator.configureWithCategory(category: formula.category.rawValue)
          locationIndicatorLable.text = " - 当前第 \(self.currentIndex + 1) 个, 共 \(self.formulasData.count) 个 -"
        
        currentFormula = formula
       
        if formula.isLibrary {
            creatUserLabel.text = "创建者: Lucuber"
        } else {
            creatUserLabel.text = "创建者: \(formula.creator?.nickname ?? "未知")"
        }
        
        let date = Date(timeIntervalSince1970: formula.createdUnixTime)
        creatTimeLabel.text = "更新: " + dateFormatter.string(from: date)
        
    }
    
    private lazy var layout: DeatilHeaderCollectionViewLayout = {
        let layout = DeatilHeaderCollectionViewLayout()
        return layout
    }()
    
    fileprivate var scrollDistance: CGFloat = Config.DetailHeaderView.imageViewWidth + Config.DetailHeaderView.collectionViewMinimumLineSpacing
    
    fileprivate var scrollToRight = true
    fileprivate var lastContentOffsetX: CGFloat = 0
    fileprivate var currentIndex = 0
    fileprivate var currentFormula: Formula?
    fileprivate let headerViewCellIdentifier = "HeaderViewCell"
    
    fileprivate lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        collectionView.register(HeaderViewCell.self, forCellWithReuseIdentifier: self.headerViewCellIdentifier)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    
    private lazy var creatUserLabel: UILabel = {
        let label = UILabel()
        label.text = "创建者: 魔方小站"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    private lazy var locationIndicatorLable: UILabel = {
        let label = UILabel()
        label.text = "当前第2个, 共100个"
        label.font = UIFont.systemFont(ofSize: 8)
        label.textAlignment = .center
        label.textColor = UIColor.lightGray
        return label
    }()
    
    private lazy var creatTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "更新: 16-06-05"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .right
        label.textColor = UIColor.lightGray
        return label
    }()
    
    private lazy var starRatingView: StarRatingView = {
        let view = StarRatingView()
        view.rating = 5
        view.maxRating = 5
        view.editable = false
        return view
    }()
    
    private lazy var categoryIndicator: CategoryIndicatorView = {
        let indicator = CategoryIndicatorView()
        return indicator
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action & Target
    
    func makeUI() {
        
        addSubview(categoryIndicator)
        addSubview(locationIndicatorLable)
        addSubview(creatUserLabel)
        addSubview(creatTimeLabel)
        addSubview(starRatingView)
        addSubview(collectionView)
        
        let margin = Config.DetailHeaderView.screenMargin
        let imageWidth = Config.DetailHeaderView.imageViewWidth
        
        categoryIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.frame = CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: imageWidth)
        
        locationIndicatorLable.frame = CGRect(x: margin, y: collectionView.frame.maxY + 5, width: collectionView.frame.width - margin * 2, height: 10)
        
        let categoryIndicatorTrailing = NSLayoutConstraint.init(item: categoryIndicator, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -margin)
        
        let cateogyrIndicatorTop = NSLayoutConstraint(item: categoryIndicator, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: imageWidth + 25)
        
        NSLayoutConstraint.activate([categoryIndicatorTrailing, cateogyrIndicatorTop])
        
        starRatingView.frame = CGRect(x: margin, y: collectionView.frame.maxY + 25, width: 80, height: 15)
        
        creatUserLabel.frame = CGRect(x: margin, y: starRatingView.frame.maxY + 20, width: 200, height: 16)
        creatTimeLabel.frame = CGRect(x: collectionView.frame.width - margin - 100, y: starRatingView.frame.maxY + 20, width: 100, height: 16)
    }
    
}

extension DetailHeaderView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return formulasData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: headerViewCellIdentifier, for: indexPath) as! HeaderViewCell
        
        cell.configCell(with: formulasData[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let imageWidth = Config.DetailHeaderView.imageViewWidth
        return CGSize(width: imageWidth, height: collectionView.bounds.height)
    }
    
}


extension DetailHeaderView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if self.lastContentOffsetX < scrollView.contentOffset.x {
            self.scrollToRight = true
            
        } else {
            self.scrollToRight = false
        }
        
        self.lastContentOffsetX = scrollView.contentOffset.x
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        //http://www.jianshu.com/p/bb921a1cbf32 参考
        
        if self.scrollToRight {
            
            let currentCount = Int(scrollView.contentOffset.x / self.scrollDistance) + 1
            if currentCount == 1 {
                let totalScrollDistance = self.scrollDistance - self.collectionView.contentInset.left
                scrollView.setContentOffset(CGPoint(x: CGFloat(currentCount) * totalScrollDistance, y: 0), animated: true)
                
            } else if currentCount < formulasData.count && currentCount > 1 {
                
                let totalScrollDistance = CGFloat(currentCount) * self.scrollDistance - self.collectionView.contentInset.left
                scrollView.setContentOffset(CGPoint(x: totalScrollDistance, y: 0), animated: true)
            } else {
                
                let totalScrollDistance = CGFloat(formulasData.count - 1) * self.scrollDistance - self.collectionView.contentInset.left
                scrollView.setContentOffset(CGPoint(x: totalScrollDistance, y: 0), animated: true)
            }
        } else {
            
            let currentCount = Int(scrollView.contentOffset.x/self.scrollDistance)
            let totalScrollDistance = CGFloat(currentCount) * self.scrollDistance - self.collectionView.contentInset.left
            scrollView.setContentOffset(CGPoint(x: totalScrollDistance, y: 0), animated: true)
        }
    }
    
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        let firstItemDistance = scrollView.contentOffset.x - self.collectionView.contentInset.left
        
        if firstItemDistance < 0 {
            currentIndex = 0
            
        } else {
            
            currentIndex = Int(firstItemDistance / self.scrollDistance) + 1
            
            if currentIndex > formulasData.count - 1 {
                currentIndex = formulasData.count - 1
            }
        }
        
        self.updateUI(with: formulasData[currentIndex])
    }
    
}

















