//
//  CommentViewController+Cache.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation


extension CommentViewController {
    
    func heightOfMessage(_ message: Message) -> CGFloat {
        
        let key = message.localObjectID
        
        if let height = messageCellHeights[key] {
            return height
        }
        
        var height: CGFloat = 0
        
        switch message.mediaType {
            
        case MessageMediaType.text.rawValue:
            
            let rect = (message.textContent as NSString).boundingRect(with: CGSize(width: messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Config.ChatCell.textAttributes, context: nil)
            
            height = max(ceil(rect.height) + (11 * 2), Config.chatCellAvatarSize())
            
            if !key.isEmpty {
                
                textContentLabelWidths[key] = ceil(rect.width)
            }
            
        case MessageMediaType.image.rawValue:
            
            if let (imageWidth, imageHeight) = imageMetaOfMessage(message: message) {
                let aspectRatio = imageWidth / imageHeight
                
                if aspectRatio >= 1 {
                    height = max(ceil(messageImagePreferredWidth / aspectRatio), Config.ChatCell.mediaMinHeight)
                } else {
                    height = max(messageImagePreferredHeight, ceil(Config.ChatCell.mediaMinWidth / aspectRatio))
                }
                
            } else {
                height = ceil(messageImagePreferredWidth / messageImagePreferredAspectRatio)
            }
            
            
        default:
            height = 40
        }
        
        if conversation.withGroup != nil {
            if message.mediaType != MessageMediaType.sectionDate.rawValue {
                
                if let sender = message.creator {
                    if !sender.isMe {
                        height += Config.ChatCell.marginTopForGroup
                    }
                }
            }
        }
        
        return height
    }
    
    func textContentLabelWidth(of message: Message) -> CGFloat {
        
        let key = message.localObjectID
        
        if let textContentLabelWidth = textContentLabelWidths[key] {
            return textContentLabelWidth
        }
        
        let rect = (message.textContent as NSString).boundingRect(with: CGSize(width: messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Config.ChatCell.textAttributes, context: nil)
        
        let width = ceil(rect.width)
        
        if !key.isEmpty {
            
            textContentLabelWidths[key] = width
        }
        
        return width
    }
    
}
