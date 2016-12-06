//
//  FeedBaseCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

public typealias tapMediaActionTypealias =  ((_ transitionView: UIView, _ image: UIImage?, _ imageAttachments: [ImageAttachment], _ index: Int) -> Void)?

class FeedBaseCell: UITableViewCell {
    
    static let messageTextViewMaxWidth: CGFloat = {
        let maxWidth = UIScreen.main.bounds.width - (15 + 40 + 10 + 15)
        return maxWidth
    }()
    
    var feed: DiscoverFeed?
    
    var tapAvataraction: ((FeedBaseCell) -> Void)?
    
    var touchesBeganAction: ((UITableViewCell) -> Void)?
    var touchesEndedAction: ((UITableViewCell) -> Void)?
    var touchesCancelledAction: ((UITableViewCell) -> Void)?
    
    /// 通过Feed内容计算高度
    class func heightOfFeed(feed: DiscoverFeed) -> CGFloat {
        
        let rect = (feed.body as NSString).boundingRect(with: CGSize(width: FeedBaseCell.messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17)], context: nil)
        
        let height: CGFloat = 10 + 40 + ceil(rect.height) + 4 + 15 + 17 + 15
        return ceil(height)
    }
    
    
    func configureWithFeed(_ feed: DiscoverFeed, layout: FeedCellLayout, needshowCategory: Bool) {
        self.feed = feed
        let defaultLayout = layout.defaultLayout
        
        messageTextView.text = "\(feed.body)" // ref http://stackoverflow.com/a/25994821
        //println("messageTextView.text: >>>\(messageTextView.text)<<<")
        messageTextView.frame = defaultLayout.messageTextViewFrame
        
        nickNameLabel.text = feed.creator?.username ?? "iTychooo"
        nickNameLabel.frame = defaultLayout.nicknameLabelFrame
        
        
        avatarImageView.image = UIImage(named: "Howard")
        avatarImageView.frame = defaultLayout.avatarImageViewFrame
        
        categoryButton.setTitle(feed.kind.rawValue, for: .normal)
        categoryButton.frame = defaultLayout.categoryButtonFrame
        
        
        leftBottomLabel.text = "1小时前"
        leftBottomLabel.frame = defaultLayout.leftBottomLabelFrame
        discussionImageView.frame = defaultLayout.discussionImageViewFrame
        
        messageCountLabel.text = "10"
        messageCountLabel.frame = defaultLayout.messageCountLabelFrame
        
    }
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.frame = CGRect(x: 15, y: 10, width: 40, height: 40)
        
        imageView.contentMode = .scaleAspectFit
        
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(FeedBaseCell.tapAvatar(sender:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapAvatar)
        
        return imageView
    }()
    
    lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.cubeTintColor()
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
        
        button.addTarget(self, action: #selector(FeedBaseCell.tapCategory(sender:)), for: .touchUpInside)
        
        return button
    }()
    
    lazy var messageTextView: FeedTextView = {
        let textView = FeedTextView()
        textView.textColor = UIColor.messageColor()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.dataDetectorTypes = [.link]
        
        textView.frame = CGRect(x: 65, y: 54, width: UIScreen.main.bounds.width - 65 - 15, height: 26)
        textView.isOpaque = true
        textView.backgroundColor = UIColor.white
        
        textView.touchesBeganAction = {
            [weak self] in
            if let strongSelf = self {
                strongSelf.touchesBeganAction?(strongSelf)
            }
        }
        
        textView.touchesEndedAction = {
            [weak self] in
            if let strongSelf = self {
                strongSelf.touchesEndedAction?(strongSelf)
            }
        }
        
        textView.touchesCancelledAction = {
            [weak self] in
            if let strongSelf = self {
                strongSelf.touchesCancelledAction?(strongSelf)
            }
        }
        return textView
    }()
    
    lazy var leftBottomLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.feedBottomLabel()
        label.textAlignment = .left
        label.frame = CGRect(x: 65, y: 0, width: UIScreen.main.bounds.width - 65 - 85, height: 17)
        label.isOpaque = true
        label.backgroundColor = UIColor.white
        label.clipsToBounds = true
        
        return label
    }()
    
    lazy var messageCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.cubeTintColor()
        label.font = UIFont.feedBottomLabel()
        label.textAlignment = .right
        
        label.frame = CGRect(x: 65, y: 0, width: 200, height: 17)
        label.isOpaque = true
        label.backgroundColor = UIColor.white
        label.clipsToBounds = true
        
        return label
    }()
    
    lazy var discussionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon-chatbubble")
        return imageView
    }()
    
    lazy var uploadingErrorContainerView: FeedUploadingErrorContainerView = {
        let view = FeedUploadingErrorContainerView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        return view
    }()
    
    var messagesConutEqualsZero = false {
        didSet {
            messageCountLabel.isHighlighted = messagesConutEqualsZero
        }
    }
    
    var hasUploadingErrorMessage = false {
        didSet {
            uploadingErrorContainerView.isHidden = !hasUploadingErrorMessage
            
            leftBottomLabel.isHidden = hasUploadingErrorMessage
            messageCountLabel.isHidden = hasUploadingErrorMessage || (self.messagesConutEqualsZero)
            discussionImageView.isHidden = hasUploadingErrorMessage
        }
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(categoryButton)
        contentView.addSubview(messageTextView)
        contentView.addSubview(leftBottomLabel)
        contentView.addSubview(messageCountLabel)
        contentView.addSubview(discussionImageView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapCategory(sender: UIGestureRecognizer) {
        
    }
    
    func tapAvatar(sender: UIGestureRecognizer) {
        
    }

    
}
