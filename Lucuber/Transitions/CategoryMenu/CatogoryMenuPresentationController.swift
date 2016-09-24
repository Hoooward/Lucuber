//
//  CatogoryMenuPresentationController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class CategoryMenuPresentationController: UIPresentationController {
    
    var predentedFrame = CGRect.zero
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = predentedFrame
        containerView?.insertSubview(maskBackgroundView, at: 0)
    }
    
    private lazy var maskBackgroundView: UIView = {
        let maskView = UIView()
        maskView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        maskView.frame = UIScreen.main.bounds
        let tap = UITapGestureRecognizer(target: self, action: #selector(CategoryMenuPresentationController.dismissPresentedViewController))
        maskView.addGestureRecognizer(tap)
        return maskView
    }()
    
    func dismissPresentedViewController() {
        
        presentedViewController.dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.post(name: .formulaCategoryMenuDidmissNotification, object: nil)
        
        
    }
    
}
