//
//  SubscribeFeedCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/15.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class SubscribeFeedCell: UITableViewCell {
    
    @IBOutlet weak var chatLabel: UILabel!
    @IBOutlet weak var mediaView: FeedMediaView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var accessoryImageView: UIImageView!
    @IBOutlet weak var redDotImageView: UIImageView!
    
    
    var conversation: Conversation!
    
    fileprivate var hasUnreadMessage: Bool = false {
        didSet {
            redDotImageView.isHidden = !hasUnreadMessage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryImageView.tintColor = UIColor.lightGray
    }
    
    override func prepareForReuse() {
        
        mediaView.isHidden = true
        mediaView.clearImages()
    }

    func configureCell(with conversation: Conversation) {
        
        self.conversation = conversation
        
        guard let feed = conversation.withGroup?.withFeed else {
            return
        }
        
        hasUnreadMessage = conversation.hasUnreadMessages
        
        nameLabel.text = feed.body
        
        let attachments: [ImageAttachment] = feed.attachments.map({
            ImageAttachment(metadata: $0.metadata, URLString: $0.URLString, image: nil)
        })
        
        mediaView.setImagesWithAttachments(attachments)
        
        if let lastesValidMessage = conversation.latestValidMessage {
            
            if let mediaType = MessageMediaType(rawValue: lastesValidMessage.mediaType), let placeholder = mediaType.placeholder {
                chatLabel.text = placeholder
                
            } else {
                
                self.chatLabel.text = lastesValidMessage.nicknameWithtextContent
            }
            
        } else {
            
            self.chatLabel.text = "没有消息"
        }
    }
    
}
