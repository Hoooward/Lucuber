//
//  ChatLeftImageCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/7.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ChatLeftImageCell: ChatBaseCell {
    
    lazy var messageImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = UIColor.leftBubbleTintColor()
        imageView.mask = self.messageImageMaskImageView
        return imageView
    }()
    
    lazy var messageImageMaskImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "left_tail_image_bubble"))
        return imageView
    }()
    
    lazy var borderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "left_tail_image_bubble_border"))
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
        
        let haleAvatarSize = Config.chatCellAvatarSize()
        
        var topOffset: CGFloat = 0
        
        if inGroup {
            topOffset = Config.ChatCell.marginTopForGroup
        } else {
            topOffset = 0
        }
        
        avatarImageView.center = CGPoint(x: Config.chatCellGapBetweenWallAndAvatar() + haleAvatarSize , y: haleAvatarSize + topOffset)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(messageImageView)
        contentView.addSubview(borderImageView)
        contentView.addSubview(loadingProgressView)
        
        UIView.performWithoutAnimation { [weak self] in
            self?.makeUI()
        }
        
        messageImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatLeftImageCell.tapMediaAction))
        messageImageView.addGestureRecognizer(tap)
        
        prepareForMenuAction = {
            otherGesturesEnabled in
            tap.isEnabled = otherGesturesEnabled
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapMediaAction() {
        mediaTapAction?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageImageView.image = nil
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
    
    func loading(with progress: Double, image: UIImage?) {
        
        if progress >= loadingProgress{
            
            if loadingProgress == 1.0 {
                if progress < 1.0 {
                    return
                }
            }
            
            if progress <= 1.0 {
                loadingProgress = progress
                
                if progress == 1 {
                    
                    if let image = image {
                        self.messageImageView.image = image
                    }
                    return
                }
            }
            
            if let image = image {
                
                UIView.transition(with: self, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    [weak self] in
                    self?.messageImageView.image = image
                    
                    
                    }, completion: nil)
            }
        }
    }
    
    func configureWithMessage(message: Message, messageImagePreferredWidth: CGFloat, messageImagePreferredHeight: CGFloat, messageImagePreferredAspectRatio: CGFloat, mediaTapAction: MediaTapAction?, collectionView: UICollectionView, indexPath: NSIndexPath) {
        
        self.user = message.creatUser
        
        self.mediaTapAction = mediaTapAction
        
        var topOffset: CGFloat = 0
        
        if inGroup {
            topOffset = Config.ChatCell.marginTopForGroup
        } else {
            topOffset = 0
        }
        
        UIView.performWithoutAnimation { [weak self] in
            self?.makeUI()
        }
        
//        if let sender = message.creatUser {
//            let userAvatar = UserAvatar(userID: sender.userID, avatarURLString: sender.avatarURLString, avatarStyle: nanoAvatarStyle)
//            avatarImageView.navi_setAvatar(userAvatar, withFadeTransitionDuration: avatarFadeTransitionDuration)
//        }
//
        loadingProgress = 0
        
        if let (imageWidth, imageHeight) = imageMetaOfMessage(message: message) {
            
            let aspectRatio = imageWidth / imageHeight
            
            let messageImagePreferredWidth = max(messageImagePreferredWidth, ceil(Config.ChatCell.mediaMinHeight * aspectRatio))
            let messageImagePreferredHeight = max(messageImagePreferredHeight, ceil(Config.ChatCell.mediaMinWidth / aspectRatio))
            
            if aspectRatio >= 1 {
                
                let width = min(messageImagePreferredWidth, Config.ChatCell.imageMaxWidth)
                
                UIView.performWithoutAnimation { [weak self] in
                    
                    if let strongSelf = self {
                        strongSelf.messageImageView.frame = CGRect(x: strongSelf.avatarImageView.frame.maxX + Config.ChatCell.gapBetweenAvatarImageViewAndBubble, y: topOffset, width: width, height: strongSelf.bounds.height - topOffset)
                        strongSelf.messageImageMaskImageView.frame = strongSelf.messageImageView.bounds
                        
                        
                        strongSelf.loadingProgressView.center = CGPoint(x: strongSelf.messageImageView.frame.midX + Config.ChatCell.playImageViewXOffset, y: strongSelf.messageImageView.frame.midY)
                        
                        strongSelf.borderImageView.frame = strongSelf.messageImageView.frame
                    }
                }
                
                var size = CGSize(width: messageImagePreferredWidth, height: ceil(messageImagePreferredWidth / aspectRatio))
                size = size.ensureMinWidthOrHeight(Config.ChatCell.mediaMinHeight)
//                
//                messageImageView.yep_setImageOfMessage(message, withSize: size, tailDirection: .Left, completion: { loadingProgress, image in
//                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
//                        self?.loadingWithProgress(loadingProgress, image: image)
//                    }
//                })
                
            } else {
                let width = messageImagePreferredHeight * aspectRatio
                
                UIView.performWithoutAnimation { [weak self] in
                    
                    if let strongSelf = self {
                        strongSelf.messageImageView.frame = CGRect(x: strongSelf.avatarImageView.frame.maxX + Config.ChatCell.gapBetweenAvatarImageViewAndBubble, y: topOffset, width: width, height: strongSelf.bounds.height - topOffset)
                        strongSelf.messageImageMaskImageView.frame = strongSelf.messageImageView.bounds
                        
                        strongSelf.loadingProgressView.center = CGPoint(x: strongSelf.messageImageView.frame.midX + Config.ChatCell.playImageViewXOffset, y: strongSelf.messageImageView.frame.midY)
                        
                        strongSelf.borderImageView.frame = strongSelf.messageImageView.frame
                    }
                }
                
                var size = CGSize(width: messageImagePreferredHeight * aspectRatio, height: messageImagePreferredHeight)
                size = size.ensureMinWidthOrHeight(Config.ChatCell.mediaMinHeight)
                
//                messageImageView.yep_setImageOfMessage(message, withSize: size, tailDirection: .Left, completion: { loadingProgress, image in
//                    dispatch_async(dispatch_get_main_queue()) { [weak self] in
//                        self?.loadingWithProgress(loadingProgress, image: image)
//                    }
//                })
            }
            
        } else {
            let width = messageImagePreferredWidth
            
            UIView.performWithoutAnimation { [weak self] in
                
                if let strongSelf = self {
                    strongSelf.messageImageView.frame = CGRect(x: strongSelf.avatarImageView.frame.maxX + Config.ChatCell.gapBetweenAvatarImageViewAndBubble, y: topOffset, width: width, height: strongSelf.bounds.height - topOffset)
                    strongSelf.messageImageMaskImageView.frame = strongSelf.messageImageView.bounds
                    
                    strongSelf.loadingProgressView.center = CGPoint(x: strongSelf.messageImageView.frame.midX + Config.ChatCell.playImageViewXOffset, y: strongSelf.messageImageView.frame.midY)
                    
                    strongSelf.borderImageView.frame = strongSelf.messageImageView.frame
                }
            }
            
            let size = CGSize(width: messageImagePreferredWidth, height: ceil(messageImagePreferredWidth / messageImagePreferredAspectRatio))
            
//            messageImageView.yep_setImageOfMessage(message, withSize: size, tailDirection: .Left, completion: { loadingProgress, image in
//                dispatch_async(dispatch_get_main_queue()) { [weak self] in
//                    self?.loadingWithProgress(loadingProgress, image: image)
//                }
//            })
        }
        
        configureNameLabel()
    }
    
    private func configureNameLabel() {
        
        if inGroup {
            nameLabel.text = user?.nickName
            
            let height = Config.ChatCell.nameLabelHeightForGroup
            let x = avatarImageView.frame.maxX + Config.chatCellGapBetweenTextContentLabelAndAvatar()
            let y = messageImageView.frame.origin.y - height
            let width = contentView.bounds.width - x - 10
            nameLabel.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
}





























