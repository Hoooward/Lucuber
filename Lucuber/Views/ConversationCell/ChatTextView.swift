//
//  ChatTextView.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/7.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ChatTextView: UITextView {

    var tapMentionAction: ((_ username: String) -> Void)?
    var tapFeedAction: ((_ feed: Any) -> Void)?
    
    static let detectionTypeName = "detectionTypeName"
    
    enum DetectionType: String {
        case Mention
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.delegate = self
        
        isEditable = false
        
        dataDetectorTypes = [.link, .phoneNumber, .calendarEvent]
    }

    override var text: String! {
        didSet {
            
            let attributedString = NSMutableAttributedString(string: text)
            
            let textRange = NSMakeRange(0, (text as NSString).length)
            
            attributedString.addAttributes([NSForegroundColorAttributeName: textColor!], range: textRange)
            
            attributedString.addAttributes([NSFontAttributeName: font!], range: textRange)
            
            // mention link 
            
            let pattern = "[@＠]([A-Za-z0-9_]{4,16})"
            
            let menttionExpression = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.init(rawValue: 0))
            
            menttionExpression.enumerateMatches(in: text, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: textRange) { (result, flages, stop) in
                
                if let result = result {
                    
                    let textValue = (self.text as NSString).substring(with: result.range)
                    
                    let textAttributes = [
                        NSLinkAttributeName: textValue,
                        ChatTextView.detectionTypeName: DetectionType.Mention.rawValue]
                    
                    attributedString.addAttributes(textAttributes, range: result.range)
                }
            }
            
            self.attributedText = attributedString
        }
    }
    
    
    override var canBecomeFirstResponder: Bool {
        return false
    }
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // iOS 9 以上，强制不添加文字选择长按手势，免去触发选择文字
        // 共有四种长按手势，iOS 9 正式版里分别加了两次：0.1 Reveal，0.12 tap link，0.5 selection， 0.75 press link
        
        if let longPressGestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
            if  longPressGestureRecognizer.minimumPressDuration == 0.5 {
                return
            }
        }
        
        super.addGestureRecognizer(gestureRecognizer)
    }
}

extension ChatTextView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        if let detectionTypeName = self.attributedText.attribute(ChatTextView.detectionTypeName, at: characterRange.location, effectiveRange: nil) as? String, let detectionType = DetectionType(rawValue: detectionTypeName) {
            
            let text = (self.text as NSString).substring(with: characterRange)
            self.handelTapText(text: text, withDetectionType: detectionType)
            
            return false
        }
        
        // TODO: 处理URL
        
        return true
    }
    
    func handelTapText(text: String, withDetectionType detectionType: DetectionType) {
        
        printLog("hangleTapText: \(text), \(detectionType)")
        
//        let username = text.substring(from: text.startIndex.advanceBy(1))
        
//        if !username.isEmpty {
//            tapMentionAction?(username)
//        }
        
    }
}























