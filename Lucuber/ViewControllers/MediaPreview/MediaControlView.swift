//
//  MediaControlView.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class MediaControlView: UIView {
    
    public enum MediaType {
        case image
        case video
    }
    
    var type: MediaType = .video {
        didSet {
            if type == oldValue {
                return
            }
            
            switch type {
                
            case .image:
                timeLabel.isHidden = true
                playButton.isHidden = true
                
            case .video:
                timeLabel.isHidden = false
                playButton.isHidden = false
                
            }
            
        }
    }
    
    enum PlayState {
        case playing
        case pause
    }
    
    var playState: PlayState = .pause {
        didSet {
            
            switch playState {
                
            case .pause:
                playButton.setImage(UIImage(named: "icon_play"), for: .normal)
                
            case .playing:
                playButton.setImage(UIImage(named: "icon_pause"), for: .normal)
                
            }
        }
    }
    
    var playAction: ((MediaControlView) -> Void)?
    var pauseAction: ((MediaControlView) -> Void)?
    
    var shareAction: (() -> Void)?
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        label.textColor = UIColor.white
        label.text = "00:42"
        return label
    }()
    
    lazy var playButton: UIButton = {
        
        let button = UIButton()
        button.setImage(UIImage(named: "icon_play"), for: .normal)
        button.tintColor = UIColor.white
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        button.addTarget(self, action: #selector(MediaControlView.playOrPasue), for: .touchUpInside)
        return button
        
    }()
    
    lazy var shareButton: UIButton = {
        
        let button = UIButton()
        button.setImage(UIImage(named: "icon_more"), for: .normal)
        button.tintColor = UIColor.white
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        button.addTarget(self, action: #selector(MediaControlView.share), for: .touchUpInside)
        return button
        
    }()
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        backgroundColor = UIColor.clear
        
        makeUI()
    }
    
    private func makeUI() {
        
        addSubview(timeLabel)
        addSubview(playButton)
        addSubview(shareButton)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsDictionary: [String: AnyObject] = [
            "timeLable": timeLabel,
            "playButton": playButton,
            "shareButton": shareButton
        ]
        
        let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|[timeLable]|", options: [], metrics: nil, views: viewsDictionary)
        let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-30-[timeLable]-(>=0)-[playButton]-(>=0)-[shareButton]-30-|", options: [.alignAllCenterY, .alignAllTop, .alignAllBottom], metrics: nil, views: viewsDictionary)
        
        NSLayoutConstraint.activate(constraintsV)
        NSLayoutConstraint.activate(constraintsH)
        
        let playButtonConstraintCenterX = NSLayoutConstraint(item: playButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([playButtonConstraintCenterX])
    }
    
    
    // MARK: - Target & Notifation
    func playOrPasue() {
        
        switch playState {
        case .playing:
            if let action = pauseAction {
                action(self)
            }
        case .pause:
            if let action = playAction {
                action(self)
            }
        }
        
    }
    
    func share() {
        if let action = shareAction {
            action()
        }
    }
    
    //    override func drawRect(rect: CGRect) {
    //
    //        let startColor = UIColor.clearColor()
    //        let endColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
    //
    //        let context = UIGraphicsGetCurrentContext()
    //        let colors = [startColor.CGColor, endColor.CGColor]
    //
    //        let colorSpace = CGColorSpaceCreateDeviceRGB()
    //
    //        let colorLocations: [CGFloat] = [0.0, 1.0]
    //
    //        let gradient = CGGradientCreateWithColors(colorSpace, colors, colorLocations)
    //
    //        let startPoint = CGPointZero
    //        let endPoint = CGPoint(x: 0, y: rect.height)
    //
    //        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions.init(rawValue: 0))
    //    }
    
}







