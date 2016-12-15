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
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var messageImageMakeImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "right_tail_image_bubble"))
        return imageView
    }()
    
    lazy var borderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "right_tail_image_bubble_border"))
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
        
        UIView.setAnimationsEnabled(false); do{
            makeUI()
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageImageView.image = nil
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
                
                if progress == 1.0 {
                    if let image = image {
                        self.messageImageView.image = image
                    }
                    return
                }
            }
            
            if let image = image {
                
                UIView.transition(with: self, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { [weak self] in
                    
                    self?.messageImageView.image = image
                    
                    }, completion: nil)
            }
        }
    }
    
    func configureWithMessage(message: Message, messageImagePreferredWidth: CGFloat, messageImagePreferredHeight: CGFloat, messageImagePreferredAspectRatio: CGFloat, mediaTapAction: MediaTapAction?, collectionView: UICollectionView, indexPath: IndexPath) {
        
        self.message = message
        self.user = message.creator
        
        self.mediaTapAction = mediaTapAction
        
        UIView.setAnimationsEnabled(false); do {
            makeUI()
        }

        UIView.setAnimationsEnabled(true)
        if let url = message.creator?.avatorImageURL {
            
            let cubeAvatar = CubeAvatar(avatarUrlString: url, avatarStyle: nanoAvatarStyle)
            avatarImageView.navi_setAvatar(cubeAvatar, withFadeTransitionDuration: 0.5)
            
        } else {
            avatarImageView.image = #imageLiteral(resourceName: "default_avatar_60")
        }
        
        loadingProgress = 0
        
        let imageSize = message.fixedImageSize
        
        messageImageView.cube_setImage(with: message, size: imageSize, direction: MessageImageBubbleDirection.right, completion: { progress, image in
            self.loadingWithProgress(progress: progress, image: image)
        })
        
        UIView.setAnimationsEnabled(false); do {
            let width = min(imageSize.width, Config.ChatCell.imageMaxWidth)
            
            messageImageView.frame = CGRect(x: (avatarImageView.frame).minX - Config.ChatCell.gapBetweenAvatarImageViewAndBubble - width, y: 0, width: width, height: bounds.height)
            messageImageMakeImageView.frame = messageImageView.bounds
            
            dotImageView.center = CGPoint(x: messageImageView.frame.minX - Config.ChatCell.gapBetweenDotImageViewAndBubble, y: messageImageView.frame.midY)
            
            loadingProgressView.center = CGPoint(x: messageImageView.frame.midX + Config.ChatCell.playImageViewXOffset, y: messageImageView.frame.midY)
            
            borderImageView.frame = messageImageView.frame
        }
        UIView.setAnimationsEnabled(true)
    }
        
    
}


















