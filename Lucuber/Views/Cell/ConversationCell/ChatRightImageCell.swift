//
//  ChatRightImageCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/8.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ChatRightImageCell: ChatRightBaseCell {
    
    lazy var messageImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = UIColor.rightBubbleTintColor()
        imageView.mask = self.messageImageMakeImageView
        return imageView
    }()
    
    lazy var messageImageMakeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: ""))
        return imageView
    }()
    
    lazy var borderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: ""))
        return imageView
    }()
    
    lazy var loadingProgressView: MessageLoadingProgressView = {
        let view = MessageLoadingProgressView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        view.isHidden = true
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    typealias MediaTapAction = () -> Void
    var mediaTapAction: MediaTapAction?
    
    func makeUI() {
        
        let fullWidth = UIScreen.main.bounds.width
        
        let halfAvatarSize = Config.chatCellAvatarSize() / 2
        
        avatarImageView.center = CGPoint(x: fullWidth - halfAvatarSize - Config.chatCellGapBetweenWallAndAvatar(), y: halfAvatarSize)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(messageImageView)
        contentView.addSubview(borderImageView)
        contentView.addSubview(loadingProgressView)
        
        UIView.performWithoutAnimation {
            [weak self] in
            self?.makeUI()
        }
        
        messageImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatRightImageCell.tapMediaAction))
        messageImageView.addGestureRecognizer(tap)
        
        prepareForMenuAction = {
            otherGestruesEnabled in
            tap.isEnabled = otherGestruesEnabled
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapMediaAction() {
        mediaTapAction?()
    }
    
    var loadingProgress: Double = 0 {
        willSet {
            
            if newValue == 1.0 {
                loadingProgressView.isHidden = true
            } else {
                loadingProgressView.progress = newValue
                loadingProgressView.isHidden = false
            }
        }
    }
    
    func loadingWithProgress(progress: Double, image: UIImage?) {
        
        if progress >= loadingProgress {
            
            if progress <= 1.0 {
                loadingProgress = progress
            }
            
            if let image = image {
                
                UIView.transition(with: self, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { [weak self] in
                    
                    self?.messageImageView.image = image
                    
                    }, completion: nil)
            }
        }
    }
    
    func configureWithMessage(message: Message, messageImagePreferredWidth: CGFloat, messageImagePreferredHeight: CGFloat, messageImagePreferredAspectRatio: CGFloat, mediaTapAction: MediaTapAction?, collectionView: UICollectionView, indexPath: NSIndexPath) {
        
        self.message = message
        self.user = message.creator
        
        self.mediaTapAction = mediaTapAction
        
        UIView.performWithoutAnimation { [weak self] in
            self?.makeUI()
        }
        
//        if let sender = message.creatUser {
//            let userAvatar = UserAvatar(userID: sender.userID, avatarURLString: sender.avatarURLString, avatarStyle: nanoAvatarStyle)
//            avatarImageView.navi_setAvatar(userAvatar, withFadeTransitionDuration: avatarFadeTransitionDuration)
//        }
        
        loadingProgress = 0
        
        if let (imageWidth, imageHeight) = imageMetaOfMessage(message: message) {
            
            let aspectRatio = imageWidth / imageHeight
            
            let messageImagePreferredWidth = max(messageImagePreferredWidth, ceil(Config.ChatCell.mediaMinHeight * aspectRatio))
            let messageImagePreferredHeight = max(messageImagePreferredHeight, ceil(Config.ChatCell.mediaMinWidth / aspectRatio))
            
            if aspectRatio >= 1 {
                let width = min(messageImagePreferredWidth, Config.ChatCell.imageMaxWidth)
                
                UIView.performWithoutAnimation { [weak self] in
                    
                    if let strongSelf = self {
                        strongSelf.messageImageView.frame = CGRect(x: strongSelf.avatarImageView.frame.minX - Config.ChatCell.gapBetweenAvatarImageViewAndBubble - width, y: 0, width: width, height: strongSelf.bounds.height)
                        strongSelf.messageImageMakeImageView.frame = strongSelf.messageImageView.bounds
                        
                        strongSelf.dotImageView.center = CGPoint(x: strongSelf.messageImageView.frame.minX - Config.ChatCell.gapBetweenDotImageViewAndBubble, y: strongSelf.messageImageView.frame.midY)
                        
                        strongSelf.loadingProgressView.center = CGPoint(x: strongSelf.messageImageView.frame.midX + Config.ChatCell.playImageViewXOffset, y: strongSelf.messageImageView.frame.midY)
                        
                        strongSelf.borderImageView.frame = strongSelf.messageImageView.frame
                    }
                }
                
                var size = CGSize(width: messageImagePreferredWidth, height: ceil(messageImagePreferredWidth / aspectRatio))
                size = size.ensureMinWidthOrHeight(Config.ChatCell.mediaMinHeight)
                
//                messageImageView.yep_setImageOfMessage(message, withSize: size, tailDirection: .Right, completion: { loadingProgress, image in
//                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
//                        self?.loadingWithProgress(loadingProgress, image: image)
//                    }
//                })
                
            } else {
                let width = messageImagePreferredHeight * aspectRatio
                
                UIView.performWithoutAnimation { [weak self] in
                    
                    if let strongSelf = self {
                        strongSelf.messageImageView.frame = CGRect(x: strongSelf.avatarImageView.frame.minX - Config.ChatCell.gapBetweenAvatarImageViewAndBubble - width, y: 0, width: width, height: strongSelf.bounds.height)
                        strongSelf.messageImageMakeImageView.frame = strongSelf.messageImageView.bounds
                        
                        strongSelf.dotImageView.center = CGPoint(x: strongSelf.messageImageView.frame.minX - Config.ChatCell.gapBetweenDotImageViewAndBubble, y: strongSelf.messageImageView.frame.midY)
                        
                        strongSelf.loadingProgressView.center = CGPoint(x: strongSelf.messageImageView.frame.midX + Config.ChatCell.playImageViewXOffset, y: strongSelf.messageImageView.frame.midY)
                        
                        strongSelf.borderImageView.frame = strongSelf.messageImageView.frame
                    }
                }
                
                var size = CGSize(width: messageImagePreferredHeight * aspectRatio, height: messageImagePreferredHeight)
                size = size.ensureMinWidthOrHeight(Config.ChatCell.mediaMinHeight)
                
//                messageImageView.yep_setImageOfMessage(message, withSize: size, tailDirection: .Right, completion: { loadingProgress, image in
//                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
//                        self?.loadingWithProgress(loadingProgress, image: image)
//                    }
//                })
            }
            
        } else {
            let width = messageImagePreferredWidth
            
            UIView.performWithoutAnimation { [weak self] in
                
                if let strongSelf = self {
                    strongSelf.messageImageView.frame = CGRect(x: strongSelf.avatarImageView.frame.minX - Config.ChatCell.gapBetweenAvatarImageViewAndBubble - width, y: 0, width: width, height: strongSelf.bounds.height)
                    strongSelf.messageImageMakeImageView.frame = strongSelf.messageImageView.bounds
                    
                    strongSelf.dotImageView.center = CGPoint(x: strongSelf.messageImageView.frame.minX - Config.ChatCell.gapBetweenDotImageViewAndBubble, y: strongSelf.messageImageView.frame.midY)
                    
                    strongSelf.loadingProgressView.center = CGPoint(x: strongSelf.messageImageView.frame.midX + Config.ChatCell.playImageViewXOffset, y: strongSelf.messageImageView.frame.midY)
                    
                    strongSelf.borderImageView.frame = strongSelf.messageImageView.frame
                }
            }
            
            let size = CGSize(width: messageImagePreferredWidth, height: ceil(messageImagePreferredWidth / messageImagePreferredAspectRatio))
            
//            messageImageView.yep_setImageOfMessage(message, withSize: size, tailDirection: .Right, completion: { loadingProgress, image in
//                dispatch_async(dispatch_get_main_queue()) { [weak self] in
//                    self?.loadingWithProgress(loadingProgress, image: image)
//                }
//            })
        }
    }
    
}


















