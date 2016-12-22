//
//  FeedUploadingErrorContainerView.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FeedUploadingErrorContainerView: UIView {
    
    
    var retryAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    
    lazy var leftContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1, green: 56/255.0, blue: 36/255.0, alpha: 0.1)
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_error"))
        return imageView
    }()
    
    lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "加载失败"
        label.textColor = UIColor.red
        return label
    }()
    
    lazy var retryButton: UIButton = {
        let button = UIButton()
        button.setTitle("重试", for: .normal)
        button.setTitleColor(UIColor.cubeTintColor(), for: .normal)
        button.addTarget(self, action: #selector(FeedUploadingErrorContainerView.retryUploadingFeed(sender:)), for: .touchUpInside)
        return button
    }()
    
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.red, for: .normal)
        button.setTitle("删除", for: .normal)
        button.addTarget(self, action: #selector(FeedUploadingErrorContainerView.deleteUploadingFeed(sender:)), for: .touchUpInside)
        return button
    }()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        makeUI()
    }
    
    func makeUI() {
        do {
            addSubview(leftContainerView)
            addSubview(deleteButton)
            
            leftContainerView.translatesAutoresizingMaskIntoConstraints = false
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            
            let viewsDictionary: [String: AnyObject] = [
                "leftContainerView": leftContainerView,
                
                "deleteButton": deleteButton]
            let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[leftContainerView]-15-[deleteButton]|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary)
            let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[leftContainerView]|", options: [], metrics: nil, views: viewsDictionary)
            
            NSLayoutConstraint.activate(constraintsH)
            NSLayoutConstraint.activate(constraintsV)
        }
        
        do {
            leftContainerView.addSubview(iconImageView)
            leftContainerView.addSubview(errorMessageLabel)
            leftContainerView.addSubview(retryButton)
            
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
            retryButton.translatesAutoresizingMaskIntoConstraints = false
            
            let viewsDictionary: [String: AnyObject] = [
                "iconImageView": iconImageView,
                "errorMessageLabel": errorMessageLabel,
                "retryButton": retryButton]
            
            let constrainsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[iconImageView]-[errorMessageLabel]-[retryButton]-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary)
            
            iconImageView.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
            iconImageView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
            
            let iconImageViewCenterY = NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: leftContainerView, attribute: .centerY, multiplier: 1.0, constant: 0)
            
            NSLayoutConstraint.activate(constrainsH)
            NSLayoutConstraint.activate([iconImageViewCenterY])
            
        }
    }
    
    func retryUploadingFeed(sender: UIGestureRecognizer) {
        retryAction?()
    }
    
    func deleteUploadingFeed(sender: UIGestureRecognizer) {
        deleteAction?()
    }
    
    
    
}
