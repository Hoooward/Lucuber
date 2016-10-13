//
//  CommentViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/10/8.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import AVOSCloudIM

//class FormulaComment: AVObject, AVSubclassing {
//    
//    ///对哪个公式的评论
//    static let FormulaCommentKey_atFormula = "atFormulaName"
//    @NSManaged var atFormulaName: String?
//    
//    /// 评论内容
//    static let FormulaCommentKey_author = "author"
//    @NSManaged var content: String?
//    
//    /// 被喜欢
//    static let FormulaCommentKey_likeCount = "likeCount"
//    @NSManaged var likeCount: Int
//    
//    /// 评论作者
//    static let FormulaCommentkey_author = "author"
//    @NSManaged var author: AVUser?
//    
//    ///新公式文本
//    static let FormulaCommetnKey_fromulaText = "formulaText"
//    @NSManaged var formulaText: String?
//    
//    class func parseClassName() -> String {
//        return "FormulaComment"
//    }
//    
//    /*
//     init(author: AVUser?, content: String, formulaString: String?, likeCount: Int = 0) {
//     self.author = author
//     self.content = content
//     self.formulaString = formulaString
//     self.likeCount = likeCount
//     
//     super.init()
//     }
//     */
//}

//extension FormulaComment {
//    class func CuberFormulaCommentQueryIncludeKeys() -> [String] {
//        return [FormulaCommentKey_author, FormulaCommentKey_atFormula]
//    }
//}
//
class CommentViewController: UIViewController {
    
    var formula: Formula?
    
    
    private lazy var sectionDateFormatter: DateFormatter =  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    private lazy var sectionDateInCurrentWeekFormatter: DateFormatter =  {
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
    
    // MARK: - Life Cycle
    fileprivate lazy var collectionViewWidth: CGFloat = {
        return self.commentCollectionView.bounds.width
    }()
    
    fileprivate lazy var messageTextViewMaxWidth: CGFloat = {
        return self.collectionViewWidth - Config.chatCellGapBetweenWallAndAvatar() - Config.chatCellAvatarSize() - Config.chatCellGapBetweenTextContentLabelAndAvatar() - Config.chatTextGapBetweenWallAndContentLabel()
    }()
    
    @IBOutlet weak var messageToolbar: MessageToolbar!
    @IBOutlet weak var commentCollectionView: UICollectionView!
    @IBOutlet weak var messageToolbarBottomConstraints: NSLayoutConstraint!
    
    private let keyboardMan = KeyboardMan()
    private var giveUpKeyboardHideAnimationWhenViewControllerDisapeear = false
    
    fileprivate let loadMoreCollectionCellIdenfitifier = "LoadMoreCollectionViewCell"
    fileprivate let chatSectionDateCellIdentifier = "ChatSectionDateCell"
    fileprivate let chatLeftTextCellIdentifier = "ChatLeftTextCell"
    fileprivate let chatRightTextCellIdentifier = "ChatRightTextCell"
    fileprivate let chatLeftImageCellIdentifier = "ChatLeftImageCell"
    fileprivate let chatRightImageCellIdentifier = "ChatRightImageCell"
    
    private var textContentLabelWidths = [String: CGFloat]()
    fileprivate func textContentLabelWidthOfMessage(_ message: Message) -> CGFloat {
        
        if let key = message.objectId {
            
            if let textContentLabelWidth = textContentLabelWidths[key] {
                return textContentLabelWidth
            }
        }
        
        let rect = (message.textContent as NSString).boundingRect(with: CGSize(width: messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Config.ChatCell.textAttributes, context: nil)
        
        let width = ceil(rect.width)
        
        if let key = message.objectId {
            
            textContentLabelWidths[key] = width
        }
        
        return width
        
    }
    
    private var messageCellHeights = [String: CGFloat]()
    fileprivate func heightOfMessage(_ message: Message) -> CGFloat {
        
        if let key = message.objectId {
            
            if let height = messageCellHeights[key] {
                return height
            }
        }
        
        var height: CGFloat = 0
        
        switch message.mediaType {
            
        case .text:
            
            let rect = (message.textContent as NSString).boundingRect(with: CGSize(width: messageTextViewMaxWidth, height: CGFloat(FLT_MAX)), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: Config.ChatCell.textAttributes, context: nil)
            
            height = max(ceil(rect.height) + (11 * 2), Config.chatCellAvatarSize())
            
            if let key = message.objectId {
                textContentLabelWidths[key] = ceil(rect.width)
            }
            
            
            // TODO: - 图片的 message 高度并未处理
            
            
        default:
            break
            
        }
        
        return height
    }
    
//    var client: AVIMClient?
    
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
    
    private var commentCollectionViewHasBeenMovedToBottomOnece = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !commentCollectionViewHasBeenMovedToBottomOnece {
            
            setCommentCollectionViewOriginalContentInset()
            
            tryScrollToBottom()
            
        }
    }
    
    
    private func setCommentCollectionViewOriginalContentInset() {
        
        let headerHeight: CGFloat = headerView == nil ? 0 : headerView!.height
        commentCollectionView.contentInset.top = 64 + headerHeight + 5
        
        commentCollectionView.contentInset.bottom = messageToolbar.height + 10
        commentCollectionView.scrollIndicatorInsets.bottom = messageToolbar.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        
        
        loadNewComment()
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
                    
                    guard let currentUser = AVUser.current() else { return }
                    
                    guard let formula = self?.formula else { return }
                    
                    
                    let newMessage = Message()
                    newMessage.textContent = text
                    newMessage.mediaType = .text
                    newMessage.creatUser = currentUser
                    newMessage.invalidated = true
                    newMessage.sendState =  MessageSendState.notSend.rawValue
                    newMessage.atObjectID = formula.objectID
                    
                    newMessage.saveInBackground {
                        successed, error in
                        
                        if error != nil {
                            printLog("发送失败")
                            // 标记发送失败
                            newMessage.sendState = MessageSendState.failed.rawValue
                            
                            //保存发送失败信息
                        
                        }
                        
                        if successed {
                            printLog("发送成功")
                           
                            self?.messages.append(newMessage)
                            
                            printLog("插入新 Message 前的 ContentSize = \(self?.commentCollectionView.contentSize)")
                            
//                            self?.commentCollectionView.reloadData()
                            
                            
                            
                            
//                            self?.commentCollectionView.reloadItems(at: [indexPath])
                            
//                            self?.commentCollectionView.layoutIfNeeded()
//                            self?.commentCollectionView.sizeToFit()
                            
//                            self?.commentCollectionView.collectionViewLayout.prepare()
                            
                            self?.commentCollectionView.performBatchUpdates({
                                
                                let indexPath = IndexPath(item: self!.messages.count - 1, section: 1)
                                
                                self?.commentCollectionView.insertItems(at: [indexPath])
                                
                                }, completion: {_ in
                                    
                                    self?.trySnapContentOfCommentCollectionViewToBottom(needAnimation: true)
                                    
                                    printLog("插入新 Message 后的 ContentSize = \(self?.commentCollectionView.contentSize)")
                            })
                            
                            
//                            delay(2){
                            
//                            }
                            
                        }
                        
                        
                    }
                    
                    
                    
                }
                
            }
        }
        
    }
    
    fileprivate func cleanTextInput() {
        messageToolbar.messageTextView.text = ""
        messageToolbar.state = .beginTextInput
    }
    
    func tapToDismissMessageToolbar() {
        
    }
    
//    func updateCommentCollectionViewWithMessageIDs
    
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
    
    
    
    var messages: [Message] = []
    
    func loadNewComment() {
        
        let query = AVQuery(className: "Message")
        query?.addDescendingOrder("creatAt")
        
        guard let formula = formula else { return }
        query?.whereKey("atObjectID", equalTo: formula.objectID)
        
        query?.findObjectsInBackground {
            result, error in
            
            if error != nil {
                
                printLog("获取Message失败")
            }
            
            if let messages = result as? [Message] {
                
                let oldMessages = self.messages
                
                self.messages = messages
                
                _ = oldMessages.map {
                    self.messages.append($0)
                }
                
                self.commentCollectionView.reloadData()
                delay(2) {
                    
                    self.tryScrollToBottom()
                }
                
                
            }
            
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
            
            return messages.count
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
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatSectionDateCellIdentifier, for: indexPath)
            
//            return cell
            
            guard let message = messages[safe: indexPath.item] else {
                fatalError("messages 越界")
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
            return CGSize(width: UIScreen.main.bounds.width, height: heightOfMessage(messages[indexPath.item]))
        }
    }
    
}

extension CommentHeaderView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        printLog(scrollView.contentOffset.y)
    }
}
















