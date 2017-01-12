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
        imageView.clipsToBounds = true
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
        
        let halfAvatarSize = Config.chatCellAvatarSize() / 2
        
        var topOffset: CGFloat = 0
        
        if inGroup {
            topOffset = Config.ChatCell.marginTopForGroup
        } else {
            topOffset = 0
        }
        
        avatarImageView.center = CGPoint(x: Config.chatCellGapBetweenWallAndAvatar() + halfAvatarSize , y: halfAvatarSize + topOffset)
        
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
    
    func configureWithMessage(_ message: Message, messageImagePreferredWidth: CGFloat, messageImagePreferredHeight: CGFloat, messageImagePreferredAspectRatio: CGFloat, mediaTapAction: MediaTapAction?, collectionView: UICollectionView, indexPath: IndexPath) {
        
        self.user = message.creator
        
        self.mediaTapAction = mediaTapAction
        
        var topOffset: CGFloat = 0
        
        if inGroup {
            topOffset = Config.ChatCell.marginTopForGroup
        } else {
            topOffset = 0
        }
        
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
        
        messageImageView.cube_setImage(with: message, size: imageSize, direction: MessageImageBubbleDirection.left, completion: { progress, image in
            self.loading(with: progress, image: image)
        })
        
        UIView.setAnimationsEnabled(false); do {
            let width = min(imageSize.width, Config.ChatCell.imageMaxWidth)
            
            messageImageView.frame = CGRect(x: avatarImageView.frame.maxX + Config.ChatCell.gapBetweenAvatarImageViewAndBubble, y: topOffset, width: width, height: bounds.height - topOffset)
            messageImageMaskImageView.frame = messageImageView.bounds
            
            loadingProgressView.center = CGPoint(x: messageImageView.frame.midX + Config.ChatCell.playImageViewXOffset, y: messageImageView.frame.midY)
            
            borderImageView.frame = messageImageView.frame
        }
        UIView.setAnimationsEnabled(true)
        
       
        
        configureNameLabel()
    }
    
    private func configureNameLabel() {
        
        if inGroup {
            nameLabel.text = user?.nickname
            
            UIView.setAnimationsEnabled(false); do {
                let height = Config.ChatCell.nameLabelHeightForGroup
                let x = avatarImageView.frame.maxX + Config.chatCellGapBetweenTextContentLabelAndAvatar()
                let y = messageImageView.frame.origin.y - height
                let width = contentView.bounds.width - x - 10
                nameLabel.frame = CGRect(x: x, y: y, width: width, height: height)
            }
            
            UIView.setAnimationsEnabled(true)
        }
    }
    
}





























