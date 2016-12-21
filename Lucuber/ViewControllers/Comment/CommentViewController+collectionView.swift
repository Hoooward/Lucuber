//
// Created by Tychooo on 16/12/13.
// Copyright (c) 2016 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloud

extension CommentViewController {
    
    func prepareCommentCollectionView() {

        commentCollectionView.keyboardDismissMode = .onDrag

        commentCollectionView.alwaysBounceVertical = true
        commentCollectionView.bounces = true

        commentCollectionView.registerNib(of: LoadMoreCollectionViewCell.self)
        commentCollectionView.registerNib(of: ChatSectionDateCell.self)

        commentCollectionView.registerClass(of: ChatLeftTextCell.self)
        commentCollectionView.registerClass(of: ChatRightTextCell.self)
        commentCollectionView.registerClass(of: ChatLeftImageCell.self)
        commentCollectionView.registerClass(of: ChatRightImageCell.self)
        commentCollectionView.registerClass(of: ChatTextIndicatorCell.self)

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
            let cell: LoadMoreCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            return cell

        case .message:

            guard let message = messages[safe: indexPath.item + displayedMessagesRange.location] else {
                fatalError("messages 越界")
            }

            if message.mediaType == MessageMediaType.sectionDate.rawValue {

                let cell: ChatSectionDateCell = collectionView.dequeueReusableCell(for: indexPath)

                return cell
            }


            if message.isfromMe {
                
                switch message.mediaType {
                    
                case MessageMediaType.image.rawValue:
                    
                    let cell: ChatRightImageCell = collectionView.dequeueReusableCell(for: indexPath)
                    
                    return cell
                
                    
                default:
                    
                    if message.deletedByCreator {
                        let cell: ChatTextIndicatorCell = collectionView.dequeueReusableCell(for: indexPath)
                        return cell
                    }
                    
                    let cell: ChatRightTextCell = collectionView.dequeueReusableCell(for: indexPath)
                    return cell
                }

            } else {

                switch message.mediaType {
                    
                case MessageMediaType.image.rawValue:
                    
                    let cell: ChatLeftImageCell = collectionView.dequeueReusableCell(for: indexPath)
                    
                    return cell
                    
                    
                default:
                    
                    if message.deletedByCreator {
                        let cell: ChatTextIndicatorCell = collectionView.dequeueReusableCell(for: indexPath)
                        return cell
                    }
                    
                    let cell: ChatLeftTextCell = collectionView.dequeueReusableCell(for: indexPath)
                    return cell
                }
            }
        }
    }
    
    func showProfileWithUsername(userName: String) {
        
    }

    func showMessageMedia(from message: Message) {

        if let messageIndex = messages.index(of: message) {

            let indexPath = IndexPath(item: messageIndex - displayedMessagesRange.location, section: Section.message.rawValue)

            if let cell = commentCollectionView.cellForItem(at: indexPath) {

                var frame = CGRect.zero
                var image: UIImage?
                var transitionView: UIView?

                if let creator = message.creator {

                    if !creator.isMe {

                        switch message.mediaType {

                        case MessageMediaType.image.rawValue:

                        let cell = cell as! ChatLeftImageCell

                        image = cell.messageImageView.image
                        transitionView = cell.messageImageView
                        frame = cell.convert(cell.messageImageView.frame, to: view)

                        // TODO: - 未来添加 Video 预览时在这里弹出
                        default:
                            break
                        }

                    } else {

                        switch message.mediaType {

                        case MessageMediaType.image.rawValue:

                            let cell = cell as! ChatRightImageCell

                            image = cell.messageImageView.image
                            transitionView = cell.messageImageView
                            frame = cell.convert(cell.messageImageView.frame, to: view)

                        default:
                            break
                        }
                    }
                }

                guard image != nil else {
                    return
                }

                let vc = UIStoryboard(name: "MediaPreview", bundle: nil).instantiateViewController(withIdentifier:
                "MediaPreviewViewController") as! MediaPreviewViewController

                let predicate = NSPredicate(format: "mediaType == %d", MessageMediaType.image.rawValue)
                let mediaMessageResult = messages.filter(predicate)
                let mediaMessages: [Message] = mediaMessageResult.map { $0 }

                if let index = mediaMessageResult.index(of: message) {
                    vc.previewMedias = mediaMessages.map { PreviewMedia.message($0) }
                    vc.startIndex = index
	                vc.isConversationDismissStyle = true
                }

                vc.previewImageViewInitalFrame = frame
                vc.topPreviewImage = message.thumbnailImage
                vc.bottomPreviewImage = image

                vc.transitionView = transitionView

                delay(0.0, clouser: {
                    transitionView?.alpha = 0
                })

                vc.afterDismissAction = { [weak self] in
                    transitionView?.alpha = 1
                    self?.view.window?.makeKeyAndVisible()
                }

                mediaPreviewWindow.rootViewController = vc
                mediaPreviewWindow.windowLevel = UIWindowLevelAlert - 1
                mediaPreviewWindow.makeKeyAndVisible()

            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }

        switch section {

        case .loadPrevious:
            break

        case .message:

            guard let message = messages[safe: indexPath.item + displayedMessagesRange.location] else {
                return
            }

            if message.mediaType == MessageMediaType.sectionDate.rawValue {

                if let cell = cell as? ChatSectionDateCell {

                    let createdAt = Date(timeIntervalSince1970: message.createdUnixTime)
                    if createdAt.isInCurrentWeek {
                        cell.sectionDateLabel.text = sectionDateInCurrentWeekFormatter.string(from: createdAt)
                    } else {
                        cell.sectionDateLabel.text = sectionDateFormatter.string(from: createdAt)
                    }
                    
                    return
                }
            }

            func prepareCell(cell: ChatBaseCell) {

                if let _  = self.conversation.withGroup {
                    cell.inGroup = true
                } else {
                    cell.inGroup = false
                }

                cell.tapAvatarAction  = { [weak self] user in
                    // TODO: - 显示用户
//                    self?.performSegue(withIdentifier: "", sender: nil)
                }

                cell.deleteMessageAction = { [weak self] in
                    self?.deleteMessage(at: indexPath, withMessage: message)
                }

                cell.reportMessageAction = { [weak self] in
                    // TODO: - 举报
                }
            }

            if message.isfromMe {

                switch message.mediaType {

                case MessageMediaType.image.rawValue:

                    if let cell = cell as? ChatRightImageCell {

                        cell.configureWithMessage(message: message, messageImagePreferredWidth: messageImagePreferredWidth, messageImagePreferredHeight: messageImagePreferredHeight, messageImagePreferredAspectRatio: messageImagePreferredAspectRatio, mediaTapAction: {
                            [weak self] in

                            if message.sendState == MessageSendState.failed.rawValue {

                                CubeAlert.confirmOrCancel(title: "失败", message: "重新发送图片?", confirmTitle: "重新发送", cancelTitles: "取消", inViewController: self , confirmAction: {


                                }, cancelAction: {

                                })

                            }

                        }, collectionView: collectionView, indexPath: indexPath)

                    }


                default:
                    if let cell = cell as? ChatRightTextCell {

                        prepareCell(cell: cell)

                        cell.configureWithMessage(message: message, textContentLabelWidth: textContentLabelWidth(of: message), mediaTapAction: nil, collectionView: collectionView, indexPath: indexPath)

                        cell.tapUsernameAction = { [weak self] name in
                            // TODO: - ShowProfileWithUsername
                        }

                        cell.tapFeedAction = { [weak self] feed in
                            // TODO: - showConversationWithFeed
                        }
                    }

                }


            } else {
                switch message.mediaType {

                case MessageMediaType.image.rawValue:

                    if let cell = cell as? ChatLeftImageCell {

                        prepareCell(cell: cell)

                        cell.configureWithMessage(message, messageImagePreferredWidth: messageImagePreferredWidth, messageImagePreferredHeight: messageImagePreferredHeight, messageImagePreferredAspectRatio: messageImagePreferredAspectRatio, mediaTapAction: {
                            [weak self] in

                            if message.downloadState == MessageDownloadState.downloaded.rawValue {

                                if let messageTextView = self?.messageToolbar.messageTextView {
                                    if messageTextView.isFirstResponder {
                                        self?.messageToolbar.state = .normal
                                        return
                                    }
                                }

                                self?.showMessageMedia(from: message)
                            }

                        }, collectionView: collectionView, indexPath: indexPath)
                    }

                default:

                    if message.deletedByCreator {
                        
                        if let cell = cell as? ChatTextIndicatorCell {
                            cell.configureWithMessage(message: message, indicateType: .recalledMessage)
                        }
                        
                    } else {
                        // TODO: - openGraphInfo

                        if let cell = cell as? ChatLeftTextCell {

                            prepareCell(cell: cell)

                            cell.configureWithMessage(message: message, textContentLabelWidth: textContentLabelWidth(of: message), collectionView: collectionView, indexPath: indexPath)

                            cell.tapUsernameAction = { [weak self] name in
                                // TODO: - ShowProfileWithUsername
                            }

                            cell.tapFeedAction = { [weak self] feed in
                                // TODO: - showConversationWithFeed
                            }
                        }
                    }
                }
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
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        
        seletedIndexPathForMenu = indexPath
        
        guard let _ = commentCollectionView.cellForItem(at: indexPath) else {
            return false
        }
        
        var title = ""
        if let message = messages[safe: (displayedMessagesRange.location + indexPath.item)] {
            
            let isMy = message.creator?.isMe ?? false
            
            if isMy {
                title = "撤回"
            } else {
                title = "隐藏"
            }
            
            let menuItems = [
                UIMenuItem(title: title, action: #selector(ChatBaseCell.deleteMessage(object:)))
            ]
            
            UIMenuController.shared.menuItems = menuItems
            
            return true
        }
        
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        if let _ = commentCollectionView.cellForItem(at: indexPath) as? ChatLeftTextCell {
            if action == #selector(NSObject.copy) {
                return true
            }
        } else if let _ = commentCollectionView.cellForItem(at: indexPath) as? ChatRightTextCell {
            if action == #selector(NSObject.copy) {
                return true
            }
        }
        
        if action == #selector(ChatBaseCell.deleteMessage(object:)) {
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        if let cell = commentCollectionView.cellForItem(at: indexPath) as? ChatLeftTextCell {
            if action == #selector(NSObject.copy) {
                UIPasteboard.general.string = cell.textContentTextView.text
            }
        } else if let cell = commentCollectionView.cellForItem(at: indexPath) as? ChatRightTextCell {
            if action == #selector(NSObject.copy) {
                UIPasteboard.general.string = cell.textContentTextView.text
            }
        }
    }
    



}
