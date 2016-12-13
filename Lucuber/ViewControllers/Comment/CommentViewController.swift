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

class CommentViewController: UIViewController {

    var formula: Formula?
    var feed: DiscoverFeed?

    var conversation: Conversation!

    var afterSentMessageAction: (() -> Void)?
    var afterDeletedFeedAction: ((String) -> Void)?
    var conversationIsDirty = false

    fileprivate var seletedIndexPathForMenu: IndexPath?

    fileprivate var realm: Realm!

    fileprivate lazy var messages: Results<Message> = {

        return messagesWith(self.conversation, inRealm: self.realm)
    }()

    fileprivate var displayedMessagesRange: NSRange = NSRange() {
        didSet {
            needShowLoadPreviousSection = displayedMessagesRange.length >= messagesBunchCount
        }
    }

    fileprivate var needShowLoadPreviousSection: Bool = false
    fileprivate var needReloadLoadPreviousSection: Bool = false

    // 上次更新 UI 时的消息数量
    fileprivate var lastUpdateMessagesCount: Int = 0

    // 一次 Fetch 多少个 Message
    fileprivate let messagesBunchCount = 20

    // 后台收到的消息
    fileprivate var inActiveNewMessageIDSet = Set<String>()

    fileprivate lazy var sectionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    fileprivate lazy var sectionDateInCurrentWeekFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE HH:mm"
        return dateFormatter
    }()

    var headerView: CommentHeaderView?
    var draBeginLocation: CGPoint?

    @IBOutlet weak var messageToolbar: MessageToolbar!
    @IBOutlet weak var commentCollectionView: UICollectionView!
    @IBOutlet weak var messageToolbarBottomConstraints: NSLayoutConstraint!

    fileprivate var commentCollectionViewHasBeenMovedToBottomOnece = false

    fileprivate var checkTypingStatusTimer: Timer?
    fileprivate var typingResetDelay: Float = 0

    private let keyboardMan = KeyboardMan()
    private var giveUpKeyboardHideAnimationWhenViewControllerDisapeear = false

    var isFirstAppear = true

    fileprivate lazy var moreMessageTypeView: MoreMessageTypeView = {
        let view = MoreMessageTypeView()

        view.alertCanNotAccessPhotoLibraryAction = { [weak self] in
            self?.alertCanNotOpenPhotoLibrary()
        }

        view.sendImageAction = { [weak self] image in
            self?.sendImage(image)
        }

        view.takePhotoAction = { [weak self] in

            let openCamera: ProposerAction = { [weak self] in

                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    self?.alertCanNotOpenCamera()
                    return
                }
                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .camera
                    strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                }
            }

            proposeToAccess(.camera, agreed: openCamera, rejected: {
                self?.alertCanNotOpenCamera()
            })
        }

        view.choosePhotoAction = { [weak self] in

            let openPhotoLibrary: ProposerAction = { [weak self] in

                guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                    self?.alertCanNotOpenPhotoLibrary()
                    return
                }

                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .photoLibrary
                    strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                }
            }

            proposeToAccess(.photos, agreed: openPhotoLibrary, rejected: {
                self?.alertCanNotOpenPhotoLibrary()
            })
        }

        view.pickLocationAction = { [weak self] in
            // TODO: - PickLocation
//            self?.performSegue(withIdentifier: "", sender: nil)
        }

        return view
    }()

    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
//        imagePicker.mediaTypes =  [kUTTypeImage as String, kUTTypeMovie as String]
        imagePicker.videoQuality = .typeMedium
        imagePicker.allowsEditing = false
        return imagePicker
    }()



    private lazy var titleView: ConversationTitleView = {
        let titleView = ConversationTitleView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 44)))

        if let title = titleName(of: self.conversation) {
            titleView.nameLabel.text = title
        } else {
            titleView.nameLabel.text = "讨论"
        }

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

        titleView.stateInfoLabel.textColor = UIColor.gray
        titleView.stateInfoLabel.text = "上次见是一周以前"

        return titleView
    }()

    // TODO: - 更新 TitleViewInfo
    fileprivate func updateInfoOfTitleView(titleView: ConversationTitleView) {
        guard !self.conversation.isInvalidated else {
            return
        }
    }

    fileprivate lazy var collectionViewWidth: CGFloat = {
        return self.commentCollectionView.bounds.width
    }()

    fileprivate lazy var messageTextViewMaxWidth: CGFloat = {
        return self.collectionViewWidth - Config.chatCellGapBetweenWallAndAvatar() - Config.chatCellAvatarSize() - Config.chatCellGapBetweenTextContentLabelAndAvatar() - Config.chatTextGapBetweenWallAndContentLabel()
    }()

    private var textContentLabelWidths = [String: CGFloat]()
    fileprivate func textContentLabelWidthOfMessage(_ message: Message) -> CGFloat {

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

    private var messageCellHeights = [String: CGFloat]()
    fileprivate func heightOfMessage(_ message: Message) -> CGFloat {

        let key = message.localObjectID

        if let height = messageCellHeights[key] {
            return height
        }

        var height: CGFloat = 0

        let type = MessageMediaType(rawValue: message.mediaType)!

        switch type {

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

//                printLog(self?.commentCollectionView.contentInset)

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

//                printLog(self?.commentCollectionView.contentInset)


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


    fileprivate var isLoadingPreviousMessages = false
    fileprivate var noMorePreviousMessage = false
    fileprivate func tryLoadPreviousMessage(completion: @escaping () -> Void) {

        if isLoadingPreviousMessages {
            return
        }

        isLoadingPreviousMessages = true

        printLog("准备加载旧Message")

        if displayedMessagesRange.location == 0 {

            printLog("从网络加载过去的 Message")


            if let recipiendID = self.conversation.recipiendID {
                var firstMessage: Message?
                if let minMessage = self.messages.first {
                    firstMessage = minMessage
                }

                fetchMessage(withRecipientID: recipiendID, messageAge: .old, lastMessage: nil, firstMessage: firstMessage, failureHandler: { [weak self] reason, errorMessage in

                    self?.isLoadingPreviousMessages = false
                    completion()
                    defaultFailureHandler(reason, errorMessage)

                }, completion: { [weak self] newMessageID in

                    tryPostNewMessageReceivedNotification(withMessageIDs: newMessageID, messageAge: .old)

                    self?.isLoadingPreviousMessages = false

                    if newMessageID.isEmpty {
                        self?.noMorePreviousMessage = true
                        printLog("网络上没有更旧的 Message")
                    } else {
                        printLog("从网络加载过去的 Message 成功.")
                    }
                    completion()
                })
            }

        } else {

            printLog("从本地 Realm 中加载过去的 Message")
            var newMessageCount = self.messagesBunchCount

            if displayedMessagesRange.location - newMessageCount < 0 {
                newMessageCount = displayedMessagesRange.location
            }

            if newMessageCount > 0 {
                self.displayedMessagesRange.location -= newMessageCount
                self.displayedMessagesRange.length += newMessageCount

                self.lastUpdateMessagesCount = self.messages.count

                var indexPaths = [IndexPath]()
                for i in 0 ..< newMessageCount {

                    let indexPath = IndexPath(item: i, section: Section.message.rawValue)
                    indexPaths.append(indexPath)
                }

                let bottomOffset = self.commentCollectionView.contentSize.height - self.commentCollectionView.contentOffset.y
//                
//                printLog("当前的contentSize: \(self.commentCollectionView.contentSize)")
//                printLog("当前的ContentOffset: \(self.commentCollectionView.contentOffset)")
                CATransaction.begin()
                CATransaction.setDisableActions(true)

                self.commentCollectionView.performBatchUpdates({
                    [weak self] in
                    self?.commentCollectionView.insertItems(at: indexPaths)

                }, completion: {
                    [weak self] finished in
                    guard let strongSelf = self else {
                        return
                    }
//                        printLog("插入之后的contentSize: \(self?.commentCollectionView.contentSize)")
//                        printLog("插入之后的ContentOffset: \(self?.commentCollectionView.contentOffset)")
                    var contentOffset = strongSelf.commentCollectionView.contentOffset
                    contentOffset.y = strongSelf.commentCollectionView.contentSize.height - bottomOffset

                    strongSelf.commentCollectionView.setContentOffset(contentOffset, animated: false)

                    CATransaction.commit()

                    // 上面的 CATransaction 保证了 CollectionView 在插入后不闪动

                    self?.isLoadingPreviousMessages = false
                    completion()
                    printLog("从本地加载过去的 Message 成功.")
                })

            }
        }

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

        if isFirstAppear {
//            if let feed = conversation.withGroup?.withFeed {
//                // TODO: - setup header View
//            }
        }

        messageToolbar.conversation = conversation

        // MARK: - Make MessageToolbar Action

        messageToolbar.moreMessageTypeAction = { [weak self] in

            if let window = self?.view.window {

                self?.moreMessageTypeView.show(in: window)

                if let state = self?.messageToolbar.state {
                    self?.messageToolbar.state = .normal
                }

                delay(0.2) {
                    self?.imagePicker.hidesBarsOnTap = false
                }

            }

        }

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


    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.handelNewMessaageIDsReceviedNotification(notification:)), name: Notification.Name.newMessageIDsReceivedNotification, object: nil)

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

        let syncMessages: (_ failedAction: (() -> Void)?, _ successAction: (() -> Void)?) -> Void = { failedAction, successAction in


            guard let recipiendID = self.conversation.recipiendID else {
                return
            }

            var lastMessage: Message?
            if let maxMessage = self.messages.last {
                lastMessage = maxMessage
            }

            fetchMessage(withRecipientID: recipiendID, messageAge: .new, lastMessage: lastMessage, firstMessage: nil, failureHandler: {
                reason, errorMessage in
                defaultFailureHandler(reason, errorMessage)

                failedAction?()
            }, completion: { newMessageID in

                tryPostNewMessageReceivedNotification(withMessageIDs: newMessageID, messageAge: .new)

            })

        }


        switch conversation.type {

        case ConversationType.oneToOne.rawValue:

            printLog("进入新的 Conversation ->> 开始同步最新的 Message")
            syncMessages({

                printLog("获取数据失败")
            }, {

            })


        case ConversationType.group.rawValue:

            printLog("进入新的 Conversation ->> 开始同步最新的 Message")
            syncMessages({

                printLog("获取数据失败")
            }, {

            })


        default:
            break
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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

    private func handleRecievedNewMessage(messageIDs: [String], messageAge: MessageAge) {

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
            updateCommentCollectionViewWithMessageIDs(messagesID: newMessageIDs, messageAge: messageAge, scrollToBottom: false, success: { _ in

            })

        } else {


            if let newMessageIDs = newMessageIDs {
                for newMessageID in newMessageIDs {

                    inActiveNewMessageIDSet.insert(newMessageID)
                    printLog("inActiveNewMessageIDSet 插入了一条新信息 \(newMessageID)")

                }
            }
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


    func updateCommentCollectionViewWithMessageIDs(messagesID: [String]?, messageAge: MessageAge, scrollToBottom: Bool, success: @escaping (Bool) -> Void) {

        guard navigationController?.topViewController == self else {
            return
        }

        if messagesID != nil {
            // 标记已读
            batchMarkMessgesAsreaded()
        }


        let keyboardAndToobarHeight = messageToolbarBottomConstraints.constant + messageToolbar.bounds.height

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

    private func adjustCommentCollectionViewWithMessageIDs(messageIDs: [String]?, messageAge: MessageAge, adjustHeight: CGFloat, scrollToBottom: Bool, success: @escaping (Bool) -> Void) {

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

                printLog("self message")

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

            let blockedHeight = 64 + (headerView != nil ? headerView!.height : 0) + keyboardAndTooBarHeight

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


    fileprivate func tryScrollToBottom() {

        let messageToobarTop = messageToolbarBottomConstraints.constant + messageToolbar.bounds.height

        let headerHeight: CGFloat = headerView == nil ? 0 : headerView!.height
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

//        printLog(messageToolbar.state)
//        
//        printLog("contentSize = \(commentCollectionView.contentSize)")
//        printLog("messageToobar.frame = \(messageToolbar.frame)")
//        printLog("collectionViewOffsetY = \(commentCollectionView.contentOffset)")
//        printLog("collectionViewContentInset = \(commentCollectionView.contentInset))")

        let newContentOffsetY = commentCollectionView.contentSize.height - messageToolbar.frame.origin.y

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

//            printLog("**************************************************************")
////            printLog("newCollectionContentOffset: = \(self.commentCollectionView.contentOffset)")
//            printLog(self.messageToolbar.state)
//            
//            printLog("contentSize = \(self.commentCollectionView.contentSize)")
//            printLog("messageToobar.frame = \(self.messageToolbar.frame)")
//            printLog("collectionViewOffsetY = \(self.commentCollectionView.contentOffset)")
//            printLog("collectionViewContentInset = \(self.commentCollectionView.contentInset))")
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

            if message.mediaType == MessageMediaType.sectionDate.rawValue {

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
                tryChangedHeaderToSmall()

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
















