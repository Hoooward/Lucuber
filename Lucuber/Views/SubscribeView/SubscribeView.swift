//
//  SubscribeView.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/14.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

final class SubscribeView: UIView {
    
    static let totalHeight: CGFloat = 50
    
    var subscribeAction: (() -> Void)?
    var showWithChangeAction: (() -> Void)?
    var hidWithChangeAction: (() -> Void)?
    
    weak var bottomConstraint: NSLayoutConstraint?
    
    private lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_subscribe_notify")
        return imageView
    }()
    
    private lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "获取推送通知"
        label.textColor = UIColor.darkGray
        return label
    }()
    
    private lazy var subscribeButton: BorderButton = {
        let button = BorderButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle("订阅", for: .normal)
        button.setTitleColor(UIColor.cubeTintColor(), for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
        
        button.addTarget(self, action: #selector(SubscribeView.subscribe), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_subscribe_close"), for: .normal)
        button.addTarget(self, action: #selector(SubscribeView.dismiss), for: .touchUpInside)
        
        return button
    }()
    
    func show() {
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            
            self?.bottomConstraint?.constant = 0
            self?.showWithChangeAction?()
            self?.superview?.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func hide() {
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            
            self?.bottomConstraint?.constant = SubscribeView.totalHeight
            self?.hidWithChangeAction?()
            self?.superview?.layoutIfNeeded()
            
            
        }, completion: nil)
        
    }
    
    func dismiss() {
        
        hide()
    }
    
    func subscribe() {
        
        subscribeAction?()
        hide()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        
        makeUI()
    }
    
    func makeUI() {
        
        backgroundColor = UIColor.white
        
        do {
            addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
        
        do {
            let horizontalLineView = HorizontalLineView()
            addSubview(horizontalLineView)
            horizontalLineView.translatesAutoresizingMaskIntoConstraints = false
            
            horizontalLineView.backgroundColor = UIColor.clear
            horizontalLineView.atBottom = false
            
            let views: [String: AnyObject] = [
                "horizontalLineView": horizontalLineView,
                ]
            
            let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[horizontalLineView]|", options: [], metrics: nil, views: views)
            
            let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[horizontalLineView(1)]", options: [], metrics: nil, views: views)
            
            NSLayoutConstraint.activate(constraintsH)
            NSLayoutConstraint.activate(constraintsV)
        }
        
        do {
            blurView.contentView.addSubview(iconImageView)
            blurView.contentView.addSubview(promptLabel)
            blurView.contentView.addSubview(subscribeButton)
            blurView.contentView.addSubview(dismissButton)
            
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            promptLabel.translatesAutoresizingMaskIntoConstraints = false
            subscribeButton.translatesAutoresizingMaskIntoConstraints = false
            dismissButton.translatesAutoresizingMaskIntoConstraints = false
            
            let views: [String: AnyObject] = [
                "iconImageView": iconImageView,
                "promptLabel": promptLabel,
                "subscribeButton": subscribeButton,
                "dismissButton": dismissButton,
                ]
            
            let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[iconImageView]-[promptLabel]-(>=10)-[subscribeButton]-[dismissButton]-(9)-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views)
            
            let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[dismissButton]|", options: [], metrics: nil, views: views)
            
            NSLayoutConstraint.activate(constraintsH)
            NSLayoutConstraint.activate(constraintsV)
        }
    }
}


























