//
//  Helper.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import Navi

public func printLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
    
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)]:\(message)")
    #endif
}

public func delay(_ delay: Double, clouser: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        clouser()
    }
}

public enum ErrorCode: String {
    case blockedByRecipient = "rejected_your_message"
    case notYetRegistered = "not_yet_registered"
    case userWasBlocked = "user_was_blocked"
    case userIsRegister = "手机号码已经注册"
}

public enum Reason: CustomStringConvertible {
    case network(Error?)
    case noData
    case noSuccessStatusCode(statusCode: Int, errorCode: ErrorCode?)
    case noSuccess
    case other(NSError?)
    
    public var description: String {
        switch self {
        case .network(let error):
            return "Network, Error: \(error)"
        case .noData:
            return "NoData"
        case .noSuccessStatusCode(let statusCode):
            return "NoSuccessStatusCode: \(statusCode)"
        case .noSuccess:
            return "NoSuccess"
        case .other(let error):
            return "Other, Error: \(error)"
        }
    }
}

public typealias FailureHandler = (_ reason: Reason, _ errorMessage: String?) -> Void

public let defaultFailureHandler: FailureHandler = { (reason, errorMessage) in
    print("\n***************************** Lucuber Failure *****************************")
    print("Reason: \(reason)")
    if let errorMessage = errorMessage { print("errorMessage: >>>\(errorMessage)<<<\n") }
}

func cleanRealmAndCaches() {
    
    guard let realm = try? Realm() else {
        return
    }
    
    try? realm.write {
        realm.deleteAll()
    }
    
    realm.refresh()
    printLog("清除 realm 完成")
    AvatarPod.clear()
    
    CubeImageCache.shard.cache.removeAllObjects()
    printLog("清除图片缓存完成")
    
    FileManager.cleanAvatarCaches()
    FileManager.cleanMessageCaches()
    
}
