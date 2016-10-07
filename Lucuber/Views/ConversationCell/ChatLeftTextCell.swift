//
//  ChatLeftTextCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/7.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ChatLeftTextCell: ChatBaseCell {
    
    var tapUsernameAction: ((_ username: String) -> Void)?
    var tapFeedAction: ((_ feed: Any) -> Void)?
    
    lazy var bubbleTailImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bubble_left_tail"))
        imageView.tintColor = UIColor.leftBubbleTintColor()
        return imageView
    }()
    
    lazy var bubbleBodyShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.leftBubbleTintColor().cgColor
        layer.fillColor = UIColor.leftBubbleTintColor().cgColor
        return layer
    }()
    
    lazy var textContentTextView: ChatTextView = {
        let view = ChatTextView()
        
        view.textContainer.lineFragmentPadding = 0
        view.font = UIFont.chatTextFont()
        view.backgroundColor = UIColor.clear
        view.textColor = UIColor.black
        view.tintColor = UIColor.black
        view.linkTextAttributes = [
            NSForegroundColorAttributeName: UIColor.cubeTintColor(),
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
    
    func makeUI() {
        
        let halfAvatarSize = Config.chatCellAvatarSize() / 2
        
        var topOffset: CGFloat = 0
        
        if inGroup {
            topOffset = Config.ChatCell.marginTopForGroup
        } else {
            topOffset = 0
        }
        
        avatarImageView.center = CGPoint(x: Config.chatCellGapBetweenWallAndAvatar() + halfAvatarSize, y: halfAvatarSize + topOffset)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bubbleTailImageView)
        contentView.addSubview(textContentTextView)
        
        UIView.performWithoutAnimation { [weak self] in
            self?.makeUI()
        }
        
        if let bubblePosition = layer.sublayers {
            contentView.layer.insertSublayer(bubbleBodyShapeLayer, at: UInt32(bubblePosition.count))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureWithMessage(message: Message, textContentLabelWidth: CGFloat, collectionView: UICollectionView, indexPath: NSIndexPath) {
        
        self.user = message.creatUser
        
        textContentTextView.text = message.textContent
        
        //textContentTextView.attributedText = NSAttributedString(string: message.textContent, attributes: textAttributes)
        
        //textContentTextView.textAlignment = textContentLabelWidth < YepConfig.minMessageTextLabelWidth ? .Center : .Left
        
        // 用 sizeThatFits 来对比，不需要 magicWidth 的时候就可以避免了
        var textContentLabelWidth = textContentLabelWidth
        let size = textContentTextView.sizeThatFits(CGSize(width: textContentLabelWidth, height: CGFloat.greatestFiniteMagnitude))
        
        // lineHeight 19.088, size.height 35.5 (1 line) 54.5 (2 lines)
        textContentTextView.textAlignment = ((size.height - textContentTextView.font!.lineHeight) < 20) ? .center : .left
        
        if ceil(size.width) != textContentLabelWidth {
            //println("left ceil(size.width): \(ceil(size.width)), textContentLabelWidth: \(textContentLabelWidth)")
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
                
                let topOffset: CGFloat
                if strongSelf.inGroup {
                    topOffset = Config.ChatCell.marginTopForGroup
                } else {
                    topOffset = 0
                }
                
                let textContentTextViewFrame = CGRect(x: strongSelf.avatarImageView.frame.maxX + Config.chatCellGapBetweenTextContentLabelAndAvatar(), y: 3 + topOffset, width: textContentLabelWidth, height: strongSelf.bounds.height - topOffset - 3 * 2 - strongSelf.bottomGap)
                
                strongSelf.textContentTextView.frame = textContentTextViewFrame
                
                let bubbleBodyFrame = textContentTextViewFrame.insetBy(dx: -12, dy: -3)
                
                strongSelf.bubbleBodyShapeLayer.path = UIBezierPath(roundedRect: bubbleBodyFrame, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: Config.ChatCell.bubbleCornerRadius, height: Config.ChatCell.bubbleCornerRadius)).cgPath
                
                if strongSelf.inGroup {
                    strongSelf.nameLabel.text = strongSelf.user?.getUserNickName()
                    
                    let height = Config.ChatCell.nameLabelHeightForGroup
                    let x = textContentTextViewFrame.origin.x
                    let y = textContentTextViewFrame.origin.y - height - 3
                    let width = strongSelf.contentView.bounds.width - x - 10
                    strongSelf.nameLabel.frame = CGRect(x: x, y: y, width: width, height: height)
                }
                
                strongSelf.bubbleTailImageView.center = CGPoint(x: bubbleBodyFrame.minX, y: strongSelf.avatarImageView.frame.midY)
            }
        }
        
        // TODO: 图片设置
        
//        if let sender = message.creatUser {
//            let userAvatar = UserAvatar(userID: sender.userID, avatarURLString: sender.avatarURLString, avatarStyle: nanoAvatarStyle)
//            avatarImageView.navi_setAvatar(userAvatar, withFadeTransitionDuration: avatarFadeTransitionDuration)
//        }
    }
    
    
}
