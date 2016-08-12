//
//  PrepaerData.swift
//  Lucuber
//
//  Created by Howard on 8/6/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit
import SwiftyJSON

class FormulaManager {
    
    static let instance = FormulaManager()
    class func shardManager() -> FormulaManager {
        return instance
    }
    
    var OLLs = [Formula]()
    var F2Ls = [Formula]()
    var PLLs = [Formula]()
    var Alls = [[Formula]]()
    
    
    // 将二维数组 Alls 转换为一维数组
    func parseAllFormulas() -> [Formula] {
        var formulas: [Formula] = []
        let _ = Alls.map {
            $0.map {
                formulas.append($0) }
        }
        return formulas
    }
    
    
    /**
     整理字符串,去除空格
     参考: http://nshipster.cn/nscharacterset/
     */
    private func trimmingSearchText(text: String) -> String {
        return text.lowercaseString.trimming(String.TrimmingType.SquashingWhiteSpace)
    }
    
    func searchFormulasWithSearchText(searchText: String?) -> [Formula] {
        let formulas = parseAllFormulas()
        guard let text = searchText where text.characters.count > 0 else {
            return []
        }
        
        return formulas.filter {
            trimmingSearchText($0.name).containsString(trimmingSearchText(text))
        }
    }
    
    
    
    func loadNewFormulasFormJSON() {
//        let formulaFile = AVFile.init(URL: "http://ac-spfbe0ly.clouddn.com/Z4qcIcQinEQBBSHIuzqwLEE.json")
        
        func creatFormulas(jsonDict: [JSON], withType type: Type) -> [Formula] {
            
            var formulas = [Formula]()
            for item in jsonDict {
                
                let name = item["name"].stringValue
                let texts = item["formulaText"].arrayValue
                
                
                var formulaContent = [FormulaContent]()
                for (index, text) in texts.enumerate() {
                    let content = FormulaContent()
                    content.text = text.stringValue
                    
                    switch index {
                    case 0:
                        content.rotation = FRrotation
                    case 1:
                        content.rotation = FLrotation
                    case 2:
                        content.rotation = BLrotation
                    case 3:
                        content.rotation = BRrotation
                    default:
                        break
                    }
                    
                    formulaContent.append(content)
                }
                
                let imageName = item["imageName"].stringValue
                let favorate = item["favorate"].boolValue
                let ID = item["ID"].intValue
                
                let formula = Formula(name: name, contents: formulaContent, imageName: imageName,  favorate: favorate, category: Category.x3x3, type: type, rating: 3, serialNumber: ID)
                formula.isLibraryFormula = true
                formulas.append(formula)
            }
            return formulas
        }
        
        let Path = NSBundle.mainBundle().pathForResource("FormulasData", ofType: ".json")
        let data = NSData(contentsOfFile: Path!)
        
        if let data = data {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                let jsonDict = JSON(json)
                
                if let olls = jsonDict["OLL"].array {
                    self.OLLs = creatFormulas(olls, withType: Type.OLL)
                    self.Alls.append(self.OLLs)
                }
                if let plls = jsonDict["PLL"].array {
                    self.PLLs = creatFormulas(plls, withType: Type.PLL)
                    self.Alls.append(self.PLLs)
                }
                if let f2ls = jsonDict["F2L"].array {
                    self.F2Ls = creatFormulas(f2ls, withType: Type.F2L)
                    self.Alls.append(self.F2Ls)
                }
                
            }catch {
                printLog("解析JSON 失败")
            }
        }
        
    }
}




//
//internal func getFormulaDataFormJSON() -> JSON {
//    let Path = NSBundle.mainBundle().pathForResource("FormulasData", ofType: ".json")
//    let data = NSData(contentsOfFile: Path!)
//    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
//}

internal func pushFormulaDataOnLeanCloud() {
    // 拿到当前的所有公式.
    
    FormulaManager.shardManager().loadNewFormulasFormJSON()
    let formulaDatas = FormulaManager.shardManager().parseAllFormulas()
    
    
    var Auser = AVUser()
    let query = AVQuery(className: "_User")
  
    
    if let user = query.getObjectWithId("57a58cb5a633bd006043f0d7") as? AVUser {
        Auser = user
    }

    
    formulaDatas.forEach {
        
        let acl = AVACL()
        acl.setPublicReadAccess(true)
        acl.setWriteAccess(true, forRole: AVRole(name: "Administrator"))
        
        $0.ACL = acl
        $0.creatUser = Auser
        $0.creatUserID = Auser.objectId
        
    }
    
    AVObject.saveAll(formulaDatas)
    
}

extension AVUser {
    
    class func loginTestUser1() {
        
       
        AVUser.logInWithUsernameInBackground("12345", password: "12345") { (user, error) in
            
            printLog("登录测试账户成功 -> \(user.username)")
        }
        
    }
}


extension AVUser {
    
    /// 登录管理员账户
    class func loginAdministrator() {
        let user = AVUser()
        user.username = "admain"
        user.password = "h1Y2775852"
        
        AVUser.logInWithUsernameInBackground("admin", password: "h1Y2775852") { (user, error) in
            
            printLog("登录管理员账户成功 -> \(user.username)")
        }
    }
    
    /// 成为管理员
    class func tobeAdministratorRole(user: AVUser) {
        
        let roleACL = AVACL()
        roleACL.setPublicReadAccess(true)
        roleACL.setPublicWriteAccess(true)
        
        let admainRole = AVRole(name: "Administrator", acl: roleACL)
        admainRole.users().addObject(user)
        admainRole.saveInBackgroundWithBlock { (
            successed , error) in
            
            if error != nil {
                printLog("当前user: \(user.username), 已成为管理员")
            }
        }
    }
    
}

