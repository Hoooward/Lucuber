//
// Created by Tychooo on 16/12/13.
// Copyright (c) 2016 Tychooo. All rights reserved.
//

import UIKit

extension  CommentViewController {

    func send(text: String) {

        if text.isEmpty {
            return
        }

        if let withFriend = conversation.withFriend {

            pushMessageText(text, toRecipient: withFriend.lcObjcetID, recipientType: "user", afterCreatedMessage: { [weak self] message in

                self?.updateCommentCollectionViewWithMessageIDs(messagesID: nil, messageAge: .new, scrollToBottom: true, success: {
                    _ in
                })

            }, failureHandler: { [weak self] reason, errorMessage in

                defaultFailureHandler(reason, errorMessage)

                CubeAlert.alertSorry(message: "发送消息失败!\n 请点击消息重新尝试.", inViewController: self)

            }, completion: { [weak self] success in

                printLog("向朋友发送消息成功")

            })

        } else if let withGroup = conversation.withGroup {

            var recipientID = ""

            if let withFormula = withGroup.withFormula {

                recipientID = withFormula.localObjectID

            } else if let withFeed = withGroup.withFeed {

                recipientID = withFeed.lcObjectID
            }

            pushMessageText(text, toRecipient: recipientID, recipientType: "group", afterCreatedMessage: { [weak self] message in

                self?.updateCommentCollectionViewWithMessageIDs(messagesID: nil, messageAge: .new, scrollToBottom: true, success: {
                    _ in
                })

            }, failureHandler: { [weak self] reason, errorMessage in

                defaultFailureHandler(reason, errorMessage)

                CubeAlert.alertSorry(message: "发送消息失败!\n 请点击消息重新尝试.", inViewController: self)

            }, completion: { [weak self] success in

                printLog("向群组发送消息成功")

            })

        }

    }

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

