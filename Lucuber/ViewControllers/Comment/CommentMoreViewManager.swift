//
//  CommentViewMoreViewManager.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/20.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import AVOSCloud

final class CommentMoreViewManager {
    
    var conversation: Conversation?
    
    public var toggleSwitchNotification: ((Bool) -> Void)?
    public var toggleSubscribeAction: (() -> Void)?
    public var reportAction: (() -> Void)?

    private func makeSubscribeGroupItem() -> ActionSheetView.Item {
        var isSubscribe = false
        if let group = self.conversation?.withGroup {
            isSubscribe = group.includeMe
        }
        return ActionSheetView.Item.Default(
            title: isSubscribe ? "取消订阅" : "订阅",
            titleColor: UIColor.cubeTintColor(),
            action: { [weak self] in
                self?.toggleSubscribeAction?()
                return true
            }
        )
    }
    
    private func makeSwitchNotificationItem() -> ActionSheetView.Item {
        var notificationEnabled = false
        if let group = self.conversation?.withGroup {
            notificationEnabled = group.notificationEnabled
        }
        return .Switch(
            title: "推送通知",
            titleColor: UIColor.darkGray,
            switchOn: notificationEnabled,
            action: { [weak self] switchOn in
                self?.toggleSwitchNotification?(switchOn)
            }
        )
    }

    public lazy var moreView: ActionSheetView = {
        
        let reportItem = ActionSheetView.Item.Default(
            title: "举报",
            titleColor: UIColor.red,
            action: { [weak self] in
                self?.reportAction?()
                return true
            }
        )

        let cancelItem = ActionSheetView.Item.Cancel
        
        let notificationItem = self.makeSwitchNotificationItem()
       
        let subscribeGroupItem = self.makeSubscribeGroupItem()

        let view: ActionSheetView = ActionSheetView(items: [
                notificationItem,
                subscribeGroupItem,
                reportItem,
                cancelItem
        ])

        return view
    }()
}
