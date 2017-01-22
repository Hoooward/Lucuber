//
//  WeChatActivity.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/22.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import MonkeyKing

final class WeChatActivity: AnyActivity {
    
    enum `Type` {
        case session
        case timeline
        
        
        var activityType: UIActivityType {
            switch self {
            case .session:
                return UIActivityType(rawValue: Config.SocialNetwork.WeChat.sessionType)             case .timeline:
                return UIActivityType(rawValue: Config.SocialNetwork.WeChat.timelineType)
            }
        }
        
        var title: String {
            switch self {
            case .session:
                return Config.SocialNetwork.WeChat.sessionTitle
            case .timeline:
                return Config.SocialNetwork.WeChat.timelineTitle
            }
        }
        
        var image: UIImage {
            switch self {
            case .session:
                return Config.SocialNetwork.WeChat.sessionImage
            case .timeline:
                return Config.SocialNetwork.WeChat.timelineImage
            }
        }
    }
    
    init(type: Type, message: MonkeyKing.Message, completionHandler: @escaping MonkeyKing.DeliverCompletionHandler) {
        
        MonkeyKing.registerAccount(.weChat(appID: Config.SocialNetwork.WeChat.appID, appKey: ""))
        
        super.init(type: type.activityType, title: type.title, image: type.image, message: message, completionHandler: completionHandler)
    }
}
