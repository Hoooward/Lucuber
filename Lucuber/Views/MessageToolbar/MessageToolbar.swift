//
//  MessageToolbar.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/8.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

public enum MessageToolbarState: Int, CustomStringConvertible {
    
    case normal
    case beginTextInput
    case textInputing
    case voiceRecord
    
    public var description: String {
        switch self {
        case .normal:
            return "normal"
        case .beginTextInput:
            return "beginTextInput"
        case .textInputing:
            return "TextInputing"
        case .voiceRecord:
            return "voiceRecord"
        }
    }
    
    public var isAtBottom: Bool {
        switch self {
        case .normal:
            return true
        case .beginTextInput, .textInputing:
            return false
        case .voiceRecord:
            return true
        }
    }
    
}

class MessageToolbar: UIToolbar {
    
    // MARK: - Properties
    
    var lastToobarFrame: CGRect?
    
    let messageTextViewHeightConstraintNormalConstant: CGFloat = 34
    var messageTextViewHeightConstraint: NSLayoutConstraint!
    
    let messageTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        // TODO: finish
    }
    
    // TODO: 这里传入 FOrmula 可能不对， Yep 中传入的是 Conversation
    var formula: Formula? {
        
        willSet {
            
            if let _ = newValue {
                
                NotificationCenter.default.addObserver(self, selector: #selector(MessageToolbar.updateDraft), name: Notification.Name.updateDraftOfConversationNotification, object: nil)
            }
        }
    }
    
    var stateTransitionAction: ((_ messageToolbar: MessageToolbar, _ previousState: MessageToolbarState, _ currentState: MessageToolbarState) -> Void)?
    
    var previousState: MessageToolbarState = .normal
    var state: MessageToolbarState = .normal {
        
        willSet {
            
            
            // update TextView
            
            previousState = state
            
            
            if let action = stateTransitionAction {
                action(self, previousState, newValue)
            }
            
            switch newValue {
                
            case .normal:
                moreButton.isHidden = false
                sendButton.isHidden = true
                
                messageTextView.isHidden = false
                voiceRecordButton.isHidden = true
                
                micButton.setImage(UIImage(named: "item_mic"), for: .normal)
                moreButton.setImage(UIImage(named: "item_more"), for: .normal)
                
                micButton.tintColor = UIColor.messageToolbarColor()
                moreButton.tintColor = UIColor.messageToolbarColor()
                
                // TODO: - hideVoiceButton
                
            case .beginTextInput:
                
                moreButton.isHidden = false
                sendButton.isHidden = true
                
                moreButton.setImage(UIImage(named: "item_more"), for: .normal)
                
            case .textInputing:
                
                moreButton.isHidden = true
                sendButton.isHidden = false
                
                messageTextView.isHidden = false
                voiceRecordButton.isHidden = true
                
            case .voiceRecord:
                
                moreButton.isHidden = false
                sendButton.isHidden = true
                
                messageTextView.isHidden = true
                voiceRecordButton.isHidden = false
                
                messageTextView.text = nil
                
                micButton.setImage(UIImage(named: "icon_keyboard"), for: .normal)
                moreButton.setImage(UIImage(named: "icon_more"), for: .normal)
                
                micButton.tintColor = UIColor.messageToolbarColor()
                moreButton.tintColor = UIColor.messageToolbarColor()
                
                // TODO: - ShowVoiceButton
                
                break
                
            }
        }
    }
    
    lazy var micButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "item_mic"), for: .normal)
        button.tintColor = UIColor.messageToolbarColor()
        button.tintAdjustmentMode = .normal
        button.addTarget(self, action: #selector(MessageToolbar.toggleRecordVoice), for: .touchUpInside)
        return button
        
    }()
    
    
    lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.messageToolbarSubViewBoderColor().cgColor
        textView.layer.cornerRadius = 6
        textView.delegate = self
        textView.isScrollEnabled = false // 重要： 没有的话换行时 Top Inset 不对
        return textView
    }()
    
    
    
    lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "item_more"), for: .normal)
        button.tintColor = UIColor.messageToolbarColor()
        button.tintAdjustmentMode = .normal
        button.addTarget(self, action: #selector(MessageToolbar.moreButtonClicked), for: .touchUpInside)
        return button
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("发送", for: .normal)
//        button.tintColor = UIColor.cubeTintColor()
        button.setTitleColor(UIColor.cubeTintColor(), for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .highlighted)
        button.tintAdjustmentMode = .normal
        button.addTarget(self, action: #selector(MessageToolbar.trySendTextMessage), for: .touchUpInside)
        return button
    }()
    
    lazy var voiceRecordButton: UIButton = {
        let button = UIButton()
        button.setTitle("语音", for: .normal)
        button.sizeToFit()
        return button
    }()
    
    
    
    // MARK: - Life Cycle
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        makeUI()
        state = .normal
    }
    
    private func makeUI () {
        
        sendButton.isHidden = true
        
        addSubview(voiceRecordButton)
        addSubview(messageTextView)
        addSubview(micButton)
        addSubview(moreButton)
        addSubview(sendButton)
        
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        micButton.translatesAutoresizingMaskIntoConstraints = false
        voiceRecordButton.translatesAutoresizingMaskIntoConstraints = false
        moreButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDictionary: [String: AnyObject] = [
            "moreButton": moreButton,
            "messageTextView": messageTextView,
            "micButton": micButton,
            "voiceRecordButton":voiceRecordButton,
            "sendButton": sendButton
        ]
        
        let buttonButton: CGFloat = 8
        
        let constraintsV1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=0)-[micButton]-(bottom)-|", options: [], metrics: ["bottom": buttonButton], views: viewDictionary)
        let constraintsV2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=0)-[moreButton(==micButton)]-(bottom)-|", options: [], metrics: ["bottom": buttonButton], views: viewDictionary)
        let constraintsV3 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=0)-[sendButton(==micButton)]-(bottom)-|", options: [], metrics: ["bottom": buttonButton], views: viewDictionary)
        let messageTextViewConstraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[messageTextView]-8-|", options: [], metrics: nil, views: viewDictionary)
        
        
        let textContainerInset = messageTextView.textContainerInset
        let constant = ceil(messageTextView.font!.lineHeight + textContainerInset.top + textContainerInset.bottom)
        printLog("messageTextViewheight: \(constant)")
        
        messageTextViewHeightConstraint = NSLayoutConstraint(item: messageTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: constant)
        
        messageTextViewHeightConstraint.priority = UILayoutPriorityDefaultHigh
        
        let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[micButton(48)][messageTextView][moreButton(==micButton)]|", options: [], metrics: nil, views: viewDictionary)
        
        
        NSLayoutConstraint.activate(constraintsV1)
        NSLayoutConstraint.activate(constraintsV2)
        NSLayoutConstraint.activate(constraintsV3)
        NSLayoutConstraint.activate(constraintsH)
        NSLayoutConstraint.activate([messageTextViewHeightConstraint])
        NSLayoutConstraint.activate(messageTextViewConstraintsV)
        
        let sendBUttonConstraintCenterY = NSLayoutConstraint(item: sendButton, attribute: .centerY, relatedBy: .equal, toItem: micButton, attribute: .centerY, multiplier: 1, constant: 0)
        
        let sendButtonConstraintHeight = NSLayoutConstraint(item: sendButton, attribute: .height, relatedBy: .equal, toItem: micButton, attribute: .height, multiplier: 1, constant: 0)
        
        let sendButtonConstrainsH = NSLayoutConstraint.constraints(withVisualFormat: "H:[messageTextView][sendButton(==moreButton)]|", options: [], metrics: nil, views: viewDictionary)
        
        NSLayoutConstraint.activate([sendBUttonConstraintCenterY])
        NSLayoutConstraint.activate([sendButtonConstraintHeight])
        NSLayoutConstraint.activate(sendButtonConstrainsH)
        
        let voiceRecordButtonConstraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[voiceRecordButton]-8-|", options: [], metrics: nil, views: viewDictionary)
        
        let voiceRecordButtonConstraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[micButton][voiceRecordButton][moreButton]|", options: [], metrics: nil, views: viewDictionary)
        
        NSLayoutConstraint.activate(voiceRecordButtonConstraintsV)
        NSLayoutConstraint.activate(voiceRecordButtonConstraintsH)
    }
    
    
    func updateHeightOfMessageTextView() {
        
        
        let size = messageTextView.sizeThatFits(CGSize(width: messageTextView.bounds.width, height: CGFloat(FLT_MAX)))
        
        let newHeight = size.height
        
        let limitedNewHeight = min(CubeRuler.iPhoneVertical(60, 80, 100, 120).value, newHeight)
        
        if newHeight != messageTextViewHeightConstraint.constant {
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
                
                self.messageTextViewHeightConstraint.constant = limitedNewHeight
                self.layoutIfNeeded()
                
                }, completion: { [weak self] finished in
                    
                    if finished,
                       let strongSelf = self {
                        
                        let enabled = newHeight > strongSelf.messageTextView.bounds.height
                        strongSelf.messageTextView.isScrollEnabled = enabled
                        
                    }
                    
            })
        }
        
        
    }
    
    // MARK: Target & Action & Notification
    
    var textSendAction: ((MessageToolbar) -> Void)?
    var moreMessageTypeAction: (() -> Void)?
    
    func trySendTextMessage() {
        
        textSendAction?(self)
    }
    
    func moreButtonClicked() {
        
    }
    
    func toggleRecordVoice() {
        
    }
    
    func updateDraft() {
        
    }
    
}

extension MessageToolbar: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        guard let text = textView.text else { return }
        
        state = text.isEmpty ? .beginTextInput : .textInputing
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard let text = textView.text else { return }
        
        state = text.isEmpty ? .beginTextInput : .textInputing
        
        
    }
    
}

