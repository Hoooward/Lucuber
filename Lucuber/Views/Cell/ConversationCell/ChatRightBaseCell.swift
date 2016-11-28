//
//  ChatRightBaseCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/7.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit


let sendingAnimationName = "RotationOnStateAnimation"

class ChatRightBaseCell: ChatBaseCell {
    
    lazy var dotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 15, y: 0, width: 26, height: 26)
        imageView.image = UIImage(named: "icon_dot_sending")
        imageView.contentMode = .center
        return imageView
        
    }()
    
    override var inGroup: Bool {
        willSet {
            dotImageView.isHidden = newValue ? true : false
        }
    }
    
    var messageSendState: MessageSendState = .notSend {
        
        didSet {
            
            switch messageSendState {
            case .notSend:
                
                dotImageView.image = UIImage(named: "icon_dot_sending")
                dotImageView.isHidden = false
                
                delay(0.1) { [weak self] in
                    
                    if let messageSendState = self?.messageSendState, messageSendState == .notSend {
                        self?.showSendingAnimation()
                    }
                }
                
            case .successed:
//                dotImageView.image = UIImage(named: "icon_dot_unread")
//                dotImageView.isHidden = false
                
                dotImageView.isHidden = true
                removeSendingAnimation()
                
            case .read:
                dotImageView.isHidden = true
                removeSendingAnimation()
                
            case .failed:
                dotImageView.image = UIImage(named: "icon_dot_failed")
                dotImageView.isHidden = false
                
                removeSendingAnimation()
            }
        }
    }
    
    var message: Message? {
        didSet {
            
            tryUpdateMessageState()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(dotImageView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatRightBaseCell.tryUpdateMessageState), name:Notification.Name.updateMessageStatesNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tryUpdateMessageState() {
        
        guard !inGroup else {
            return
        }
        
        if let message = message {
            if !message.invalidate {
                if let messageSendState = MessageSendState(rawValue: message.sendStateInt) {
                    self.messageSendState = messageSendState
                }
            }
        }
        
    }
    
    func showSendingAnimation() {
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = 2 * M_PI
        animation.duration = 1.0
        animation.repeatCount = MAXFLOAT
        
        DispatchQueue.main.async { [weak self] in
            self?.dotImageView.layer.add(animation, forKey: sendingAnimationName)
        }
    }
    
    func removeSendingAnimation() {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.dotImageView.layer.removeAnimation(forKey: sendingAnimationName)
        }
    }
    
    
    
}















