//
//  FeedDefaultCellTableViewCell.swift
//  Lucuber
//
//  Created by Howard on 7/22/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

public typealias tapMediaActionTypealias =  ((transitionView: UIView, image: UIImage?, imageAttachments: [ImageAttachment], index: Int) -> Void)?

class FeedDefaultCell: UITableViewCell {


    static let messageTextViewMaxWidth: CGFloat = {
        let maxWidth = screenWidth - (15 + 40 + 10 + 15)
        return maxWidth
    }()
    

    var feed: Feed?
    
    var tapAvataraction: ((FeedDefaultCell) -> Void)?
    
    
    class func heightOfFeed(feed: Feed) -> CGFloat {
        
        let rect = (feed.contentBody! as NSString).boundingRectWithSize(CGSize(width: FeedDefaultCell.messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.UsesLineFragmentOrigin, .UsesFontLeading], attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17)], context: nil)
        
        let height: CGFloat = 10 + 40 + ceil(rect.height) + 4 + 15 + 17 + 15
        return ceil(height)
    }
    
    func configureWithFeed(feed: Feed, layout: FeedCellLayout, needshowCategory: Bool) {
        self.feed = feed
        let defaultLayout = layout.defaultLayout
        
        messageTextView.text = "\(feed.contentBody!)" // ref http://stackoverflow.com/a/25994821
        //println("messageTextView.text: >>>\(messageTextView.text)<<<")
        messageTextView.frame = defaultLayout.messageTextViewFrame
        
        nickNameLabel.text = feed.creator?.username ?? "iTychooo"
        nickNameLabel.frame = defaultLayout.nicknameLabelFrame
        
        
        avatarImageView.image = UIImage(named: "Howard")
        avatarImageView.frame = defaultLayout.avatarImageViewFrame
        
        categoryButton.setTitle(feed.category, forState: .Normal)
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
        
        imageView.contentMode = .ScaleAspectFit
        
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(FeedDefaultCell.tapAvatar(_:)))
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapAvatar)
        
        return imageView
    }()
    
    lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.cubeTintColor()
        label.font = UIFont.systemFontOfSize(15)
        
        label.frame = CGRect(x: 65, y: 21, width: 100, height: 18)
        label.opaque = true
        label.backgroundColor = UIColor.whiteColor()
        label.clipsToBounds = true
        
        return label
    }()
    
    lazy var categoryButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "skill_bubble_empty"), forState: .Normal)
        button.setTitleColor(UIColor.cubeTintColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(12)
      
        let cellWidth = self.bounds.width
        let width: CGFloat = 60
        button.frame = CGRect(x: cellWidth - width - 15, y: 19, width: width, height: 22)
        
        button.addTarget(self, action: #selector(FeedDefaultCell.tapCategory(_:)), forControlEvents: .TouchUpInside)
        
        return button
    }()
    
    lazy var messageTextView: FeedTextView = {
        let textView = FeedTextView()
        textView.textColor = UIColor.cubeMessageColor()
        textView.font = UIFont.systemFontOfSize(17)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.editable = false
        textView.scrollEnabled = false
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.dataDetectorTypes = [.Link]
        
        textView.frame = CGRect(x: 65, y: 54, width: screenWidth - 65 - 15, height: 26)
        textView.opaque = true
        textView.backgroundColor = UIColor.whiteColor()
        
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
        label.textColor = UIColor.grayColor()
        label.font = UIFont.feedBottomLabelFont()
        label.textAlignment = .Left
        
        label.frame = CGRect(x: 65, y: 0, width: screenWidth - 65 - 85, height: 17)
        label.opaque = true
        label.backgroundColor = UIColor.whiteColor()
        label.clipsToBounds = true
        
        return label
    }()
    
    lazy var messageCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.cubeTintColor()
        label.font = UIFont.feedBottomLabelFont()
        label.textAlignment = .Right
        
        label.frame = CGRect(x: 65, y: 0, width: 200, height: 17)
        label.opaque = true
        label.backgroundColor = UIColor.whiteColor()
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
            messageCountLabel.highlighted = messagesConutEqualsZero
        }
    }
    
    var hasUploadingErrorMessage = false {
        didSet {
            uploadingErrorContainerView.hidden = !hasUploadingErrorMessage
            
            leftBottomLabel.hidden = hasUploadingErrorMessage
            messageCountLabel.hidden = hasUploadingErrorMessage || (self.messagesConutEqualsZero)
            discussionImageView.hidden = hasUploadingErrorMessage
        }
    }
    
    
    var touchesBeganAction: (UITableViewCell -> Void)?
    var touchesEndedAction: (UITableViewCell -> Void)?
    var touchesCancelledAction: (UITableViewCell -> Void)?
    
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
