//
//  NewScoreGroupAnimator.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/26.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class NewScoreGroupAnimator: NSObject, UIViewControllerTransitioningDelegate {
    
    var isPresented = false
    var presentedFrame = CGRect.zero
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = NewScoreGroupPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.predentedFrame = presentedFrame
        return presentationController
    }
    
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresented = false
        return self
    }
    
}


extension NewScoreGroupAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
                return
        }
        
        if isPresented {
            
            let toView = toVC.view
            let scale = CGAffineTransform(scaleX: 0.3, y: 0.3)
            let translate = CGAffineTransform(translationX: 50, y: 0)
            toView?.transform = scale.concatenating(translate)
            toView?.alpha = 0
            toView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            transitionContext.containerView.addSubview(toView!)
            
            springWithCompletion(duration: 0.5, animations: {
                let scale = CGAffineTransform(translationX: 1, y: 1)
                let translate = CGAffineTransform(translationX: 0, y: 0)
                toView?.transform = scale.concatenating(translate)
                toView?.alpha = 1
            }, completions: { finished in
                transitionContext.completeTransition(finished)
            })
            
        } else {
            
            let fromView = fromVC.view
            //            fromView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            transitionContext.containerView.addSubview(fromView!)
            
            springWithCompletion(duration: 0.5, animations: {
                //                fromView.transform = CGAffineTransformMakeScale(1.0, 0.000000001)
                transitionContext.containerView.subviews.forEach {
                    view in view.alpha = 0 }
            }, completions: { finished in
                transitionContext.completeTransition(finished)
            })
            
            
        }
    }
}

