//
//  FeedURLContainerView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/6.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Kingfisher

public class FeedURLContainerView: UIView {
    
    var tapAction: (() -> Void)?
    
    private var needMakeUI: Bool = true
    
    var directionLeading = true {
        
        didSet {
            
            if directionLeading {
                backgroundImageView.image = UIImage(named: "url_container_left_backgroud")
            } else {
                backgroundImageView.image = UIImage(named: "url_container_right_background")
            }
        }
    }
    
    var compressionMode: Bool = false {
        didSet {
            if needMakeUI {
                makeUI()
                needMakeUI = false
            }
        }
    }
    
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "url_container_left_background")
        return imageView
    }()
    
    lazy var siteNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        return label
    }()
    
    lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(FeedURLContainerView.tap(gesture:)))
        addGestureRecognizer(tap)
    }
    
    private func makeUI () {
        
        addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(siteNameLabel)
        addSubview(titleLabel)
        siteNameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomContainerView = UIView()
        addSubview(bottomContainerView)
        
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomContainerView.addSubview(descriptionLabel)
        bottomContainerView.addSubview(thumbnailImageView)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: AnyObject] = [
            "backgroundImageView": backgroundImageView,
            "siteNameLabel": siteNameLabel,
            "titleLabel": titleLabel,
            "bottomContainerView": bottomContainerView,
            "descriptionLabel": descriptionLabel,
            "thumbnailImageView": thumbnailImageView
        ]
        
        
        do {
            let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", options: [], metrics: nil, views: views)
            let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", options: [], metrics: nil, views: views)
            
            NSLayoutConstraint.activate(constraintsH)
            NSLayoutConstraint.activate(constraintsV)
        }
        
        do {
            let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[siteNameLabel]-|", options: [], metrics: nil, views: views)
            
            let metrcs: [String: Any] = [
                "top": compressionMode ? 4 : 8,
                "gap": compressionMode ? 4 : 8,
                "bottom": compressionMode ? 4 : 8
            ]
            
            let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[siteNameLabel(15)]-(gap)-[titleLabel(15)]-(gap)-[bottomContainerView]-(bottom)-|", options: [.alignAllLeading, .alignAllTrailing], metrics: metrcs, views: views)
            
            NSLayoutConstraint.activate(constraintsH)
            NSLayoutConstraint.activate(constraintsV)
        }
        
        do {
            let metrics: [String: Any] = [
                "imageSize": compressionMode ? 35 : 40,
                ]
            
            let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[descriptionLabel]-[thumbnailImageView(imageSize)]|", options: [.alignAllTop], metrics: metrics, views: views)
            
            let constraintsV1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[descriptionLabel]-(>=0)-|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
            
            let constraintsV2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[thumbnailImageView(imageSize)]", options: [.alignAllLeading, .alignAllTrailing], metrics: metrics, views: views)
            
            NSLayoutConstraint.activate(constraintsH)
            NSLayoutConstraint.activate(constraintsV1)
            NSLayoutConstraint.activate(constraintsV2)
        }
    }
    
    func tap(gesture: UIGestureRecognizer) {
        tapAction?()
    }
    
    public func configureWithOpenGraphInfoType(openGraphInfo: OpenGraphInfoType) {
    
        siteNameLabel.text = openGraphInfo.siteName
        titleLabel.text = openGraphInfo.title
        descriptionLabel.text = openGraphInfo.infoDescription
        
        if let imageURL = URL(string: openGraphInfo.thumbnailImageURLString) {
            thumbnailImageView.kf.setImage(with: ImageResource.init(downloadURL: imageURL), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            
        } else {
            thumbnailImageView.image = nil
            thumbnailImageView.backgroundColor = UIColor.lightGray
        }
    
    }
    
    
    
    
    
}
