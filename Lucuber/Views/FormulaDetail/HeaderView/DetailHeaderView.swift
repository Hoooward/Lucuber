//
//  DetailHeaderView.swift
//  Lucuber
//
//  Created by Howard on 7/19/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class DetailHeaderView: UIView {

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
   
    var formula: Formula? {
        didSet {
            if let formula = formula {
               
                nameLabel.text = formula.name
                printLog("imageName = \(formula.imageName)")
                imageView.image = UIImage(named: formula.imageName)
                ratingView.rating = formula.rating
                ratingView.maxRating = 5
                
            }
        }
    }
    
    ///外界读取方便设置自己的frame
    var headerHeight: CGFloat {
        return CGRectGetMaxY(creatTimeLabel.frame) + 20
    }
    
    func makeUI() {
        
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(creatUserLabel)
        addSubview(creatTimeLabel)
        addSubview(ratingView)
        
        let ratingWidth = CubeConfig.DetailFormula.ratingViewWidth
        let margin = CubeConfig.DetailFormula.screenMargin
        let imageWidth = screenWidth - margin - margin
        
        imageView.frame = CGRect(x: margin, y: 5, width: imageWidth, height: imageWidth)
        
        nameLabel.frame = CGRect(x: margin, y: CGRectGetMaxY(imageView.frame) + 15, width: imageWidth - ratingWidth, height: 24)
        
        ratingView.frame = CGRect(x: CGRectGetMaxX(imageView.frame) - ratingWidth, y: nameLabel.frame.origin.y, width: ratingWidth, height: 35)
        
        creatUserLabel.frame = CGRect(x: margin, y: CGRectGetMaxY(nameLabel.frame) + 8, width: imageWidth, height: 16)
        
        creatTimeLabel.frame = CGRect(x: margin, y: CGRectGetMaxY(creatUserLabel.frame) + 5, width: imageWidth, height: 16)
    }
    
    

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "F2L 1"
        label.font = UIFont.systemFontOfSize(20)
        label.sizeToFit()
        return label
    }()
    
    private lazy var creatUserLabel: UILabel = {
        let label = UILabel()
        label.text = "来自: 魔方小站"
        label.font = UIFont.systemFontOfSize(13)
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
    
    private lazy var creatTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "最后更新时间： 06-05"
        label.font = UIFont.systemFontOfSize(13)
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = UIImage(named: "placeholder")
        return imageView
    }()
    
    private lazy var ratingView: StarRatingView = {
        let view = StarRatingView()
        view.rating = 5
        view.maxRating = 5
        view.editable = false
        return view
    }()
}


















