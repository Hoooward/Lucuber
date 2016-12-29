//
//  NewScoreGroupPresentationController.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/26.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation

class NewScoreGroupPresentationController: UIPresentationController {
    
    var predentedFrame = CGRect.zero
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = predentedFrame
        containerView?.insertSubview(maskBackgroundView, at: 0)
    }
    
    private lazy var maskBackgroundView: UIVisualEffectView = {
        let blue = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let maskView = UIVisualEffectView(effect: blue)
        
        maskView.frame = UIScreen.main.bounds
        let tap = UITapGestureRecognizer(target: self, action: #selector(CategoryMenuPresentationController.dismissPresentedViewController))
        maskView.addGestureRecognizer(tap)
        return maskView
    }()
    
    func dismissPresentedViewController() {
        
        NotificationCenter.default.post(name: .newScoreGroupViewControllerDidDismissNotification, object: nil)
        presentedViewController.dismiss(animated: true, completion: nil)
        
    }
    
}

