
//
//  PrepareData.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/21.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud
import SwiftyJSON

class FormulaManager {
    
    static let instance = FormulaManager()
    class func shardManager() -> FormulaManager {
        return instance
    }
    
    var OLLs = [DiscoverFormula]()
    var F2Ls = [DiscoverFormula]()
    var PLLs = [DiscoverFormula]()
    var Alls = [[DiscoverFormula]]()
    
    // 将二维数组 Alls 转换为一维数组
    func parseAllFormulas() -> [DiscoverFormula] {
        
        var formulas: [DiscoverFormula] = []
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
        return text.lowercased().trimming(trimmingType: String.TrimmingType.squashingWhiteSpace)
    }
    
//    func searchFormulasWithSearchText(searchText: String?) -> [Formula] {
//        let formulas = parseAllFormulas()
//        guard let text = searchText, text.characters.count > 0 else {
//            return []
//        }
//        
//        return formulas.filter {
//            trimmingSearchText(text: $0.name).containsString(trimmingSearchText(text))
//        }
//    }
    
    
    
    func loadNewFormulasFormJSON() {
        //        let formulaFile = AVFile.init(URL: "http://ac-spfbe0ly.clouddn.com/Z4qcIcQinEQBBSHIuzqwLEE.json")
        
        func creatFormulas(jsonDict: [JSON], withType type: Type) -> [DiscoverFormula] {
            
            var formulas = [DiscoverFormula]()
            
            for item in jsonDict {
                
                let newFormula = DiscoverFormula()
                newFormula.localObjectID = UUID().uuidString
                newFormula.name = item["name"].stringValue
                newFormula.isLibrary = true
                newFormula.imageName = item["imageName"].stringValue
                newFormula.favorate = item["favorate"].boolValue
                newFormula.category = Category.x3x3.rawValue
                newFormula.type = type.rawValue
                newFormula.rating = 3
                newFormula.serialNumber = item["ID"].intValue
                
                let texts = item["formulaText"].arrayValue
                
                var contents = [String]()
                for (index, text) in texts.enumerated() {
                    
                    var resultText = ""
                    
                    switch index {
                    case 0:
                        resultText = "FR--\(text)"
                    case 1:
                        resultText = "FL--\(text)"
                    case 2:
                        resultText = "BL--\(text)"
                    case 3:
                        resultText = "BR--\(text)"
                    default:
                        break
                    }
                    contents.append(resultText)
                }
                
                
                newFormula.contents = contents
                formulas.append(newFormula)
            }
            return formulas
        }
        
        let Path = Bundle.main.path(forResource: "FormulasData", ofType: ".json")
        let data = NSData(contentsOfFile: Path!)
        
        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments)
                let jsonDict = JSON(json)
                
                if let olls = jsonDict["OLL"].array {
                    self.OLLs = creatFormulas(jsonDict: olls, withType: Type.OLL)
                    self.Alls.append(self.OLLs)
                }
                if let plls = jsonDict["PLL"].array {
                    self.PLLs = creatFormulas(jsonDict: plls, withType: Type.PLL)
                    self.Alls.append(self.PLLs)
                }
                if let f2ls = jsonDict["F2L"].array {
                    self.F2Ls = creatFormulas(jsonDict: f2ls, withType: Type.F2L)
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

internal func pushFormulaDataToLeanCloud() {
    // 拿到当前的所有公式.
    
    FormulaManager.shardManager().loadNewFormulasFormJSON()
    let formulaDatas = FormulaManager.shardManager().parseAllFormulas()
    
    
    var adminUser = AVUser()
    let query = AVQuery(className: "_User")
    
    
    if let user = query.getObjectWithId("57a58cb5a633bd006043f0d7") as? AVUser {
        adminUser = user
    }
    
    
    formulaDatas.forEach {
        
        let acl = AVACL()
        acl.setPublicReadAccess(true)
        acl.setWriteAccess(true, for: AVRole(name: "Administrator"))
        
        $0.acl = acl
        $0.creator = adminUser
        
    }
    
    AVObject.saveAll(formulaDatas)
    
}

extension AVUser {
    
    class func loginTestUser1() {
        
        
        //        AVUser.logInWithUsernameInBackground("12345", password: "12345") { (user, error) in
        //
        //            printLog("登录测试账户成功 -> \(user.username)")
        //        }
        
        AVUser.logIn(withUsername: "12345", password: "12345")
        
    }
}


extension AVUser {
    
    /// 登录管理员账户
    class func loginAdministrator() {
        let user = AVUser()
        user.username = "admain"
        user.password = "h1Y2775852"
        
        AVUser.logInWithUsername(inBackground: "admin", password: "h1Y2775852") { (user, error) in
            
            printLog("登录管理员账户成功 -> \(user?.username)")
        }
    }
    
    /// 成为管理员
    class func tobeAdministratorRole(user: AVUser) {
        
        let roleACL = AVACL()
        roleACL.setPublicReadAccess(true)
        roleACL.setPublicWriteAccess(true)
        
        let admainRole = AVRole(name: "Administrator", acl: roleACL)
        admainRole.users().add(user)
        admainRole.saveInBackground { (
            successed , error) in
            
            if error != nil {
                printLog("当前user: \(user.username), 已成为管理员")
            }
        }
    }
    
}


