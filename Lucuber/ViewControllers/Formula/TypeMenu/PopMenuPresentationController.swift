//
//  PopMenuPresentationController.swift
//  Lucuber
//
//  Created by Howard on 16/6/30.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class PopMenuPresentationController: UIPresentationController {
    /// 设置presentedView的frame
    var presentedFrame = CGRectZero
    
    override func containerViewWillLayoutSubviews() {
        if presentedFrame == CGRectZero {
            presentedView()?.frame = CGRect(x: screenWidth - 150 - 10, y: 60, width: 150, height: 250)
        } else {
            presentedView()?.frame = presentedFrame
        }
        containerView?.insertSubview(maskBackgroundView, atIndex: 0)
    }
    
    private lazy var maskBackgroundView: UIView = {
        let maskView = UIView()
        maskView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        maskView.frame = screenBounds
        let tap = UITapGestureRecognizer(target: self, action: #selector(PopMenuPresentationController.dismissPresentedViewController))
        maskView.addGestureRecognizer(tap)
        return maskView
    }()

    func dismissPresentedViewController() {
        presentedViewController.dismissViewControllerAnimated(true, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName( FormulaTypePopMenuDismissNotification, object: nil)
    }
}
