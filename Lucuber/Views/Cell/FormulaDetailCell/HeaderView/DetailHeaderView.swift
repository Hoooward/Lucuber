//
//  DetailHeaderView.swift
//  Lucuber
//
//  Created by Howard on 7/19/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import AVOSCloud

class DetailHeaderView: UIView {

    // MARK: - Properties
    
    var formulas: [UIImage] {
        
        var formulas = [UIImage]()
        for index in 1...10 {
            
            let image = UIImage(named: "PLL\(index)")!
            
            formulas.append(image)
        }
        return formulas
    }
    
    ///外界读取方便设置自己的frame
    var headerHeight: CGFloat {
        return creatTimeLabel.frame.maxY + 20
    }
    
    var formula: Formula? {
        didSet {
            if let formula = formula {
                
                nameLabel.text = formula.name
                imageView.cube_setImageAtFormulaCell(with: formula.imageURL ?? "", size: imageView.size)
                ratingView.rating = formula.rating
                ratingView.maxRating = 5
                
                
            }
        }
    }
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "F2L 1"
        label.font = UIFont.systemFont(ofSize: 20)
        label.sizeToFit()
        return label
        
    }()
    
    private lazy var creatUserLabel: UILabel = {
        let label = UILabel()
        label.text = "来自: 魔方小站"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    private lazy var creatTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "最后更新时间： 06-05"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var layout: DeatilHeaderCollectionViewLayout = {
        let layout = DeatilHeaderCollectionViewLayout()
        return layout
    }()
    fileprivate let headerViewCellIdentifier = "HeaderViewCell"
    
    fileprivate lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        collectionView.register(HeaderViewCell.self, forCellWithReuseIdentifier: self.headerViewCellIdentifier)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var ratingView: StarRatingView = {
        let view = StarRatingView()
        view.rating = 5
        view.maxRating = 5
        view.editable = false
        return view
    }()

    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Action & Target
    
    func makeUI() {
        
//        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(creatUserLabel)
        addSubview(creatTimeLabel)
        addSubview(ratingView)
        addSubview(collectionView)
        
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        
        let ratingWidth = Config.FormulaDetail.ratingViewWidth
        let margin = Config.FormulaDetail.screenMargin
        let imageWidth = UIScreen.main.bounds.width - margin - margin
        
        imageView.frame = CGRect(x: margin, y: 5, width: imageWidth, height: imageWidth)
        collectionView.frame = CGRect(x: 0, y: 5, width: UIScreen.main.bounds.width, height: imageWidth)
        
        nameLabel.frame = CGRect(x: margin, y: imageView.frame.maxY + 15, width: imageWidth - ratingWidth, height: 24)
        
        ratingView.frame = CGRect(x: imageView.frame.maxX - ratingWidth, y: nameLabel.frame.origin.y, width: ratingWidth, height: 35)
        
        creatUserLabel.frame = CGRect(x: margin, y: nameLabel.frame.maxY + 8, width: imageWidth, height: 16)
        
        creatTimeLabel.frame = CGRect(x: margin, y: creatUserLabel.frame.maxY + 5, width: imageWidth, height: 16)
    }
    
    
    func changeFormulaNameLabelStatus() {
        
        if
            let list = AVUser.current()?.masterList(),
            let formula = formula {
            
            nameLabel.textColor = list.contains(formula.localObjectID) ? UIColor.masterLabelText() : UIColor.black
            
        }
    }
    
    var scrollDistance: CGFloat = UIScreen.main.bounds.width - Config.FormulaDetail.screenMargin - Config.FormulaDetail.screenMargin + 6
    var scrollToRight = true
    var lastContentOffsetX: CGFloat = 0
}

extension DetailHeaderView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return formulas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: headerViewCellIdentifier, for: indexPath) as! HeaderViewCell
        
        cell.image = formulas[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin = Config.FormulaDetail.screenMargin
        let imageWidth = UIScreen.main.bounds.width - margin - margin

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
                
            } else if currentCount < formulas.count && currentCount > 1 {
                
                let totalScrollDistance = CGFloat(currentCount) * self.scrollDistance - self.collectionView.contentInset.left
                scrollView.setContentOffset(CGPoint(x: totalScrollDistance, y: 0), animated: true)
            } else {
                
                let totalScrollDistance = CGFloat(formulas.count - 1) * self.scrollDistance - self.collectionView.contentInset.left
                scrollView.setContentOffset(CGPoint(x: totalScrollDistance, y: 0), animated: true)
            }
        } else {
            
            let currentCount = Int(scrollView.contentOffset.x/self.scrollDistance)
            let totalScrollDistance = CGFloat(currentCount) * self.scrollDistance - self.collectionView.contentInset.left
            scrollView.setContentOffset(CGPoint(x: totalScrollDistance, y: 0), animated: true)
        }
    }
    
    
//    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
//        let cell = self.collection.cellForItemAtIndexPath(NSIndexPath.init(forItem: self.currentRow, inSection: 0)) as? XXCell
//        cell?.timer?.invalidate()
//        
//        // compute currentRow
//        let distanceWithoutFirstRow = scrollView.contentOffset.x - (self.scrollDistance - self.collection.contentInset.left)
//        if distanceWithoutFirstRow < 0 {
//            self.currentRow = 0
//        }
//        else{
//            self.currentRow = Int(distanceWithoutFirstRow/self.scrollDistance) + 1
//        }
//        self.loadBottomView(self.currentRow)
//    }
}

















