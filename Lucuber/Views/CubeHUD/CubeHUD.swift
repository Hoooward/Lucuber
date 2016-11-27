//
//  CubeHUD.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/22.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

public class CubeHUD: NSObject {
    
    // MARK: Properties
    
    static let shardInstance = CubeHUD()
    
    var isShowing = false
    var dismissTimer: Timer?
    
    private lazy var containerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
        
    }()
    
    private lazy var indicatorLabel: UILabel = {
        
        let label = UILabel()
        
        label.text = "正在加载..."
        return label
        
    }()
    
    
    var indicatorText: String = " " {
        willSet {
            indicatorLabel.text = newValue
        }
    }
    
    private lazy var activitIndicator: UIActivityIndicatorView = {
        
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        
        return view
        
    }()
    
    // MARK: Action & Target
    
    class func showActivityIndicator() {
        
        showActivityIndicatorWhile(blockingUI: true)
    }
    
    class func showActivityIndicatorWhile(blockingUI: Bool = false) {
        
        if self.shardInstance.isShowing {
            return
        }
        
        DispatchQueue.main.async {
            
            if
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let window = appDelegate.window {
                
                self.shardInstance.isShowing = true
                self.shardInstance.containerView.isUserInteractionEnabled = blockingUI
                
                self.shardInstance.containerView.alpha = 0
                window.addSubview(self.shardInstance.containerView)
                self.shardInstance.containerView.frame = window.bounds
                
                springWithCompletion(duration: 0.1, animations: {
                    
                    self.shardInstance.containerView.alpha = 1
                    
                    }, completions: { finished in
                        
                        self.shardInstance.containerView.addSubview(self.shardInstance.activitIndicator)
                        self.shardInstance.activitIndicator.center = self.shardInstance.containerView.center
//                        self.shardInstance.containerView.addSubview(self.shardInstance.indicatorLabel)
                        self.shardInstance.indicatorLabel.center = CGPoint(x: self.shardInstance.containerView.center.x, y: self.shardInstance.containerView.center.y + 25)
                        self.shardInstance.activitIndicator.startAnimating()
                        
                        self.shardInstance.activitIndicator.alpha = 0
                        self.shardInstance.indicatorLabel.alpha = 0
                        self.shardInstance.activitIndicator.transform = CGAffineTransform.init(scaleX: 0.00001, y: 0.00001)
                        
                        self.shardInstance.indicatorLabel.transform = CGAffineTransform.init(scaleX: 0.00001, y: 0.00001)
                        
                        springWithCompletion(duration: 0.2, animations: {
                            
                            self.shardInstance.activitIndicator.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                            self.shardInstance.activitIndicator.alpha = 1
                            
                            self.shardInstance.indicatorLabel.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                            self.shardInstance.indicatorLabel.alpha = 1
                            
                            }, completions: { finished in
                                
                                self.shardInstance.activitIndicator.transform = CGAffineTransform.identity
                                
                                self.shardInstance.indicatorLabel.transform = CGAffineTransform.identity
                                
                                if let dismissTimer = self.shardInstance.dismissTimer {
                                    
                                    dismissTimer.invalidate()
                                }
                                
                                self.shardInstance.dismissTimer = Timer(timeInterval: Config.forcedHideActivityIndicatorTimeInterval, target: self, selector: #selector(CubeHUD.forcedHideActivityIndicator), userInfo: nil, repeats: false)
                        })
                        
                })
                
            }
        }
        
    }
    
    class func forcedHideActivityIndicator() {
        
        hideActivityIndicator {
            
            if
                let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let _ = appDelegate.window?.rootViewController {
                
                // TODO: Alert 超时提醒
            }
        }
        
    }
    
    class func hideActivityIndicator() {
        
        hideActivityIndicator {
            
        }
    }
    
    class func hideActivityIndicator(completion: @escaping () -> Void ){
        
        DispatchQueue.main.async {
            
            if self.shardInstance.isShowing {
                
                self.shardInstance.isShowing = false
                
                self.shardInstance.activitIndicator.transform = CGAffineTransform.identity
                self.shardInstance.indicatorLabel.transform = CGAffineTransform.identity
                
                springWithCompletion(duration: 0.5, animations: {
                    
                    self.shardInstance.activitIndicator.transform = CGAffineTransform.init(scaleX: 0.00001, y: 0.00001)
                    self.shardInstance.activitIndicator.alpha = 0
                    
                    
                    self.shardInstance.indicatorLabel.transform = CGAffineTransform.init(scaleX: 0.00001, y: 0.00001)
                    self.shardInstance.indicatorLabel.alpha = 0
                    
                    }, completions: { finished in
                        
                        self.shardInstance.activitIndicator.removeFromSuperview()
                        self.shardInstance.indicatorLabel.removeFromSuperview()
                        
                        springWithCompletion(duration: 0.1, animations: {
                            
                            self.shardInstance.containerView.alpha = 0
                            
                            }, completions: { finished in
                                
                                self.shardInstance.containerView.removeFromSuperview()
                                
                                completion()
                                
                        })
                })
            }
        }
    }
    
    
}

































































