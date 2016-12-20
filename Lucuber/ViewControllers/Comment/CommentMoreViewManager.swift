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
    
    var toggleSubscribeAction: ((Bool) -> Void)?
    var reportAction: (() -> Void)?

    private func makeSubscribeGroupItem(notificationEnabled: Bool) -> ActionSheetView.Item {
        return .Switch(
            title: "推送通知",
            titleColor: UIColor.darkGray,
            switchOn: notificationEnabled,
            action: { [weak self] switchOn in
                self?.toggleSubscribeAction?(switchOn)
            }
        )
    }

    lazy var moreView: ActionSheetView = {

        let reportItem = ActionSheetView.Item.Default(
            title: "举报",
            titleColor: UIColor.cubeTintColor(),
            action: { [weak self] in
                self?.reportAction?()
                return true
            }
        )

        let cancelItem = ActionSheetView.Item.Cancel

        var isSubscribe = false
		if let group = self.conversation?.withGroup {
            isSubscribe = group.includeMe
        }

//        if let channels = currentUserInstallation.channels as? [String] {
//            let channelsSet: Set<String> = Set(channels.map { $0 })
//            if channelsSet.contains(groupID) {
//                isSubscribe = true
//            }
//        }

        let subscribeGroupItem = self.makeSubscribeGroupItem(notificationEnabled: isSubscribe)

        let view: ActionSheetView = ActionSheetView(items: [
                subscribeGroupItem,
                reportItem,
                cancelItem
        ])

        return view
        
    }()
    
    

}
