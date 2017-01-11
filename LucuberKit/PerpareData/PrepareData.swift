
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

    
    func loadNewFormulasFormJSON() {
        //        let formulaFile = AVFile.init(URL: "http://ac-spfbe0ly.clouddn.com/Z4qcIcQinEQBBSHIuzqwLEE.json")
        
        func creatFormulas(jsonDict: [JSON], withType type: Type) -> [DiscoverFormula] {
            
            var formulas = [DiscoverFormula]()
            
            for item in jsonDict {
                
                let newFormula = DiscoverFormula()
                newFormula.localObjectID = Formula.randomLocalObjectID()
                newFormula.name = item["name"].stringValue
                newFormula.isLibrary = true
                newFormula.imageName = item["imageName"].stringValue
                
                
                if let image = UIImage(named: newFormula.imageName) {
                    
                    let data = UIImagePNGRepresentation(image)
                    let uploadFile = AVFile(data: data!)
                    
                    var error: NSError?
                    
                    if uploadFile.save(&error) {
                        if let url = uploadFile.url {
                            printLog("推送 Library 图片成功")
                            newFormula.imageURL = url
                        }
                    } else {
                        
                        printLog("推送 Library 图片失败")
                    }
                }
                
                
                newFormula.favorate = item["favorate"].boolValue
                newFormula.category = Category.x3x3.rawValue
                newFormula.type = type.rawValue
                newFormula.rating = 3
                newFormula.serialNumber = item["ID"].intValue
                
                let texts = item["formulaText"].arrayValue
                
                var contents = [DiscoverContent]()
                for (index, text) in texts.enumerated() {
                    
                    let content = DiscoverContent()
                    
                    content.localObjectID = Content.randomLocalObjectID()
                    content.atFormulaLocalObjectID = newFormula.localObjectID
                    content.text = text.stringValue
                    
                    switch index {
                    case 0:
                        content.rotation = "FR"
                        content.indicatorImageName = "FR"
                        
                    case 1:
                        content.rotation = "FL"
                        content.indicatorImageName = "FL"
                        
                    case 2:
                        content.rotation = "BL"
                        content.indicatorImageName = "BL"
                        
                    case 3:
                        content.rotation = "BR"
                        content.indicatorImageName = "BR"
                        
                    default:
                        break
                    }
                    
                    
                    contents.append(content)
                    
                    newFormula.contents = contents
                }
                
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
                print("解析JSON 失败")
            }
        }
        
    }
}

public func pushCubeCategory() {
    
    let categorys = [
        "二阶",
        "三阶",
        "四阶",
        "五阶",
        "六阶",
        "七阶",
        "八阶",
        "九阶",
        "十一阶",
      
        "镜面魔方",
        "金字塔魔方",
        "魔粽",
        "魔球",
        "五魔方",
        "菊花五魔方",
        "亚历山大之星",
        "直升机魔方",
        "移棱魔方",
        "空心魔方",
        "唯棱魔方",
        "斜转魔方",
        "钻石魔方",
        "齿轮魔方",
        "Square One",
        "Super Square One",
        "Square Two",
        "魔粽齿轮",
        "花瓣转角魔方",
        "六角异形魔方",
        "路障魔方",
        "八轴八面魔方",
        "百慕大三阶",
        "空心唯棱魔方",
        "唯角魔方",
        "魔中魔",
        "魔刃",
        "鲁比克360",
        "魔板",
        "大师魔板",
        "魔表",
        "扭计蛇",
        "113连体",
        "Tuttminx",
        "Futtminx",
        
        
        
        "3x3x1",
        "3x3x2",
        "3x3x4",
        "3x3x5",
        "3x3x6",
        "3x3x7",
        "3x3x8",
        "3x3x9",
        "2x2x1",
        "2x2x3",
        "2x2x4",
        "4x4x5",
        "4x4x6",
        "5x5x4",
        "2x3x4",
        "3x4x5",
    ]
    
    var cubeCategorys: [DiscoverCubeCategory] = []
    
    categorys.forEach { string in
        
        let newCategory = DiscoverCubeCategory()
        newCategory.categoryString = string
        cubeCategorys.append(newCategory)
    }
    
    AVObject.saveAll(cubeCategorys)
}

internal func pushBaseFormulaDataToLeanCloud() {
    
    FormulaManager.shardManager().loadNewFormulasFormJSON()
    let formulaDatas = FormulaManager.shardManager().parseAllFormulas()
    
    
    print("共 \(formulaDatas.count) 个公式.")
    var adminUser = AVUser()
    let query = AVQuery(className: "_User")
    
    
//    if let user = query.getObjectWithId("583d4df4128fe1006ac638d6") as? AVUser {
//        adminUser = user
//    }
    
    
    formulaDatas.forEach {
        
        let acl = AVACL()
        acl.setPublicReadAccess(true)
        acl.setWriteAccess(true, for: AVRole(name: "Administrator"))
        
        $0.acl = acl
//        $0.creator = adminUser
        
    }
    
    var contents = [DiscoverContent]()
    _ = formulaDatas.map {
        $0.contents.map {
            contents.append($0)
        }
    }
    
    
    
    
    printLog("共(\(contents.count) 个 contents)")
    
    AVObject.saveAll(contents)
    
    AVObject.saveAll(formulaDatas)
    
}



extension AVUser {
    
    /// 登录管理员账户
    class func loginAdministrator() {
        let user = AVUser()
        user.username = "admain"
        user.password = "h1Y2775852"
        
        
        AVUser.logInWithUsername(inBackground: "admain", password: "h1Y2775852") { (user, error) in
            
            if error != nil {
                
                printLog(error)
                
            } else {
                
                print("登录管理员账户成功 -> \(user?.username)")
            }
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
                print("当前user: \(user.username), 已成为管理员")
            }
        }
    }
    
}


