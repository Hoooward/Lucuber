//
//  FeedFormulaContainerView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/9.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Kingfisher


public class FeedFormulaContainerView: UIView {
    
    var tapAction: (() -> Void)?
    
    private var needMakeUI: Bool = true
    
    var compressionMode: Bool = false {
        didSet {
            if needMakeUI {
                makeUI()
                needMakeUI = false
            }
        }
    }
    
    lazy var indicatorView: CategoryIndicatorView = {
        let indicatorView = CategoryIndicatorView()
        indicatorView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return indicatorView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        return label
    }()
    
    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.image = UIImage(named: "url_container_left_background")
        return imageView
    }()
    
    lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        self.layer.borderWidth = 1.0

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(FeedURLContainerView.tap(gesture:)))
        addGestureRecognizer(tap)
    }
    
    func tap(gesture: UIGestureRecognizer) {
        tapAction?()
    }
    
    public func configureWithDiscoverFormula(formula: DiscoverFormula) {
        
        nameLabel.text = formula.name
        
        indicatorView.configureWithCategory(category: formula.category)
        
        let contents = formula.contents.filter {
            $0.deletedByCreator == false
            }

        countLabel.text = "含 \(contents.count) 个公式"
        
        if let firstContent = contents.first {
            contentLabel.text = firstContent.text
        } else {
            contentLabel.text = "..."
        }
        
//        contentLabel.text = "..................."
        
        if let imageURL = URL.init(string: formula.imageURL) {
            
            thumbnailImageView.kf.setImage(with: ImageResource.init(downloadURL: imageURL, cacheKey: nil), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            thumbnailImageView.image = nil
            thumbnailImageView.backgroundColor = UIColor.lightGray
            
        }
        
    }
    
    private func makeUI() {
        
        
        addSubview(backgroundImageView)
        addSubview(thumbnailImageView)
        addSubview(nameLabel)
        addSubview(countLabel)
        addSubview(indicatorView)
        addSubview(contentLabel)
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let views: [String: AnyObject] = [
            "backgroundImageView": backgroundImageView,
        ]
        
        do {
            let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", options: [], metrics: nil, views: views)
            let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", options: [], metrics: nil, views: views)
            
            NSLayoutConstraint.activate(constraintsH)
            NSLayoutConstraint.activate(constraintsV)
        }
        
        let imageWidth: CGFloat = compressionMode ? 60 : 70
        let thumbnailImageViewLeftConstant: CGFloat = compressionMode ? 12 : 15
        do {
            
            let thumbnailImageViewLeft = NSLayoutConstraint.init(item: thumbnailImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: thumbnailImageViewLeftConstant)
            
            let thumbnailImageViewCenterY = NSLayoutConstraint.init(item: thumbnailImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            
            let thumbnailImageViewHeight = NSLayoutConstraint.init(item: thumbnailImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: imageWidth)
            
              let thumbnailImageViewWidth = NSLayoutConstraint.init(item: thumbnailImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: imageWidth)
            
            NSLayoutConstraint.activate([thumbnailImageViewLeft, thumbnailImageViewCenterY, thumbnailImageViewHeight, thumbnailImageViewWidth])
            
        }
        
        do {
            let nameLabelLeft = NSLayoutConstraint.init(item: nameLabel, attribute: .leading, relatedBy: .equal, toItem: thumbnailImageView, attribute: .leading, multiplier: 1, constant: imageWidth + 10)
            
            let nameLabelTop = NSLayoutConstraint.init(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: thumbnailImageView, attribute: .top, multiplier: 1, constant: 0)
            
            let nameLabelTrailing = NSLayoutConstraint.init(item: nameLabel, attribute: .trailing, relatedBy: .equal, toItem: indicatorView, attribute: .leading, multiplier: 1, constant: -10)
         
             NSLayoutConstraint.activate([nameLabelLeft, nameLabelTop, nameLabelTrailing])
        }
        
        
        do {
            
            let indicatorViewTrailing = NSLayoutConstraint.init(item: indicatorView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10)
            
            let indicatorViewCenterY = NSLayoutConstraint.init(item: indicatorView, attribute: .centerY, relatedBy: .equal, toItem: nameLabel, attribute: .centerY, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activate([indicatorViewTrailing, indicatorViewCenterY])
            
        }
        
        do {
            
            let contentLabelLading = NSLayoutConstraint(item: contentLabel, attribute: .leading, relatedBy: .equal, toItem: nameLabel, attribute: .leading, multiplier: 1, constant: 0)
            
            let contentLabelBottom = NSLayoutConstraint(item: contentLabel, attribute: .bottom, relatedBy: .equal, toItem: thumbnailImageView, attribute: .bottom, multiplier: 1, constant: 0)
            
            let contentLabelTrailing = NSLayoutConstraint.init(item: contentLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activate([contentLabelLading, contentLabelBottom, contentLabelTrailing])
            
        }
        
        do {
            
            let countLabelLeft = NSLayoutConstraint.init(item: countLabel, attribute: .leading, relatedBy: .equal, toItem: nameLabel, attribute: .leading, multiplier: 1, constant: 0)
            
            let countLabelTop = NSLayoutConstraint.init(item: countLabel, attribute: .top, relatedBy: .equal, toItem: nameLabel, attribute: .bottom, multiplier: 1, constant: 5)
            
            let countLabelTrailing = NSLayoutConstraint.init(item: countLabel, attribute: .trailing, relatedBy: .equal, toItem: indicatorView, attribute: .leading, multiplier: 1, constant: 10)
            
            NSLayoutConstraint.activate([countLabelLeft, countLabelTop, countLabelTrailing])
            
        }
        
        
        
    }
    
}






