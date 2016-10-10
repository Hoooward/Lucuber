//
//  ChatRightTextCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/7.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ChatRightTextCell: ChatRightBaseCell {
    
    var tapUsernameAction: ((_ username: String) -> Void)?
    var tapFeedAction: ((_ feed: Any) -> Void)?
    
    lazy var bubbleTailImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bubble_right_tail"))
        imageView.tintColor = UIColor.rightBubbleTintColor()
        return imageView
    }()
    
    lazy var bubbleBodyShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.rightBubbleTintColor().cgColor
        layer.fillColor = UIColor.rightBubbleTintColor().cgColor
        return layer
    }()
    
    lazy var textContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var textContentTextView: ChatTextView = {
        let view = ChatTextView()
        
        view.textContainer.lineFragmentPadding = 0
        view.font = UIFont.chatTextFont()
        view.backgroundColor = UIColor.clear
        view.textColor = UIColor.white
        view.tintColor = UIColor.white
        view.linkTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSUnderlineStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue),
        ]
        
        view.tapMentionAction = { [weak self] username in
            self?.tapUsernameAction?(username)
        }
        
        view.tapFeedAction = { [weak self] feed in
            self?.tapFeedAction?(feed: feed)
        }
        
        return view
    }()
    
    var bottomGap: CGFloat = 0
    
    typealias MediaTapAction = () -> Void
    var mediaTapAction: MediaTapAction?
    
    func makeUI() {
        
        let fullWidth = UIScreen.main.bounds.width
        
        let halfAvatarSize = Config.chatCellAvatarSize() / 2
        
        avatarImageView.center = CGPoint(x: fullWidth - halfAvatarSize - Config.chatCellGapBetweenWallAndAvatar(), y: halfAvatarSize)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bubbleTailImageView)
        contentView.addSubview(textContainerView)
        textContainerView.addSubview(textContentTextView)
        
        if let bubblePosition = layer.sublayers {
            contentView.layer.insertSublayer(bubbleBodyShapeLayer, at: UInt32(bubblePosition.count))
        }
        
        UIView.performWithoutAnimation { [weak self] in
            self?.makeUI()
        }
        
        textContainerView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatRightTextCell.tapMediaView))
        textContainerView.addGestureRecognizer(tap)
        
        prepareForMenuAction = { otherGesturesEnabled in
            tap.isEnabled = otherGesturesEnabled
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapMediaView() {
        mediaTapAction?()
    }
    
    
    func configureWithMessage(message: Message, textContentLabelWidth: CGFloat, mediaTapAction: MediaTapAction?, collectionView: UICollectionView, indexPath: NSIndexPath) {
        
        self.message = message
        self.user = message.creatUser
        
        self.nameLabel.text = "Tychooo"
        
        self.avatarImageView.image = UIImage(named: "Howard")
        
        self.mediaTapAction = mediaTapAction
        
        textContentTextView.text = message.textContent
        //textContentTextView.attributedText = NSAttributedString(string: message.textContent, attributes: textAttributes)
        
        //textContentTextView.textAlignment = textContentLabelWidth < YepConfig.minMessageTextLabelWidth ? .Center : .Left
        
        // 用 sizeThatFits 来对比，不需要 magicWidth 的时候就可以避免了
        var textContentLabelWidth = textContentLabelWidth
        let size = textContentTextView.sizeThatFits(CGSize(width: textContentLabelWidth, height: CGFloat.greatestFiniteMagnitude))
        
        // lineHeight 19.088, size.height 35.5 (1 line) 54.5 (2 lines)
        textContentTextView.textAlignment = ((size.height - textContentTextView.font!.lineHeight) < 20) ? .center : .left
        
        if ceil(size.width) != textContentLabelWidth {
            
            //println("right ceil(size.width): \(ceil(size.width)), textContentLabelWidth: \(textContentLabelWidth)")
            //println(">>>\(message.textContent)<<<")
            
            //textContentLabelWidth += YepConfig.ChatCell.magicWidth
            
            if abs(ceil(size.width) - textContentLabelWidth) >= Config.ChatCell.magicWidth {
                textContentLabelWidth += Config.ChatCell.magicWidth
            }
        }
        
        textContentLabelWidth = max(textContentLabelWidth, Config.ChatCell.minTextWidth)
        
        UIView.performWithoutAnimation { [weak self] in
            
            if let strongSelf = self {
                
                strongSelf.makeUI()
                
                strongSelf.textContainerView.frame = CGRect(x: strongSelf.avatarImageView.frame.minX - Config.chatCellGapBetweenTextContentLabelAndAvatar() - textContentLabelWidth, y: 3, width: textContentLabelWidth, height: strongSelf.bounds.height - 3 * 2 - strongSelf.bottomGap)
                
                strongSelf.textContentTextView.frame = strongSelf.textContainerView.bounds
                
                let bubbleBodyFrame = strongSelf.textContainerView.frame.insetBy(dx: -12, dy: -3)
                
                strongSelf.bubbleBodyShapeLayer.path = UIBezierPath(roundedRect: bubbleBodyFrame, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: Config.ChatCell.bubbleCornerRadius, height: Config.ChatCell.bubbleCornerRadius)).cgPath
                
                strongSelf.bubbleTailImageView.center = CGPoint(x: bubbleBodyFrame.maxX, y: strongSelf.avatarImageView.frame.midY)
                
                strongSelf.dotImageView.center = CGPoint(x: bubbleBodyFrame.minX - Config.ChatCell.gapBetweenDotImageViewAndBubble, y: strongSelf.textContainerView.frame.midY)
            }
        }
        
        // TODO: 设置图片
        
//        if let sender = message.fromFriend {
//            let userAvatar = UserAvatar(userID: sender.userID, avatarURLString: sender.avatarURLString, avatarStyle: nanoAvatarStyle)
//            avatarImageView.navi_setAvatar(userAvatar, withFadeTransitionDuration: avatarFadeTransitionDuration)
//        }
    }
}





















