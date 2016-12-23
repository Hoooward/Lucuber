//
//  SearchTransition.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/23.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

final class SearchTransition: NSObject {
    
    var isPresentation = true
}

extension SearchTransition: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            if (fromVC is SearchTrigeer) && (toVC is SearchAction) {
                isPresentation = true
                return self
            }
        } else if operation == .pop {
            if (fromVC is SearchAction) && (toVC is SearchTrigeer) {
                isPresentation = false
                return self
            }
        }
        return nil
    }
}

extension SearchTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        if isPresentation {
            return 0.25
        } else {
            return 0.45
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if isPresentation {
            
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let containerView = transitionContext.containerView
            
            containerView.addSubview(toView)
            
            toView.alpha = 0
            
            let fullDuration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: fullDuration, delay: 0.0, options: [.curveEaseInOut, .layoutSubviews], animations: { _ in
                
                toView.alpha = 1
                
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
            
        } else {
            
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
            let searchAction = fromVC as! SearchAction
            
            let containerView = transitionContext.containerView
            
            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
            
            
            fromView.alpha = 1
            searchAction.searchBar.setShowsCancelButton(false, animated: true)
            
            let fullDuration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: fullDuration * 0.6, delay: 0.0, options: [ .curveEaseInOut
                ], animations: { _ in
                    
                    searchAction.searchBarTopConstraint.constant = 64
                    fromVC.view.layoutIfNeeded()
                    
            }, completion: { finished in
                
                UIView.animate(withDuration: fullDuration * 0.4, delay: 0.0, options: [.curveEaseInOut], animations: { _ in
                    
                    fromView.alpha = 0
                    
                }, completion: { finished in
                    transitionContext.completeTransition(true)
                    
                })
            })
        }
        
    }
}








