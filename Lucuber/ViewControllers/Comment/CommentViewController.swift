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
import Proposer
import UserNotifications

class CommentViewController: UIViewController {
 
    var formula: Formula?
    var feed: DiscoverFeed?

    var conversation: Conversation!
    var realm: Realm!

    var afterSentMessageAction: (() -> Void)?
    var afterDeletedFeedAction: ((String) -> Void)?
    var conversationIsDirty = false

    var seletedIndexPathForMenu: IndexPath?

    lazy var messages: Results<Message> = {
        return messagesWith(self.conversation, inRealm: self.realm)
    }()

    var displayedMessagesRange: NSRange = NSRange() {
        didSet {
            needShowLoadPreviousSection = displayedMessagesRange.length >= messagesBunchCount
        }
    }

    var needShowLoadPreviousSection: Bool = false
    var needReloadLoadPreviousSection: Bool = false

    // 上次更新 UI 时的消息数量
    var lastUpdateMessagesCount: Int = 0

    // 一次 Fetch 多少个 Message
    let messagesBunchCount = 20

    // 后台收到的消息
    var inActiveNewMessageIDSet = Set<String>()

    lazy var sectionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    lazy var sectionDateInCurrentWeekFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE HH:mm"
        return dateFormatter
    }()

    var formulaHeaderView: CommentHeaderView?
    var feedHeaderView: FeedHeaderView?
    
    var isHaveHeaderView: Bool {
        if let _ = self.formulaHeaderView { return true }
        if let _ = self.feedHeaderView { return true }
        return false
    }
    
    var headerViewHeight: CGFloat {
        if let formulaHeaderView = formulaHeaderView {
            return formulaHeaderView.bounds.height
        }
        if let feedHeaderView = feedHeaderView {
            return feedHeaderView.bounds.height
        }
        return 0
    }
    
    var draBeginLocation: CGPoint?

    @IBOutlet weak var messageToolbar: MessageToolbar!
    @IBOutlet weak var commentCollectionView: UICollectionView!
    @IBOutlet weak var messageToolbarBottomConstraints: NSLayoutConstraint!

    var commentCollectionViewHasBeenMovedToBottomOnece = false

    var checkTypingStatusTimer: Timer?
    var typingResetDelay: Float = 0

    let keyboardMan = KeyboardMan()
    var giveUpKeyboardHideAnimationWhenViewControllerDisapeear = false

    var isFirstAppear = true
    var isSubscribeViewShowing: Bool = false

    lazy var moreMessageTypeView: MoreMessageTypeView = {
	    let view = self.makeMoreMessageTypeView()
        return view
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = self.makeImagePickerController()
        return imagePicker
    }()

    lazy var titleView: ConversationTitleView = {
	    let titleView = self.makeTitleView()
        return titleView
    }()

    lazy var subscribeView: SubscribeView = {
        let subscribeView = self.makeSubscribeView()
        return subscribeView
    }()
    
    var moreViewManager: CommentMoreViewManager {
        return self.makeCommentMoreViewManager()
    }

    lazy var collectionViewWidth: CGFloat = {
        return self.commentCollectionView.bounds.width
    }()

    lazy var messageTextViewMaxWidth: CGFloat = {
        return self.collectionViewWidth - Config.chatCellGapBetweenWallAndAvatar() - Config.chatCellAvatarSize() - Config.chatCellGapBetweenTextContentLabelAndAvatar() - Config.chatTextGapBetweenWallAndContentLabel()
    }()
    
    var messageImagePreferredWidth: CGFloat {
        return Config.ChatCell.mediaPreferredWidth
    }
    
    var messageImagePreferredHeight: CGFloat {
        return Config.ChatCell.mediaPreferredHeight
    }
    
    var messageImagePreferredAspectRatio: CGFloat {
        return 4.0 / 3.0
    }

    var textContentLabelWidths = [String: CGFloat]()
    var messageCellHeights = [String: CGFloat]()

    var isLoadingPreviousMessages = false
    var noMorePreviousMessage = false
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tryShowSubscribeView()

        self.tabBarController?.tabBar.isHidden = true

        navigationController?.setNavigationBarHidden(false, animated: false)

        if isFirstAppear {

            makeFormulaHeaderView(with: formula)
            makeFeedHeaderView(with: feed)
            tryFoldHeaderView()
        }

        messageToolbar.conversation = conversation

        messageToolbar.moreMessageTypeAction = { [weak self] in

            if let window = self?.view.window {

                self?.moreMessageTypeView.show(in: window)

                if let _ = self?.messageToolbar.state {
                    self?.messageToolbar.state = .normal
                }

                delay(0.2) {
                    self?.imagePicker.hidesBarsOnTap = false
                }
            }
        }

        messageToolbar.stateTransitionAction = { [weak self] messageToolbar, previousState, currentStatue in

            switch currentStatue {

            case .beginTextInput:
                self?.tryFoldHeaderView()
                self?.trySnapContentOfCommentCollectionViewToBottom(needAnimation: true)

            case .textInputing:


                self?.trySnapContentOfCommentCollectionViewToBottom()
                break

            default:
                break
            }
        }
    }

    deinit {
        printLog("\(self)" + "已经释放")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        prepareCommentCollectionView()

        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.handelNewMessaageIDsReceviedNotification(notification:)), name: Notification.Name.newMessageIDsReceivedNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.handelApplicationDidBecomeActive(notification:)), name: Notification.Name.applicationDidBecomeActiveNotification, object: nil)

        realm = try! Realm()

        lastUpdateMessagesCount = messages.count

        if messages.count >= messagesBunchCount {
            displayedMessagesRange = NSRange(location: messages.count - messagesBunchCount, length: messagesBunchCount)
        } else {
            displayedMessagesRange = NSRange(location: 0, length: messages.count)
        }

        navigationItem.titleView = titleView
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_more"), style: .plain, target: self, action: #selector(CommentViewController.moreAction))

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
                
                let subscribeViewHeight = strongSelf.isSubscribeViewShowing ? SubscribeView.totalHeight : 0

                if strongSelf.messageToolbarBottomConstraints.constant > 0 {

                    // 第一次出现
                    if apperaPostIndex == 0 {
                        strongSelf.commentCollectionView.contentOffset.y += keyboardHeightIncrement
                    } else {
                        strongSelf.commentCollectionView.contentOffset.y += keyboardHeightIncrement
                    }

                    let bottom = keyboardHeight + strongSelf.messageToolbar.frame.height + subscribeViewHeight
                    strongSelf.commentCollectionView.contentInset.bottom = bottom
                    strongSelf.commentCollectionView.scrollIndicatorInsets.bottom = bottom
                    strongSelf.messageToolbarBottomConstraints.constant = keyboardHeight

                    strongSelf.view.layoutIfNeeded()

                } else {

                    strongSelf.commentCollectionView.contentOffset.y += keyboardHeightIncrement
                    let bottom = keyboardHeight + strongSelf.messageToolbar.frame.height + subscribeViewHeight
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

                let subscribeViewHeight = strongSelf.isSubscribeViewShowing ? SubscribeView.totalHeight : 0
     
                if strongSelf.messageToolbarBottomConstraints.constant > 0 {
                    strongSelf.commentCollectionView.contentOffset.y -= keyboardHeight

                    let bottom = strongSelf.messageToolbar.frame.height + subscribeViewHeight
                    strongSelf.commentCollectionView.contentInset.bottom = bottom
                    strongSelf.commentCollectionView.scrollIndicatorInsets.bottom = bottom
                    strongSelf.messageToolbarBottomConstraints.constant = 0
                    strongSelf.view.layoutIfNeeded()
                }
            }
        }

        tryShowSubscribeView()
        commentCollectionView.contentInset = UIEdgeInsets(top: 64 + 60 + 20, left: 0, bottom: 44, right: 0)
        print(commentCollectionView.contentInset)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tryFetchMessages()
        commentCollectionViewHasBeenMovedToBottomOnece = true

        if isFirstAppear {

            delay(0.1) {

                self.messageToolbar.textSendAction = { [weak self] messageToolbar in

                    let text = messageToolbar.messageTextView.text!.trimming(trimmingType: .whitespaceAndNewLine)

                    self?.cleanTextInput()
                    self?.trySnapContentOfCommentCollectionViewToBottom(needAnimation: true)

                    if text.isEmpty {
                        return
                    }

                    if let withFriend = self?.conversation.withFriend {

                        pushMessageText(text, toRecipient: withFriend.lcObjcetID, recipientType: "User", afterCreatedMessage: { [weak self] message in

                            self?.updateCommentCollectionViewWithMessageIDs(messagesID: nil, messageAge: .new, scrollToBottom: true, success: { _ in })

                        }, failureHandler: { reason, errorMessage in

                            defaultFailureHandler(reason, errorMessage)

                        }, completion: { _ in

                            printLog("发送成功")

                        })

                    } else if let withGroup = self?.conversation.withGroup {

                        pushMessageText(text, toRecipient: withGroup.groupID, recipientType: "group", afterCreatedMessage: { [weak self] message in

                            self?.updateCommentCollectionViewWithMessageIDs(messagesID: nil, messageAge: .new, scrollToBottom: true, success: { _ in })

                        }, failureHandler: { reason, errorMessage in

                            defaultFailureHandler(reason, errorMessage)

                            CubeAlert.alertSorry(message: "发送消息失败！\n尝试点击消息重新发送。", inViewController: self)

                        }, completion: { _ in

                            printLog("Send Text Message Success!")
                        })
                    }
                }
            }
        }

        isFirstAppear = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !commentCollectionViewHasBeenMovedToBottomOnece {
            setCommentCollectionViewOriginalContentInset()
            tryScrollToBottom()
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        switch identifier {
            
        case "showProfileView":
            let vc = segue.destination as! ProfileViewController
            
            if let user = sender as? RUser {
                // message user
                vc.prepare(withUser: user)
                
            } else {
                // headerView User
                if let creator = feed?.creator {
                    vc.prepare(with: creator)
                }
            }
            
        case "showFormulaDetail":
            let vc = segue.destination as! FormulaDetailViewController
            
            guard let feed = feed, let realm = try? Realm() else {
                return
            }
            
            var formula = feedWith(feed.objectId!, inRealm: realm)?.withFormula
            if formula == nil {
                realm.beginWrite()
                formula = vc.prepareFormulaFrom(feed, inRealm: realm)
                try? realm.commitWrite()
            }
            
            guard let resultFormula = formula else {
                return
            }
            vc.formula = resultFormula
            vc.previewFormulaStyle = .single
            
        default:
            break
        }
    }
        
    // MARK: - Action & Target
    @objc private func handelNewMessaageIDsReceviedNotification(notification: Notification) {

        guard
                let messageInfo = notification.object as? [String: Any],
                let messageIDs = messageInfo["messageIDs"] as? [String],
                let messageRawValue = messageInfo["messageAge"] as? String,
                let messageAge = MessageAge(rawValue: messageRawValue) else {
            printLog("不能 handelNewMessaageIDsReceviedNotification")
            return
        }

        handleRecievedNewMessage(messageIDs: messageIDs, messageAge: messageAge)
    }

    func handleRecievedNewMessage(messageIDs: [String], messageAge: MessageAge) {

        var newMessageIDs: [String]?

        guard let commentController = self.navigationController?.visibleViewController as? CommentViewController else {
            return
        }

        realm.refresh()

        if let conversation = conversation {
            
            if
                let conversationID = conversation.fakeID,
                let currentVisibleConversationID = commentController.conversation.fakeID {
                
                if conversationID != currentVisibleConversationID {
                    return
                }

                var filteredMessageIDs = [String]()

                for messageID in messageIDs {

                    if let message = messageWith(messageID, inRealm: realm) {
                        if let messageInConversationId = message.conversation?.fakeID {
                            if messageInConversationId == conversationID {
                                filteredMessageIDs.append(messageID)
                            }
                        }
                    }
                }
                newMessageIDs = filteredMessageIDs
            }
        }

        if UIApplication.shared.applicationState == .active {
            updateCommentCollectionViewWithMessageIDs(messagesID: newMessageIDs, messageAge: messageAge, scrollToBottom: false, success: { _ in })
        } else {


            if let newMessageIDs = newMessageIDs {
                for newMessageID in newMessageIDs {

                    inActiveNewMessageIDSet.insert(newMessageID)
                    printLog("inActiveNewMessageIDSet 插入了一条新信息 \(newMessageID)")
                }
            }
        }
    }

    func batchMarkMessgesAsreaded() {
        DispatchQueue.main.async {
            [weak self] in
            guard let _ = self else {
                return
            }
        }
    }

    func updateCommentCollectionViewWithMessageIDs(messagesID: [String]?, messageAge: MessageAge, scrollToBottom: Bool, success: @escaping (Bool) -> Void) {

        guard navigationController?.topViewController == self else {
            return
        }

        if messagesID != nil {
            batchMarkMessgesAsreaded()
        }

        let subscribeViewHeight = isSubscribeViewShowing ? SubscribeView.totalHeight : 0
        let keyboardAndToobarHeight = messageToolbarBottomConstraints.constant + messageToolbar.bounds.height + subscribeViewHeight

        var scrollToBottom = true
        if case .old = messageAge {
            scrollToBottom = false
        }

        adjustCommentCollectionViewWithMessageIDs(messageIDs: messagesID, messageAge: messageAge, adjustHeight: keyboardAndToobarHeight, scrollToBottom: scrollToBottom, success: {
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

    func adjustCommentCollectionViewWithMessageIDs(messageIDs: [String]?, messageAge: MessageAge, adjustHeight: CGFloat, scrollToBottom: Bool, success: @escaping (Bool) -> Void) {

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
                return
            }
        }

        if newMessageCount > 0 {

            if let messageIDs = messageIDs {

                var indexPaths = [IndexPath]()
                
                for messageID in messageIDs {
                    
                    if
                        let message = messageWith(messageID, inRealm: realm),
                        let index = messages.index(of: message) {
                        
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
                        }
                    })
                    break
                }
                
            } else {

                // 这里做了一个假设：本地刚创建的消息比所有的已有的消息都要新，这在创建消息里做保证（服务器可能传回创建在“未来”的消息）
                var indexPaths = [IndexPath]()

                for i in 0 ..< newMessageCount {
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
            for i in _lastTimeMessagesCount ..< messages.count {

                if let message = messages[safe: i] {
                    let height = heightOfMessage(message) + 5
                    newMessagesTotalHeight += height
                }
            }

            let keyboardAndTooBarHeight = adjustHeight
            

            let blockedHeight = 64 + (isHaveHeaderView ? headerViewHeight : 0) + keyboardAndTooBarHeight

            let visibleHeight = commentCollectionView.frame.height - blockedHeight

            let useableHeight = visibleHeight - commentCollectionView.contentSize.height

            if newMessagesTotalHeight > useableHeight {

                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {

                    [weak self] in

                    if let strongSelf = self {

                        if scrollToBottom {

                            let newContentSize = strongSelf.commentCollectionView.collectionViewLayout
                                    .collectionViewContentSize
                            let newContentOffsetY = newContentSize.height - strongSelf.commentCollectionView.frame.height + keyboardAndTooBarHeight
                            strongSelf.commentCollectionView.contentOffset.y = newContentOffsetY
                            printLog("更新 Message 后自动滚到最下方")

                        } else {

                            strongSelf.commentCollectionView.contentOffset.y += newMessagesTotalHeight
                            printLog("更新 Messaage 后调整 contentOffsetY 为之前的状态.")
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

    func tryUpdateCommentCollectionViewWith(newContentInsetbottom bottom: CGFloat, newContentOffsetY: CGFloat) {
        
        guard newContentOffsetY + commentCollectionView.contentInset.top > 0 else {
            commentCollectionView.contentInset.bottom = bottom
            commentCollectionView.scrollIndicatorInsets.bottom = bottom
            return
        }
        
        var needUpdate = false
        
        let bottomInsetOffset = bottom - commentCollectionView.contentInset.bottom
        
        if bottomInsetOffset != 0 {
            needUpdate = true
        }
        
        if commentCollectionView.contentOffset.y != newContentOffsetY {
            needUpdate = true
        }
        
        guard needUpdate else {
            return
        }
        
        commentCollectionView.contentInset.bottom = bottom
        commentCollectionView.scrollIndicatorInsets.bottom = bottom
        commentCollectionView.contentOffset.y = newContentOffsetY
    }

    func tryScrollToBottom() {
        let messageToobarTop = messageToolbarBottomConstraints.constant + messageToolbar.bounds.height

        let headerHeight: CGFloat = isHaveHeaderView ? headerViewHeight : 0
        
        let invisbleHeight = messageToobarTop + 64 + headerHeight
        let visibleHeight = commentCollectionView.frame.height - invisbleHeight

        let canScroll = visibleHeight <= commentCollectionView.contentSize.height
//        printLog("collectionViewContentSize = \(commentCollectionView.contentSize)")
        if canScroll {

            commentCollectionView.contentOffset.y = commentCollectionView.contentSize.height - commentCollectionView.frame.size.height + messageToobarTop
            commentCollectionView.contentInset.bottom = messageToobarTop
            commentCollectionView.scrollIndicatorInsets.bottom = messageToobarTop
        }

    }

    func setCommentCollectionViewOriginalContentInset() {
        let headerHeight: CGFloat = isHaveHeaderView ? headerViewHeight : 0
        commentCollectionView.contentInset.top = 64 + headerHeight + 5

        commentCollectionView.contentInset.bottom = messageToolbar.height + 10
        commentCollectionView.scrollIndicatorInsets.bottom = messageToolbar.height
    }

    func cleanTextInput() {
        messageToolbar.messageTextView.text = ""
        messageToolbar.state = .beginTextInput
    }

    func tapToDismissMessageToolbar() {

    }

    func moreAction() {
        messageToolbar.state = .normal
        if let window = view.window {
            moreViewManager.moreView.showInView(view: window)
        }
    }

    fileprivate func trySnapContentOfCommentCollectionViewToBottom(needAnimation: Bool = false) {

	    /*
        if let lastToolbarFrame = messageToolbar.lastToobarFrame {
            if lastToolbarFrame == messageToolbar.frame {
                return
            } else {
                messageToolbar.lastToobarFrame = messageToolbar.frame
            }
        } else {

            messageToolbar.lastToobarFrame = messageToolbar.frame

        }

        printLog(messageToolbar.state)

        printLog("contentSize = \(commentCollectionView.contentSize)")
        printLog("messageToobar.frame = \(messageToolbar.frame)")
        printLog("collectionViewOffsetY = \(commentCollectionView.contentOffset)")
        printLog("collectionViewContentInset = \(commentCollectionView.contentInset))")
	    */
        
        let subscribeViewHeight = isSubscribeViewShowing ? SubscribeView.totalHeight : 0

        let newContentOffsetY = commentCollectionView.contentSize.height - messageToolbar.frame.origin.y + subscribeViewHeight

        // TODO: - 这里 + 44 是干什么的
        let bottom = view.bounds.height - messageToolbar.frame.origin.y + 44

        guard newContentOffsetY + commentCollectionView.contentInset.top > 0  else {

            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
                [weak self] in
                if let strongSelf = self {
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

	        /*
            printLog("**************************************************************")
            printLog("newCollectionContentOffset: = \(self.commentCollectionView.contentOffset)")
            printLog(self.messageToolbar.state)
            printLog("contentSize = \(self.commentCollectionView.contentSize)")
            printLog("messageToobar.frame = \(self.messageToolbar.frame)")
            printLog("collectionViewOffsetY = \(self.commentCollectionView.contentOffset)")
            printLog("collectionViewContentInset = \(self.commentCollectionView.contentInset))")
            */
        }
    }

    func deleteMessage(at indexPath: IndexPath, withMessage message: Message) {

        DispatchQueue.main.async { [weak self] in

            if let strongSelf = self, let realm = message.realm {

                let isMyMessage = message.creator?.isMe ?? false

                // 先判断上一条 Message 是不是 SecitonMessage
                var sectionDateMessage: Message?

                if let currentMessageIndex = strongSelf.messages.index(of: message) {

                    let previousMessageIndex = currentMessageIndex - 1

                    if let previousMessage = strongSelf.messages[safe: previousMessageIndex]{

                        if previousMessage.mediaType == MessageMediaType.sectionDate.rawValue {
                            sectionDateMessage = previousMessage
                        }
                    }
                }

                let currentIndexPath: IndexPath
                if let index = strongSelf.messages.index(of: message) {
                    currentIndexPath =  IndexPath(item: index - strongSelf.displayedMessagesRange.location, section: indexPath.section)
                } else {
                    currentIndexPath = indexPath
                }

                if let sectionDateMessage = sectionDateMessage {

                    var canDeleteTowMessages = false

                    if strongSelf.displayedMessagesRange.length >= 2 {
                        strongSelf.displayedMessagesRange.length -= 2
                        canDeleteTowMessages = true

                    } else {
                        if strongSelf.displayedMessagesRange.location >= 1 {
                            strongSelf.displayedMessagesRange.location -= 1
                        }
                        strongSelf.displayedMessagesRange.length -= 1
                    }

                    if isMyMessage {
                        
                        let messageID = message.lcObjectID
                        
                        
                        try? realm.write {
                            message.deleteAttachment(inRealm: realm)
                            realm.delete(sectionDateMessage)
                            realm.delete(message)
                        }
                        
                        deleteMessageFromServer(messageID: messageID, failureHandler: {
                            reason, errorMessage in
                            defaultFailureHandler(reason, errorMessage)
                            
                        }, completion: {
                            printLog("删除 Message 成功")
                        })
                        
                    } else {
                        
                        try? realm.write {
                            message.hidden = true
                        }
                    }

                    if canDeleteTowMessages {
                        let previousIndexPath = IndexPath(item: currentIndexPath.item - 1, section: currentIndexPath.section)
                        strongSelf.commentCollectionView.deleteItems(at: [previousIndexPath, currentIndexPath])

                    } else {
                        strongSelf.commentCollectionView.deleteItems(at: [currentIndexPath])
                    }
                    
                } else {
                    
                    strongSelf.displayedMessagesRange.length -= 1
                    
                    if isMyMessage {
                        
                        let messageID = message.lcObjectID
                        
                        
                        try? realm.write {
                            message.deleteAttachment(inRealm: realm)
                            realm.delete(message)
                        }
                        
                        deleteMessageFromServer(messageID: messageID, failureHandler: {
                            reason, errorMessage in
                            defaultFailureHandler(reason, errorMessage)
                            
                        }, completion: {
                            printLog("删除 Message 成功")
                        })
                        
                    } else {
                        try? realm.write {
                            message.hidden = true
                        }
                    }
                    
                    strongSelf.commentCollectionView.deleteItems(at: [currentIndexPath])
                }
                
                strongSelf.lastUpdateMessagesCount = strongSelf.messages.count
            }
        }
    }

    // 应用进入前台时, 插入后台状态收到的消息
    @objc private func handelApplicationDidBecomeActive(notification: Notification) {
		guard UIApplication.shared.applicationState == .active else {
            return
        }
		tryInsertInActiveNewMessage()
        tryFetchMessages()
    }

    private func tryInsertInActiveNewMessage() {

        if inActiveNewMessageIDSet.count > 0 {
            updateCommentCollectionViewWithMessageIDs(messagesID: Array(inActiveNewMessageIDSet), messageAge: .new, scrollToBottom: false, success: { _ in
            })

            inActiveNewMessageIDSet = []
            printLog("已插入后台接受的 Message")
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

extension CommentViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        let location = scrollView.panGestureRecognizer.location(in: view)
        self.draBeginLocation = location

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if let dragBeginLocation = self.draBeginLocation {

            let location = scrollView.panGestureRecognizer.location(in: view)
            let deltaY = location.y - dragBeginLocation.y

            if deltaY < -30 {
                tryFoldHeaderView()
            }
        }

        guard !noMorePreviousMessage else {
//            printLog("从上一次网络请求过去的 Message 得知已没有更旧的数据")
            return
        }

        guard scrollView.isAtTop && (scrollView.isDragging || scrollView.isDecelerating) else {
            return
        }

        let indexPath = IndexPath(item: 0, section: Section.loadPrevious.rawValue)
        guard let cell = commentCollectionView.cellForItem(at: indexPath) as? LoadMoreCollectionViewCell else {
            return
        }

        guard !isLoadingPreviousMessages else {
            cell.loadingActivityIndicator.stopAnimating()
            return
        }

        cell.loadingActivityIndicator.startAnimating()

        delay(0.5) {
            [weak self] in

            self?.tryLoadPreviousMessage(completion: { [weak cell] in
                cell?.loadingActivityIndicator.stopAnimating()

            })
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        draBeginLocation = nil
    }

}
















