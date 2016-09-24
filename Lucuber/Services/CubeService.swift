//
//  CubeService.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/19.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import AVOSCloud

public enum UploadFormulaMode: String {
    
    case my = "My"
    case library = "Library"
    
}


public enum UploadFeedMode {
    case top
    case loadMore
}

extension AVQuery {
    
    private enum DefaultKey: String {
        case updatedTime = "updatedAt"
        case creatTime = "createdAt"
    }
    
    class func getFormula(mode: UploadFormulaMode) -> AVQuery? {
        
        switch mode {
            
        case .my:
            
            let query = AVQuery(className: Formula.parseClassName())
            query?.addAscendingOrder("name")
            query?.whereKey("creatUser", equalTo: AVUser.current())
            query?.limit = 1000
            return query
            
        case .library:
            
            let query = AVQuery(className: Formula.parseClassName())
            query?.whereKey("isLibraryFormula", equalTo: NSNumber(booleanLiteral: true))
            query?.addAscendingOrder("serialNumber")
            query?.limit = 1000
            return query
            
        }
    }
    
}

public func fetchFormulaWithMode(uploadingFormulaMode: UploadFormulaMode,
                                 category: Category,
                                 completion: (([Formula]) -> Void)?,
                                 failureHandler: ((NSError) -> Void)?) {
    
    
    let task: (() -> Void) = {
        
        let needUpdate = UserDefaults.isNeedUpdateLibrary()
        
        if needUpdate {
            
            let query = AVQuery.getFormula(mode: uploadingFormulaMode)
            
            
            /// 直接请求所有的公式, 不区分类型或种类, 因为要更新 Realm
            query?.findObjectsInBackground {
                
                formulas, error in
                
                if error != nil {
                    
                    failureHandler?(error as! NSError)
                }
                
                if let formulas = formulas as? [Formula] {
                    
                    /// 更新 needUpdateLibrary
                    UserDefaults.setNeedUpdateLibrary(need: false)
                    
                    if let user = AVUser.current() {
                        
                        user.setNeedUpdateLibrary(need: false)
                        user.saveInBackground {
                            sessuce, error in
                            
                            if sessuce {
                                
                                printLog("更新用户数据成功")
                                
                            } else {
                                
                                printLog("更新用户数据失败")
                            }
                        }
                    }
                    
                    /// 将 Result 过滤一下, 只使用符合 category 的 formula
                    completion?(formulas.filter{ $0.category == category })
                    
                    /// 删除 Library 中 Formula 对应的 content
                    deleteLibraryFormalsRContentAtRealm()
                    
                    /// 更新数据库中的 Formula
                    saveUploadFormulasAtRealm(formulas: formulas, mode: uploadingFormulaMode, isCreatNewFormula: false)
                }
            }
            
        } else {
            
            let result = getFormulsFormRealmWithMode(mode: uploadingFormulaMode, category: category)
            
            completion?(result)
            
        }
    }
    
    
    switch uploadingFormulaMode {
        
    case .my :
        
        // 我的公式, 如果Realm中没有数据, 则尝试从网络加载, 否则不需要从网络加载
        
        let result = getFormulsFormRealmWithMode(mode: uploadingFormulaMode, category: category)
        
        result.isEmpty ? task() : completion?(result)
        
    case .library:
        
        task()
    }
    
    
}





internal func saveNewFormulaToRealmAndPushToLeanCloud(newFormula: Formula,
                                                      completion: (() -> Void)?,
                                                      failureHandler: ((NSError) -> Void)? ) {
    
    
    if let user = AVUser.current() {
        
        newFormula.creatUser = user
        newFormula.creatUserID = user.objectId
        
        let acl = AVACL()
        acl.setPublicReadAccess(true)
        acl.setWriteAccess(true, for: AVUser.current())
        newFormula.acl = acl
        
        
        newFormula.saveEventually({ (success, error) in
            if error  == nil {
                printLog("新公式保存到 LeanCloud 成功")
            } else {
                printLog("新公式保存到 LeanCloud 失败")
            }
        })
        
        saveUploadFormulasAtRealm(formulas: [newFormula], mode: nil, isCreatNewFormula: true)
        
        
        completion?()
        
        
    } else {
        
        let error = NSError(domain: "没有登录用户", code: 0, userInfo: nil)
        failureHandler?(error)
    }
    
    
    
}

// MARK: - Login

func validateMobile(mobile: String, failureHandler: ((NSError?) -> Void)?, completion: (() -> Void)?) {
    
    
    let query = AVQuery(className: "_User")
    query?.whereKey("mobilePhoneNumber", equalTo: mobile)
    
    query?.findObjectsInBackground {
        
        users, error in
        
        if let findUsers = users , findUsers.count == 0 {
            
            completion?()
            
        } else {
            
            failureHandler?(error as NSError?)
        }
        
    }
    
    
}


/// 如果已经登录,就去获取是否需要更新公式的bool值
/// 因为 getObjectInBackgroundWithId 是并发的, 应用程序一启动如果第一个视图是 Formula
/// 的话会第一时间使用 NeedUpdateLibrary 属性进行 Formula 数据加载. 即使在 LeanCloud 中 将
/// 值设为 ture 后的第一次启动, NeedUpdateLibrary 的值还是 false. 第二次启动才会更新 Libray.
public func initializeWhetherNeedUploadLibraryFormulas() {
    
    
    if let user = AVUser.current() {
        
        if !UserDefaults.isNeedUpdateLibrary() {
            
            let query = AVQuery(className: "_User")
            
            query?.getObjectInBackground(withId: user.objectId) {
                
                result , error in
                
                if error == nil {
                    
                    let need = result?.object(forKey: "needUpdateLibrary") as! Bool
                    printLog("is Need Upload Formulas From LeanCloud")
                    UserDefaults.setNeedUpdateLibrary(need: need)
                }
            }
        }
        
    } else {
        
        UserDefaults.setNeedUpdateLibrary(need: true)
    }
}





















