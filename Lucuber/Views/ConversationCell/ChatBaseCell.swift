//
//  ChatBaseCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/7.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud

class ChatBaseCell: UICollectionViewCell {
    
    
    // MARK: Properties
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.cubeGrayColor()
        label.numberOfLines = 1
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.frame = CGRect(x: 15, y: 0, width: 40, height: 40)
        
        imageView.contentMode = .scaleAspectFit
        
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(ChatBaseCell.tapAvatar(sender:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapAvatar)
        
        return imageView
    }()
    
    var user: AVUser?
    var tapAvatarAction: ((AVUser) -> Void)?
    
    var deleteMessageAction: (() -> Void)?
    var reportMessageAction: (() -> Void)?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(avatarImageView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatBaseCell.menuWillShow(_ :)), name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatBaseCell.menuWillHide(_ :)), name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
        
       
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tapAvatar(sender: UITapGestureRecognizer) {
        
        printLog("tapAvatar")
        
        if let user = user {
            tapAvatarAction?(user)
        }
    }
    
    var prepareForMenuAction: ((_ otherGesturesEnabled: Bool) -> Void)?
    
    @objc func menuWillShow(_ notification: NSNotification) {
        prepareForMenuAction?(false)
    }
    
    @objc func menuWillHide(_ notification: NSNotification) {
        prepareForMenuAction?(true)
        
    }
    
    var inGroup = false
    
    func deleteMessage(object: UIMenuController?) {
        deleteMessageAction?()
    }
    
    func reportMessage(object: UIMenuController?) {
        reportMessageAction?()
    }
    
}

extension ChatBaseCell: UIGestureRecognizerDelegate {
    
     // 让触发 Menu 和 Tap Media 能同时工作，不然 Tap 会让 Menu 不能弹出
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // iOS 9 在长按链接时不弹出 menu
        
        if let longPressGestureRecognizer = otherGestureRecognizer as? UILongPressGestureRecognizer {
            if longPressGestureRecognizer.minimumPressDuration == 0.75 {
                return true
            }
        }
        
        return false
    }
    
    
}
