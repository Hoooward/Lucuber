//
//  PopMenuAnimator.swift
//  Lucuber
//
//  Created by Howard on 16/6/30.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class PopMenuAnimator: NSObject, UIViewControllerTransitioningDelegate {
    
    var isPresented = false
    var presentedFrmae = CGRectZero
    
    
    /**
     设置PresentationController,这个Controller专门控制转场细节
     - parameter presented:  被展现的视图
     - parameter presenting: 发起的视图
     - parameter source:
     - returns: 返回一个控制转场的控制器
     */
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        let presentationController = PopMenuPresentationController(presentedViewController: presented, presentingViewController: presenting)
        presentationController.presentedFrame = presentedFrmae
        return presentationController
    }
    
    /**
     由自己来实现转场中的动画,实现此方法,实现之后系统默认的动画就不存在了
     - parameter presented:  被展示的视图
     - parameter presenting: 发起展示的视图
     - returns: 谁来控制转场动画 , 需要遵循 UIViewControllerAnimatedTransitioning 协议
     */
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = true
        return self
    }
    
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        return self
    }
    
}

extension PopMenuAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey), fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
            print("转场视图准备失败")
            return
        }
        
        if isPresented {
            
            let toView = toVC.view
            let scale = CGAffineTransformMakeScale(0.3, 0.3)
            let translate = CGAffineTransformMakeTranslation(50, 0)
            toView.transform = CGAffineTransformConcat(scale, translate)
            toView.alpha = 0
            toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            transitionContext.containerView()?.addSubview(toView)
            
            springWithCompletion(0.5, animations: {
                let scale = CGAffineTransformMakeTranslation(1, 1)
                let translate = CGAffineTransformMakeTranslation(0, 0)
                toView.transform = CGAffineTransformConcat(scale, translate)
                toView.alpha = 1
                }, completions: { finished in
                    transitionContext.completeTransition(finished)
            })
            
            
        } else {
            let fromView = fromVC.view
//            fromView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            transitionContext.containerView()?.addSubview(fromView)
            
            springWithCompletion(0.5, animations: { 
//                fromView.transform = CGAffineTransformMakeScale(1.0, 0.000000001)
                transitionContext.containerView()?.subviews.forEach {
                    view in view.alpha = 0 }
                }, completions: { finished in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}











