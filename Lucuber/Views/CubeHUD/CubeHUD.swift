//
//  CubeHUD.swift
//  Lucuber
//
//  Created by Howard on 7/15/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit


final class CubeHUD: NSObject {
    
    static let sharedInstance = CubeHUD()
    
    var isShowing = false
    var dismissTimer: NSTimer?
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        return view
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        return view
    }()
    
    class func showActivityIndicator() {
        showActivityIndicatorWhileBlockingUI(false)
    }
    
    class func showActivityIndicatorWhileBlockingUI(blockingUI: Bool) {
        
        if self.sharedInstance.isShowing {
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            if
                let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
                let windows = appDelegate.window {
                    self.sharedInstance.isShowing = true
                    self.sharedInstance.containerView.userInteractionEnabled = blockingUI
                
                self.sharedInstance.containerView.alpha = 0
                windows.addSubview(self.sharedInstance.containerView)
                self.sharedInstance.containerView.frame = windows.bounds
                
                springWithCompletion(0.1, animations: {
                        self.sharedInstance.containerView.alpha = 1
                    }, completions: {
                        finished in
                        self.sharedInstance.containerView.addSubview(self.sharedInstance.activityIndicator)
                        self.sharedInstance.activityIndicator.center = self.sharedInstance.containerView.center
                        self.sharedInstance.activityIndicator.startAnimating()
                        
                        self.sharedInstance.activityIndicator.alpha = 0
                        self.sharedInstance.activityIndicator.transform = CGAffineTransformMakeScale(0.00001, 0.00001)
                        springWithCompletion(0.2, animations: {
                            self.sharedInstance.activityIndicator.transform = CGAffineTransformMakeScale(1.0, 1.0)
                            self.sharedInstance.activityIndicator.alpha = 1
                            }, completions: {
                            finished in
                                self.sharedInstance.activityIndicator.transform = CGAffineTransformIdentity
                                
                                if let dismissTimer = self.sharedInstance.dismissTimer {
                                    dismissTimer.invalidate()
                                }
                            
                                self.sharedInstance.dismissTimer = NSTimer(timeInterval: CubeConfig.forcedHideActivityIndicatorTimeInterval, target: self, selector: #selector(CubeHUD.forcedHideActivityIndicator), userInfo: nil, repeats: false)
                            
                        })
                })
                
            }
        }
    }
    
    class func forcedHideActivityIndicator() {
        hideActivityIndicator() {
            if
                let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
                let _ = appDelegate.window?.rootViewController {
                //TODO: Alert 超时提醒
            }
        }
    }
    
    class func hideActivityIndicator() {
        hideActivityIndicator(){}
    }
    
    
    class func hideActivityIndicator(completion: ()->Void) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            if self.sharedInstance.isShowing {
                    self.sharedInstance.activityIndicator.transform = CGAffineTransformIdentity
                springWithCompletion(0.2, animations: {
                    
                    self.sharedInstance.activityIndicator.transform = CGAffineTransformMakeScale(0.00001, 0.0001)
                    self.sharedInstance.activityIndicator.alpha = 0
                    }, completions: {
                        finished in
                        self.sharedInstance.activityIndicator.removeFromSuperview()
                        
                        springWithCompletion(0.1, animations: {
                            self.sharedInstance.containerView.alpha = 0
                            }, completions: {
                                finished in
                                self.sharedInstance.containerView.removeFromSuperview()
                                completion()
                        })
                        
                })
            }
        }
    }
}

