//
//  CommentViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/8.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import RealmSwift

class CommentViewController: UIViewController {
    
    var formula: Formula?
    var conversation: Conversation!
    
    fileprivate lazy var messages: Results<Message> = {
        
        return messagesOfConversation(conversation: self.conversation, inRealm: self.realm)
    }()
    
    
    fileprivate var lastUpdateMessagesCount: Int = 0
    fileprivate let messagesBunchCount = 20
    
    fileprivate var displayedMessagesRange: NSRange = NSRange() {
        didSet {
            needShowLoadPreviousSection = displayedMessagesRange.length >= messagesBunchCount
        }
    }
    fileprivate var needShowLoadPreviousSection: Bool = false 
    
    var afterSentMessageAction: (() -> Void)?
    var afterDeletedFeedAction: ((String) -> Void)?
    var conversationIsDirty = false
    
    fileprivate var seletedIndexPathForMenu: IndexPath?
    
    fileprivate var realm: Realm!
    
//    fileprivate lazy var rMessages: Result<RMessage> = {
//    
//        return messag
//    }
//    
    
    fileprivate lazy var sectionDateFormatter: DateFormatter =  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    fileprivate lazy var sectionDateInCurrentWeekFormatter: DateFormatter =  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE HH:mm"
        return dateFormatter
    }()
    
    private lazy var titleView: ConversationTitleView = {
        let titleView = ConversationTitleView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 44)))
        
//        if nameOfConversation(self.conversation) != "" {
//            titleView.nameLabel.text = nameOfConversation(self.conversation)
//        } else {
//            titleView.nameLabel.text = NSLocalizedString("Discussion", comment: "")
//        }
//        
//        self.updateStateInfoOfTitleView(titleView)
//        
//        titleView.userInteractionEnabled = true
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(CommentViewController.showFriendProfile(_:)))
//        
//        titleView.addGestureRecognizer(tap)
        
        titleView.nameLabel.text = "讨论"
        titleView.stateInfoLabel.textColor = UIColor.gray
        titleView.stateInfoLabel.text = "上次见是一周以前"
        
        return titleView
    }()
    
    
    
    
    
    var headerView: CommentHeaderView?

    @IBOutlet weak var messageToolbar: MessageToolbar!
    @IBOutlet weak var commentCollectionView: UICollectionView!
    
    private var commentCollectionViewHasBeenMovedToBottomOnece = false
    
    @IBOutlet weak var messageToolbarBottomConstraints: NSLayoutConstraint!
    
    private let keyboardMan = KeyboardMan()
    private var giveUpKeyboardHideAnimationWhenViewControllerDisapeear = false
    
    
    fileprivate lazy var collectionViewWidth: CGFloat = {
        return self.commentCollectionView.bounds.width
    }()
    
    fileprivate lazy var messageTextViewMaxWidth: CGFloat = {
        return self.collectionViewWidth - Config.chatCellGapBetweenWallAndAvatar() - Config.chatCellAvatarSize() - Config.chatCellGapBetweenTextContentLabelAndAvatar() - Config.chatTextGapBetweenWallAndContentLabel()
    }()
    
    
    private var textContentLabelWidths = [String: CGFloat]()
    fileprivate func textContentLabelWidthOfMessage(_ message: Message) -> CGFloat {
        
        let key = message.messageID
            
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
    
    private var messageCellHeights = [String: CGFloat]()
    fileprivate func heightOfMessage(_ message: Message) -> CGFloat {
        
       let key = message.messageID
            
        if let height = messageCellHeights[key] {
            return height
        }
        
        var height: CGFloat = 0
        
        switch message.mediaType {
            
        case .text:
            
            let rect = (message.textContent as NSString).boundingRect(with: CGSize(width: messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Config.ChatCell.textAttributes, context: nil)
            
            height = max(ceil(rect.height) + (11 * 2), Config.chatCellAvatarSize())
            
            if !key.isEmpty {
                
                textContentLabelWidths[key] = ceil(rect.width)
            }
        
            // TODO: - 图片的 message 高度并未处理
            
            
        default:
            height = 20
            
        }
        
        if conversation.withGroup != nil {
            if message.mediaType != MessageMediaType.sectionDate {
                
                if let sender = message.creatUser {
                    if !sender.isMe() {
                        height += Config.ChatCell.marginTopForGroup
                    }
                }
            }
        }
        
        return height
    }
    
    
    func makeHeaderView(with formula: Formula?) {
        guard let formula = formula else {
            return
        }
        
        let headerView = CommentHeaderView.creatCommentHeaderViewFormNib()
        headerView.formula = formula
        
        headerView.changeStatusAction = {
            [weak self] status in
            
            switch status {
            case .small:
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                    [weak self] in
                    self?.commentCollectionView.contentInset.top = 64 + 60 + 20
                    }, completion: nil)
                
                printLog(self?.commentCollectionView.contentInset)
                
            case .big:
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                    [weak self] in
                    self?.commentCollectionView.contentInset.top = 64 + 120 + 20
                    }, completion: nil)
                
                if let messageToolbar = self?.messageToolbar {
                    
                    if !messageToolbar.state.isAtBottom {
                        messageToolbar.state = .normal
                    }
                }
                
                printLog(self?.commentCollectionView.contentInset)
                
                
            }
        }
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        let views: [String: AnyObject] = [
            "headerView": headerView
        ]
        
        let constraintH = NSLayoutConstraint.constraints(withVisualFormat: "H:|[headerView]|", options: [], metrics: nil, views: views)
        
        let top = NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 64)
        
        let height = NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 60)
        
        NSLayoutConstraint.activate(constraintH)
        NSLayoutConstraint.activate([top, height])
        
        headerView.heightConstraint = height
        
        self.headerView = headerView
        
    }
    
    
    fileprivate let loadMoreCollectionCellIdenfitifier = "LoadMoreCollectionViewCell"
    fileprivate let chatSectionDateCellIdentifier = "ChatSectionDateCell"
    fileprivate let chatLeftTextCellIdentifier = "ChatLeftTextCell"
    fileprivate let chatRightTextCellIdentifier = "ChatRightTextCell"
    fileprivate let chatLeftImageCellIdentifier = "ChatLeftImageCell"
    fileprivate let chatRightImageCellIdentifier = "ChatRightImageCell"
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        messageToolbar.stateTransitionAction = {
            [weak self] messageToolbar, previousState, currentStatue in
            
            switch currentStatue {
                
            case .beginTextInput:
                self?.tryChangedHeaderToSmall()
                self?.trySnapContentOfCommentCollectionViewToBottom(needAnimation: true)
                
            case .textInputing:
                
                
                self?.trySnapContentOfCommentCollectionViewToBottom()
                break
                
            default:
                break
                
            }
        }
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        realm = try! Realm()
        
        lastUpdateMessagesCount = messages.count
        
        if messages.count >= messagesBunchCount {
            
            displayedMessagesRange = NSRange(location: messages.count - messagesBunchCount, length: messagesBunchCount)
        } else {
            
            displayedMessagesRange = NSRange(location: 0, length: messages.count)
        }
        
        
        navigationItem.titleView = titleView
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_more"), style: .plain, target: self, action: #selector(CommentViewController.moreAction))
        
        makeHeaderView(with: formula)
      
        commentCollectionView.keyboardDismissMode = .onDrag
        commentCollectionView.alwaysBounceVertical = true
        
        commentCollectionView.register(UINib(nibName: loadMoreCollectionCellIdenfitifier, bundle: nil), forCellWithReuseIdentifier: loadMoreCollectionCellIdenfitifier)
        commentCollectionView.register(UINib(nibName: chatSectionDateCellIdentifier, bundle: nil), forCellWithReuseIdentifier: chatSectionDateCellIdentifier)
        commentCollectionView.register(ChatLeftTextCell.self, forCellWithReuseIdentifier: chatLeftTextCellIdentifier)
        commentCollectionView.register(ChatLeftImageCell.self, forCellWithReuseIdentifier: chatLeftImageCellIdentifier)
        commentCollectionView.register(ChatRightTextCell.self, forCellWithReuseIdentifier: chatRightTextCellIdentifier)
        commentCollectionView.register(ChatRightImageCell.self, forCellWithReuseIdentifier: chatRightImageCellIdentifier)
        
        commentCollectionView.bounces = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CommentViewController.tapToDismissMessageToolbar))
        commentCollectionView.addGestureRecognizer(tap)
        
        messageToolbarBottomConstraints.constant = 0
        
        keyboardMan.animateWhenKeyboardAppear = {
            [weak self] apperaPostIndex, keyboardHeight, keyboardHeightIncrement in
            
            guard self?.navigationController?.topViewController == self else {
                return
            }
            
            if let giveUp = self?.giveUpKeyboardHideAnimationWhenViewControllerDisapeear {
                
                if giveUp {
                    self?.giveUpKeyboardHideAnimationWhenViewControllerDisapeear = false
                    return
                }
            }
            
            if let strongSelf = self {
                
                if strongSelf.messageToolbarBottomConstraints.constant > 0 {
                    
                    // 第一次出现
                    if apperaPostIndex == 0 {
                        strongSelf.commentCollectionView.contentOffset.y += keyboardHeightIncrement
                    } else {
                        strongSelf.commentCollectionView.contentOffset.y += keyboardHeightIncrement
                    }
                    
                    let bottom = keyboardHeight + strongSelf.messageToolbar.frame.height
                    strongSelf.commentCollectionView.contentInset.bottom = bottom
                    strongSelf.commentCollectionView.scrollIndicatorInsets.bottom = bottom
                    strongSelf.messageToolbarBottomConstraints.constant = keyboardHeight
                    
                    strongSelf.view.layoutIfNeeded()
                    
                } else {
                    
                    strongSelf.commentCollectionView.contentOffset.y += keyboardHeightIncrement
                    let bottom = keyboardHeight + strongSelf.messageToolbar.frame.height
                    strongSelf.commentCollectionView.contentInset.bottom = bottom
                    strongSelf.commentCollectionView.scrollIndicatorInsets.bottom = bottom
                    strongSelf.messageToolbarBottomConstraints.constant = keyboardHeight
                    strongSelf.view.layoutIfNeeded()
                }
            }
        }
        
        keyboardMan.animateWhenKeyboardDisappear = {
            [weak self] keyboardHeight in
            
            guard self?.navigationController?.topViewController == self else {
                return
            }
            
            if let nvc = self?.navigationController {
                if nvc.topViewController != self {
                    self?.giveUpKeyboardHideAnimationWhenViewControllerDisapeear = true
                    return
                }
            }
            
            if let strongSelf = self {
                
                if strongSelf.messageToolbarBottomConstraints.constant > 0 {
                    strongSelf.commentCollectionView.contentOffset.y -= keyboardHeight
                    
                    let bottom = strongSelf.messageToolbar.frame.height
                    strongSelf.commentCollectionView.contentInset.bottom = bottom
                    strongSelf.commentCollectionView.scrollIndicatorInsets.bottom = bottom
                    strongSelf.messageToolbarBottomConstraints.constant = 0
                    strongSelf.view.layoutIfNeeded()
                }
            }
        }
        
        commentCollectionView.contentInset = UIEdgeInsets(top: 64 + 60 + 20, left: 0, bottom: 44, right: 0)
        print(commentCollectionView.contentInset)
        
        
        
//        loadNewComment()
    }
    
    private var isFirstAppear: Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        commentCollectionViewHasBeenMovedToBottomOnece = true
        
        if isFirstAppear {
            
            delay(0.1) {
                
                self.messageToolbar.textSendAction = { [weak self] messageToolbar in
                    
                    let text = messageToolbar.messageTextView.text!.trimming(trimmingType: .whitespaceAndNewLine)
                    
                    self?.cleanTextInput()
                    self?.trySnapContentOfCommentCollectionViewToBottom(needAnimation: true)
         
                    
                    if text.isEmpty { return }
                    
                    if let withFriend = self?.conversation.withFriend {
                        
                        sendText(text: text, toRecipient: withFriend.userID, recipientType: "User", afterCreatedMessage: { [weak self] message in
                            
                            self?.updateCommentCollectionViewWithMessageIDs(messagesID: nil, messageAge: .new, scrollToBottom: true, success: { _ in })
                            
                            }, failureHandler: {
                                
                                printLog("发送失败")
                                
                            }, completion: { _ in
                                
                                printLog("发送成功")
                                
                                
                        })
                        
                    } else if let withGroup = self?.conversation.withGroup {
                        
                        sendText(text: text, toRecipient: withGroup.groupID, recipientType: "group", afterCreatedMessage: { [weak self] message in
                            
                            self?.updateCommentCollectionViewWithMessageIDs(messagesID: nil, messageAge: .new, scrollToBottom: true, success: { _ in })
                            
                            }, failureHandler: {
                                
                                     printLog("发送失败")
                            }, completion: { _ in
                                
                                printLog("发送成功")
                                
                                
                        })
                    }
              
                    
                }
                
               
            }
        }
        
        isFirstAppear = false
        
    }
    
    

    
    func updateCommentCollectionViewWithMessageIDs(messagesID: [String]? , messageAge: MessageAge, scrollToBottom: Bool, success: @escaping (Bool) -> Void) {
        
        guard navigationController?.topViewController == self else {
            return
        }
        
        if messagesID != nil {
            
        // 标记已读
            batchMarkMessgesAsreaded()
        }
        
        
        let keyboardAndToobarHeight = messageToolbarBottomConstraints.constant + messageToolbar.bounds.height
        
        adjustConversationCollectionViewWithMessageIDs(messageIDs: messagesID, messageAge: messageAge, adjustHeight: keyboardAndToobarHeight, scrollToBottom: true, success: {
            finished in
            
            success(finished)
            
        })
        
        if messageAge == .new {
            conversationIsDirty = true
        }
        
        if messagesID == nil {
            
            afterSentMessageAction?()
            
            // 订阅栏如果出现
        }
        
    }
    
     private func adjustConversationCollectionViewWithMessageIDs(messageIDs: [String]?, messageAge: MessageAge, adjustHeight: CGFloat, scrollToBottom: Bool, success: @escaping (Bool) -> Void) {
        
        let _lastTimeMessagesCount = lastUpdateMessagesCount
        lastUpdateMessagesCount = messages.count
        
        
        if messages.count <= _lastTimeMessagesCount {
            return
        }
        
        let newMessageCount = Int(messages.count - _lastTimeMessagesCount)
        
        
        let lastDisplayedMessagesRange = displayedMessagesRange
        
        displayedMessagesRange.length += newMessageCount
        
        let needReloadLoadPreviousSection = self.needShowLoadPreviousSection
        
        if let messageIDs = messageIDs {
            
            if newMessageCount != messageIDs.count {
                commentCollectionView.reloadData()
            }
        }
        
        if newMessageCount > 0 {
            
            if let messageIDs = messageIDs {
                
                var indexPaths = [IndexPath]()
                
                for messageID in messageIDs {
                    
                    if
                        let message = messageWithMessageID(messageID: messageID, inRealm: realm) ,
                        let index = messages.index(of: message){
                        
                        let indexPath = IndexPath(item: index - displayedMessagesRange.location, section: Section.message.rawValue)
                        
                        indexPaths.append(indexPath)
                    } else {
                        
                        printLog("unknow message")
                    }
                }
                
                switch messageAge {
                    
                case .new:
                    
                    commentCollectionView.performBatchUpdates({
                        [weak self] in
                        if needReloadLoadPreviousSection {
                            
                            self?.commentCollectionView.reloadSections(IndexSet(integer: Section.loadPrevious.rawValue))
                            self?.needShowLoadPreviousSection = false
                        }
                        
                        self?.commentCollectionView.insertItems(at: indexPaths)
                        
                        }, completion: nil)
                    
                case .old:
                    
                    let bottomOffset = commentCollectionView.contentSize.height - commentCollectionView.contentOffset.y
                    
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    
                    commentCollectionView.performBatchUpdates({ [weak self] in
                        if needReloadLoadPreviousSection {
                            
                            self?.commentCollectionView.reloadSections(IndexSet(integer: Section.loadPrevious.rawValue))
                            self?.needShowLoadPreviousSection = false
                        }
                        
                        self?.commentCollectionView.insertItems(at: indexPaths)
                        
                        }, completion: { [weak self] finished in
                            if let strongSelf = self {
                                
                                var contentOffset = strongSelf.commentCollectionView.contentOffset
                                contentOffset.y = strongSelf.commentCollectionView.contentSize.height - bottomOffset
                                
                                strongSelf.commentCollectionView.setContentOffset(contentOffset, animated: false)
                                
                                CATransaction.commit()
                                
                                // 上面的 CATransaction 保证了 CollectionView 在插入后不闪动
                                /*
                                 // 此时再做个 scroll 动画比较自然
                                 let indexPath = NSIndexPath(forItem: newMessagesCount - 1, inSection: Section.Message.rawValue)
                                 strongSelf.conversationCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
                                 */
                            }
                        })
                    
                    
                    break
                }
            } else {
                
                printLog("self message")
                
                 // 这里做了一个假设：本地刚创建的消息比所有的已有的消息都要新，这在创建消息里做保证（服务器可能传回创建在“未来”的消息）
                var indexPaths = [IndexPath]()
                
                for i in 0..<newMessageCount {
                    let indexPath = IndexPath(item: lastDisplayedMessagesRange.length + i, section: Section.message.rawValue)
                    indexPaths.append(indexPath)
                }
                
                commentCollectionView.performBatchUpdates({
                    [weak self] in
                    if needReloadLoadPreviousSection {
                        
                        self?.commentCollectionView.reloadSections(IndexSet(integer: Section.loadPrevious.rawValue))
                        self?.needShowLoadPreviousSection = false
                    }
                    
                    self?.commentCollectionView.insertItems(at: indexPaths)
                    
                    }, completion: nil)
            }
        }
        
        if newMessageCount > 0 {
            
            var newMessagesTotalHeight: CGFloat = 0
            for i in _lastTimeMessagesCount..<messages.count {
                
                if let message = messages[safe: i] {
                    let height = heightOfMessage(message) + 5
                    newMessagesTotalHeight += height
                }
            }
            
            let keyboardAndTooBarHeight = adjustHeight
            
            let blockedHeight = 64 + (headerView != nil ? headerView!.height : 0) + keyboardAndTooBarHeight
            
            let visibleHeight = commentCollectionView.frame.height - blockedHeight
            
            let useableHeight = visibleHeight - commentCollectionView.contentSize.height
            
            if newMessagesTotalHeight > useableHeight {
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                    
                    [weak self] in
                    
                    if let strongSelf = self {
                        
                        if scrollToBottom {
                            
                            let newContentSize = strongSelf.commentCollectionView.collectionViewLayout.collectionViewContentSize
                            let newContentOffsetY = newContentSize.height - strongSelf.commentCollectionView.frame.height + keyboardAndTooBarHeight
                            strongSelf.commentCollectionView.contentOffset.y = newContentOffsetY
                            
                        } else {
                            
                            strongSelf.commentCollectionView.contentOffset.y += newMessagesTotalHeight
                        }
                    }
                    
                        
                    }, completion: { _ in
                        success(true)
                })
            } else {
                
                success(true)
            }
        } else {
            
            success(true)
        }
        
        
    }
    
     fileprivate func batchMarkMessgesAsreaded() {
       
        DispatchQueue.main.async {
            [weak self] in
            
            guard let _ = self else {
                return
            }
            
            
        }
        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !commentCollectionViewHasBeenMovedToBottomOnece {
            
            setCommentCollectionViewOriginalContentInset()
            
            tryScrollToBottom()
            
        }
    }
    
    
    // MARK: - Action & Target
    
    fileprivate func tryScrollToBottom() {
        
        let messageToobarTop = messageToolbarBottomConstraints.constant + messageToolbar.bounds.height
        
        let headerHeight: CGFloat = headerView == nil ? 0 : headerView!.height
        let invisbleHeight = messageToobarTop + 64 + headerHeight
        let visibleHeight = commentCollectionView.frame.height - invisbleHeight
        
        let canScroll = visibleHeight <= commentCollectionView.contentSize.height
        
        printLog("collectionViewContentSize = \(commentCollectionView.contentSize)")
        if canScroll {
            
            commentCollectionView.contentOffset.y = commentCollectionView.contentSize.height - commentCollectionView.frame.size.height + messageToobarTop
            commentCollectionView.contentInset.bottom = messageToobarTop
            commentCollectionView.scrollIndicatorInsets.bottom = messageToobarTop
        }
        
    }

    
    private func setCommentCollectionViewOriginalContentInset() {
        
        let headerHeight: CGFloat = headerView == nil ? 0 : headerView!.height
        commentCollectionView.contentInset.top = 64 + headerHeight + 5
        
        commentCollectionView.contentInset.bottom = messageToolbar.height + 10
        commentCollectionView.scrollIndicatorInsets.bottom = messageToolbar.height
    }
    
    fileprivate func cleanTextInput() {
        messageToolbar.messageTextView.text = ""
        messageToolbar.state = .beginTextInput
    }
    
    func tapToDismissMessageToolbar() {
        
    }
    

    
    func moreAction() {
        printLog("")
        
    }
    
    fileprivate func tryChangedHeaderToSmall() {
        
        guard let headerView = headerView else {
            return
        }
        
        if headerView.status == .big {
           headerView.status = .small
        }
    }
    
    fileprivate func trySnapContentOfCommentCollectionViewToBottom(needAnimation: Bool = false) {
        
//        if let lastToolbarFrame = messageToolbar.lastToobarFrame {
//            if lastToolbarFrame == messageToolbar.frame {
//                return
//            } else {
//                messageToolbar.lastToobarFrame = messageToolbar.frame
//            }
//        } else {
//            
//            messageToolbar.lastToobarFrame = messageToolbar.frame
        
//        }
        
        printLog(messageToolbar.state)
        
        printLog("contentSize = \(commentCollectionView.contentSize)")
        printLog("messageToobar.frame = \(messageToolbar.frame)")
        printLog("collectionViewOffsetY = \(commentCollectionView.contentOffset)")
        printLog("collectionViewContentInset = \(commentCollectionView.contentInset))")
        
        let newContentOffsetY = commentCollectionView.contentSize.height - messageToolbar.frame.origin.y
        
        let bottom = view.bounds.height - messageToolbar.frame.origin.y + 44
        
        guard newContentOffsetY + commentCollectionView.contentInset.top > 0  else {
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
                [weak self] in
                if let strongSelf = self  {
                    strongSelf.commentCollectionView.contentInset.bottom = bottom
                    strongSelf.commentCollectionView.scrollIndicatorInsets.bottom = bottom
                }
                
                }, completion: nil)
            
            return
        }
        
        var needDoAnimation = needAnimation
        
        let bottomInsetOffset = bottom - commentCollectionView.contentInset.bottom
        
        if bottomInsetOffset != 0 {
            needDoAnimation = true
        }
        
        if commentCollectionView.contentOffset.y != newContentOffsetY {
            needDoAnimation = true
        }
        
        guard needDoAnimation else {
            return
        }
        
        UIView.animate(withDuration: needAnimation ? 0.25 : 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
            [weak self] in
            
            if let strongSelf = self {
                strongSelf.commentCollectionView.contentInset.bottom = bottom
                strongSelf.commentCollectionView.scrollIndicatorInsets.bottom = bottom
                strongSelf.commentCollectionView.contentOffset.y = newContentOffsetY
            }
            
            }, completion: nil)
        
        delay(1) {
            
            printLog("**************************************************************")
//            printLog("newCollectionContentOffset: = \(self.commentCollectionView.contentOffset)")
            printLog(self.messageToolbar.state)
            
            printLog("contentSize = \(self.commentCollectionView.contentSize)")
            printLog("messageToobar.frame = \(self.messageToolbar.frame)")
            printLog("collectionViewOffsetY = \(self.commentCollectionView.contentOffset)")
            printLog("collectionViewContentInset = \(self.commentCollectionView.contentInset))")
        }
        
    }
    
    
   
    
    func loadNewComment() {

       
        var messageAge: MessageAge = .new
        
        let query = AVQuery(className: "DiscoverMessage")
        
        query?.limit = self.messagesBunchCount
        
        if let minMessageCreatedUnixTime = self.messages.last?.createdUnixTime {
            
            query?.whereKey("createdAt", greaterThan: minMessageCreatedUnixTime)
            
        } else {
            
            // 转圈
        }
        
        query?.findObjectsInBackground { result, error in
            
            if error != nil {
                printLog("获取失败")
            }
            
            if let leanCloudMessages = result as? [DiscoverMessage] {
                
                guard let realm = try? Realm() else  {
                    return
                }
                
                realm.beginWrite()
                
                for leanCloudMessage in leanCloudMessages {
                    
                    if let messageID = leanCloudMessage.objectId {
                        
                        var message = messageWithMessageID(messageID: messageID, inRealm: realm)
                        
                        // 先判断获取到的信息是否为自己发送，并确定是否需要删除
                        
                        let deleted = leanCloudMessage.deletedByCreator
                        
                        if deleted {
                            let leanCloudMessageCreatorObjectID = leanCloudMessage.creatUser.objectId ?? " "
                            let meObjectID = AVUser.current().objectId ?? ""
                            
                            if  leanCloudMessageCreatorObjectID == meObjectID {
                                
                                if let message = message {
                                    
                                    // TODO - 删除message附件
                                    realm.delete(message)
                                    
                                }
                            }
                        }
                        
                        
                        if message == nil {
                            
                            let newMessage = Message()
                            newMessage.messageID = messageID
                            
                            newMessage.createdUnixTime = leanCloudMessage.createdAt.timeIntervalSince1970
                            
                            if case .new = messageAge {
                                // 确保网络来的新消息比任何已有的消息都要新，防止服务器消息延后发来导致插入到当前消息上面
                                if let latestMessage = realm.objects(Message.self).sorted(byProperty: "createdUnixTime", ascending: true).last {
                                    if newMessage.createdUnixTime < latestMessage.createdUnixTime {
                                        // 只考虑最近的消息，过了可能混乱的时机就不再考虑
                                        if abs(newMessage.createdUnixTime - latestMessage.createdUnixTime) < 60 {
                                            printLog("xbefore newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
                                            newMessage.createdUnixTime = latestMessage.createdUnixTime + 0.00005
                                            printLog("xadjust newMessage.createdUnixTime: \(newMessage.createdUnixTime)")
                                        }
                                    }
                                }
                            }
                            
                            realm.add(newMessage)
                            
                            message = newMessage
                        }
                        
                        if let message = message {
                            
                             // 纪录消息的发送者
                            
                            let messageSender = leanCloudMessage.creatUser
                            
                            if let userID = messageSender.objectId {
                                
                                var sender =  userWithUserID(userID: userID, inRealm: realm)
                                
                                if sender == nil {
                                    
                                    let newUser = messageSender.converRUserModel()
                                    
                                    // TODO: 可能需要标记newuser 为陌生人
                                    
                                    realm.add(newUser)
                                    
                                    sender = newUser
                                    
                                }
                                
                                if let sender = sender {
                                    
                                    message.creatUser = sender
                                    
                                    // 查询消息来自 group 还是 user
                                    
                                    var senderFromGroup: Group? = nil
                                    
                                    let recipientType = leanCloudMessage.recipientType
                                    let recipientID = leanCloudMessage.recipientID
                                    
                                    if recipientType == "Group" {
                                        
                                        senderFromGroup = groupWithGroupID(groupID: recipientID, inRealm: realm)
                                        
                                        if senderFromGroup == nil {
                                            
                                            
                                            let newGroup = Group()
                                            newGroup.groupID = recipientID
                                            newGroup.incloudMe = true
                                            
                                            // TODO: 初次还无法确定group 类型， 下面会请求 group 信息再确认
                                            
                                            realm.add(newGroup)
                                            
                                            senderFromGroup = newGroup
                                            
                                            // 若提及我， 才同步 group 进而
                                            
                                            
                                            
                                        }
                                        
                                        
                                        
                                        
                                        
                                    }
                                    
                                    // 记录消息所属的 Conversation
                                    
                                    var conversation: Conversation?
                                    
                                    var conversationWithUser: RUser?
                                    
                                    
                                    if let senderFromGroup = senderFromGroup {
                                        conversation = senderFromGroup.conversation
                                        
                                    } else {
                                        
                                        var currentUserObjectID = ""
                                        if let currentUser = AVUser.current() {
                                            currentUserObjectID = currentUser.objectId
                                        }
                                        
                                        if sender.userID !=  currentUserObjectID {
                                            conversation = sender.conversation
                                            conversationWithUser = sender
                                            
                                        } else {
                                            
                                            if leanCloudMessage.recipientID == "" {
                                                
//                                                message.deleted
                                                return
                                            }
                                            
                                            if let user = userWithUserID(userID: leanCloudMessage.recipientID, inRealm: realm) {
                                                conversation = user.conversation
                                                conversationWithUser = user
                                                
                                            } else {
                                                
                                                let newUser = RUser()
                                                newUser.userID = leanCloudMessage.recipientID
                                                
                                                realm.add(newUser)
                                                
                                                // 网络获取这个新的 newUser 的信息
                                                
                                            }
                                            
                                            
                                            
                                        }
                                    }
                                    
                                    var createdNewConversation = false
                                    
                                    if conversation == nil {
                                        
                                        let newConversation = Conversation()
                                        
                                        if let senderFromGroup = senderFromGroup {
                                            
                                            newConversation.type = ConversationType.group.rawValue
                                            newConversation.withGroup = senderFromGroup
                                            
                                        } else {
                                            newConversation.type = ConversationType.oneToOne.rawValue
                                            newConversation.withFriend = conversationWithUser
                                            
                                        }
                                        
                                        realm.add(newConversation)
                                        
                                        conversation = newConversation
                                        
                                        createdNewConversation = true
                                    }
                                    
                                    if let conversation = conversation {
                                        
                                        // TODO :- 同步已读
                                        
//                                        if message.conversation == nil &&
//                                       
//                                        }
                                        
                                        message.conversation = conversation
                                        
                                        var sectionDateMessageID: String?
                                        
                                        tryCreatDateSectionMessage(withNewMessage: message, conversation: conversation, realm: realm, completion: {
                                            sectionDateMesage in
                                            if let sectionDateMessage = sectionDateMesage {
                                                
                                                realm.add(sectionDateMessage)
                                            }
                                            
                                            sectionDateMessageID = sectionDateMesage?.messageID
                                            
                                        })
                                        
                                        if createdNewConversation {
                                            
                                            //发送通知
                                        }
                                        
                                        if let sectionDateMessageID = sectionDateMessageID {
                                            
                                        } else {
                                            
                                        }
                                        
                                    
                                    } else {
                                        
                                        // 删除message
                                        //                                        message.deleted
                                    }
                                    
                                    
                                }
                                
                                
                                
                            }
                            
                            
                        }
                        
                    }
                    
                    try? realm.commitWrite()
                }
                
            }
                
            
            }
        
    }

    
}

public enum TimeDirection {
    
    case future(minMessageID: String)
    case past(maxMessageID: String)
    case none
    
    public var messageAge: MessageAge {
        switch self {
        case .past:
            return .old
        default:
            return .new
        }
    }
}

extension CommentViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    enum Section: Int {
        case loadPrevious
        case message
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
            
        case .loadPrevious:
            return 1
            
        case .message:
            
            return displayedMessagesRange.length
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .loadPrevious:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadMoreCollectionCellIdenfitifier, for: indexPath) as! LoadMoreCollectionViewCell
            return cell
            
        case .message:

            
            guard let message = messages[safe: indexPath.item + displayedMessagesRange.location] else {
                fatalError("messages 越界")
            }
            
            if message.mediaType == .sectionDate {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatSectionDateCellIdentifier, for: indexPath) as! ChatSectionDateCell
                
                
                let createdAt = Date(timeIntervalSince1970: message.createdUnixTime)
                
                cell.sectionDateLabel.text = sectionDateFormatter.string(from: createdAt)
                
                return cell
            }
            
            if message.isfromMe {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatRightTextCellIdentifier, for: indexPath) as! ChatRightTextCell
                
                cell.configureWithMessage(message: message, textContentLabelWidth: textContentLabelWidthOfMessage(message), mediaTapAction: nil, collectionView: collectionView, indexPath: indexPath as NSIndexPath)
                
                return cell
                
            } else {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatLeftTextCellIdentifier, for: indexPath) as! ChatLeftTextCell
                
                cell.configureWithMessage(message: message, textContentLabelWidth: textContentLabelWidthOfMessage(message), collectionView: collectionView, indexPath: indexPath as NSIndexPath)
                
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .loadPrevious:
            return UIEdgeInsets.zero
        case .message:
            return UIEdgeInsets(top: 5, left: 0, bottom: 15, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .loadPrevious:
            return CGSize(width: UIScreen.main.bounds.width, height: 20)
        case .message:
            return CGSize(width: UIScreen.main.bounds.width, height: heightOfMessage(messages[indexPath.item + displayedMessagesRange.location]))
        }
    }
    
}

extension CommentHeaderView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        printLog(scrollView.contentOffset.y)
    }
}
















