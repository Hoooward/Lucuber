//
// Created by Tychooo on 16/12/13.
// Copyright (c) 2016 Tychooo. All rights reserved.
//

import UIKit

extension  CommentViewController {

    public func sendImage(_ image: UIImage) {

        let imageData = UIImageJPEGRepresentation(image, 0.95)!

        let messageImageName = UUID().uuidString

        if let withGroup = conversation.withGroup {

            pushMessageImage(atPath: nil, orFileData: imageData, metaData: nil, toRecipient: withGroup.groupID, recipientType: "group", afterCreatedMessage: { [weak self] message in

                DispatchQueue.main.async {
                    if let _ = FileManager.saveMessageImageData(imageData, withName: messageImageName) {
                        if let realm = message.realm {

                            try? realm.write {
                                message.localAttachmentName = messageImageName
                                message.mediaType = MessageMediaType.image.rawValue
                            }
                        }
                    }

                    self?.updateCommentCollectionViewWithMessageIDs(messagesID: nil, messageAge: .new, scrollToBottom: true, success: { _ in
                    })
                }

            }, failureHandler: { [weak self] reason, errorMessage in

                defaultFailureHandler(reason, errorMessage)

                CubeAlert.alertSorry(message: "发送图片失败!\n 尝试点击图片重试", inViewController: self)

            }, completion: { success in
                printLog("发送 Message 成功")
            })

        } else {
            // TODO: - 与朋友聊天时发送 图片
        }

    }

}

