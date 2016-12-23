//
//  TimerControl.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/23.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

public class TimerControlView: UIView {
    
    let screenWidth = UIScreen.main.bounds.width
    public enum Statue {
        case prepare
        case readyStart
        case start
    }
    
    public var status: Statue = .prepare {
        didSet {
            
            switch status {
                
            case .prepare :
                
                UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.prepareStartIndicatorLabel.alpha = 1
                    self.prepareStartIndicatorLabel.transform = CGAffineTransform.identity
                }, completion: nil)
                
                readyStartIndicatorLabel.transform = CGAffineTransform.identity
                
                break
                
            case .readyStart:
                
                UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.prepareStartIndicatorLabel.transform = self.prepareStartIndicatorLabel.transform.translatedBy(x: self.screenWidth, y: 0)
                    self.prepareStartIndicatorLabel.alpha = 0
                    self.readyStartIndicatorLabel.transform = self.readyStartIndicatorLabel.transform.translatedBy(x: self.screenWidth, y: 0)
                    self.readyStartIndicatorLabel.alpha = 1
                    
                    
                }, completion: nil)
                
            case .start:
                
                UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveEaseInOut, animations: {
                   self.readyStartIndicatorLabel.transform = self.readyStartIndicatorLabel.transform.translatedBy(x: self.screenWidth, y: 0)
                    self.readyStartIndicatorLabel.alpha = 0
                }, completion: { _ in
                    
                })
                self.prepareStartIndicatorLabel.alpha = 0
                self.readyStartIndicatorLabel.alpha = 0
                
                self.prepareStartIndicatorLabel.transform = CGAffineTransform.identity
                self.prepareStartIndicatorLabel.transform = self.prepareStartIndicatorLabel.transform.translatedBy(x: -self.screenWidth, y: 0)
                
            }
        }
    }
    
    private lazy var prepareStartIndicatorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "长按屏幕 准备开始"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var readyStartIndicatorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "松开手指 开始计时"
        label.textAlignment = .center
        return label
    }()
    
    override public func awakeFromNib() {
        addSubview(prepareStartIndicatorLabel)
        addSubview(readyStartIndicatorLabel)
        prepareStartIndicatorLabel.frame = bounds
        
        readyStartIndicatorLabel.frame = CGRect(x: -bounds.size.width, y: 0, width: bounds.size.width, height: bounds.size.height)
        
        status = .prepare
    }
    
}
















