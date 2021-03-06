//
//  SearchFeedBasicCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/16.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import Navi

class SearchFeedBasicCell: UITableViewCell {
    
    
    var feed: DiscoverFeed?
    
    var tapAvatarAction: ((UITableViewCell) -> Void)?
    
    var touchesBeganAction: ((UITableViewCell) -> Void)?
    var touchesEndedAction: ((UITableViewCell) -> Void)?
    var touchesCancelledAction: ((UITableViewCell) -> Void)?
    
    static let messageTextViewMaxWidth: CGFloat = {
        let maxWidth = UIScreen.main.bounds.width - (10 + 30 + 10 + 10)
        return maxWidth
    }()
    
    
    class func heightOfFeed(_ feed: DiscoverFeed) -> CGFloat {
        
        let rect = feed.body.boundingRect(with: CGSize(width: SearchFeedBasicCell.messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Config.FeedDetailCell.messageTextViewAttributies, context: nil)
        
        let height: CGFloat = 15 + 30 + 4 + ceil(rect.height) + 15
        
        return ceil(height)
    }
    
    func configureCell(with feed: DiscoverFeed, layout: SearchFeedCellLayout, keyword: String?) {
        
        let basicLayout = layout.basicLayout
        
        self.feed = feed
        
        if let url = feed.creator?.avatorImageURL() {
            let cubeAvatar = CubeAvatar(avatarUrlString: url, avatarStyle: nanoAvatarStyle)
            avatarImageView.navi_setAvatar(cubeAvatar, withFadeTransitionDuration: 0.5)
        } else {
            avatarImageView.image = #imageLiteral(resourceName: "default_avatar_60")
        }
        
        let text = "\u{200B}\(feed.body)"
        if let keyword = keyword {
            
            printLog(keyword)
//            printLog(keywordSet)
            if let attributedText = text.highlightWithKeywordSet(keyword, color: UIColor.cubeTintColor(), baseFont: UIFont.feedMessageTextView(), baseColor: UIColor.messageColor()) {
                messageTextView.attributedText = attributedText
            } else {
                messageTextView.text = text
            }
        } else {
            messageTextView.text = text
        }
        
        messageTextView.frame = basicLayout.messageTextViewFrame
        
        var _nickname = "未知"
        if let nickname = feed.creator?.nickname() {
            _nickname = nickname
        }
        nicknameLabel.text = _nickname
        nicknameLabel.frame = basicLayout.nicknameLabelFrameWhen(hasLogo: false, hasCategory: false)
        
        avatarImageView.frame = basicLayout.avatarImageViewFrame
        
        
        if let formula = feed.withFormula {
            let categoryString = formula.category
            categoryButton.isHidden = false
            categoryButton.setTitle(categoryString, for: .normal)
            categoryButton.frame = basicLayout.categoryButtonFrame
            
        } else {
            categoryButton.isHidden = true
            categoryButton.frame = basicLayout.categoryButtonFrame
        }
    }
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 10, y: 15, width: 30, height: 30)
        imageView.contentMode = .scaleAspectFit
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(SearchFeedBasicCell.tapAvatar))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapAvatar)
        
        return imageView
    }()
    
    
    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 199/255.0, green: 199/255.0, blue: 204/255.0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 15)
        
        label.frame = CGRect(x: 65, y: 21, width: 100, height: 18)
        label.isOpaque = true
        label.backgroundColor = UIColor.white
        label.clipsToBounds = true
        
        return label
    }()
    
    lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "skill_bubble_empty"), for: .normal)
        button.setTitleColor(UIColor.cubeTintColor(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        let cellWidth = self.bounds.width
        let width: CGFloat = 60
        button.frame = CGRect(x: cellWidth - width - 15, y: 19, width: width, height: 22)
        
        return button
    }()
    
    
    lazy var messageTextView: FeedTextView = {
        let textView = FeedTextView()
        textView.textColor = UIColor.messageColor()
        textView.font = UIFont.feedMessageTextView()
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.dataDetectorTypes = [.link]
        
        textView.frame = CGRect(x: 65, y: 54, width: UIScreen.main.bounds.width - 65 - 15, height: 26)
        textView.isOpaque = true
        textView.backgroundColor = UIColor.white
        
        textView.touchesBeganAction = { [weak self] in
            if let strongSelf = self {
                strongSelf.touchesBeganAction?(strongSelf)
            }
        }
        textView.touchesEndedAction = { [weak self] in
            if let strongSelf = self {
                if strongSelf.isEditing {
                    return
                }
                strongSelf.touchesEndedAction?(strongSelf)
            }
        }
        textView.touchesCancelledAction = { [weak self] in
            if let strongSelf = self {
                strongSelf.touchesCancelledAction?(strongSelf)
            }
        }
        
        return textView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(categoryButton)
        contentView.addSubview(messageTextView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        feed = nil
        
        messageTextView.text = nil
        messageTextView.attributedText = nil
    }
    
    // MARK: - Target & Action
    func tapAvatar() {
       tapAvatarAction?(self)
    }
}
