//
//  LibraryFormulaViewController.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class LibraryFormulaViewController: BaseFormulaViewController {
   
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userMode = FormulaUserMode.Normal
        seletedCategory = Category.Megaminx
        
//        FormulaManager.shardManager().loadNewFormulas { [weak self] in
//            self?.formulasData = FormulaManager.shardManager().Alls
//            self?.collectionView?.reloadData()
//            
//           pushFormulaDataOnLeanCloud()
//        }
  
        refreshControl.addTarget(self, action: #selector(LibraryFormulaViewController.refreshFormula), forControlEvents: .ValueChanged)
        refreshControl.layer.zPosition = -1
        collectionView!.alwaysBounceVertical = true
        self.collectionView!.addSubview(refreshControl)
        
        uploadFormulas(.Library) {
            [weak self] in
            
            self?.collectionView?.reloadData()
        }
    }
    
    
    var isUploadingFormula = false
    
    func uploadFormulas(mode: UploadFormulaMode = .Library, finfish: (() -> Void)? ) {
        
        //0.1 从本地获取是否需要重新加载数据的标记,需要不需要更新就执行1
        
        //1. 从本地数据库加载
       
        if isUploadingFormula {
            finfish?()
            return
        }
        
        isUploadingFormula = true
        
        //TODO: - 添加 activityIndicatorView
        
        let failureHandler: (error: NSError) -> Void = {
            error in
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                
                CubeAlert.alertSorry(message: "加载失败,请重试", inViewController: self)
                
                finfish?()
            }
        }
        
        let completion: ([Formula]) -> Void = {
            
            formulas in
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.isUploadingFormula = false
                
                var resultFormula = [[Formula]]()
                
                if !formulas.isEmpty {
                   
                    
                    // 装所有的 Formula 类型
                    var allType = [Type]()
                    // 拿到 Formulas 数组中第一个元素的 type
                    var compareType = formulas.first!.type
                    
                    allType.append(compareType)
                    
                    // 遍历所有 formuls, 判断已有的 Type 有哪些
                    formulas.forEach {
                        
                        if $0.type != compareType {
                            
                            compareType = $0.type
                            allType.append(compareType)
                        }
                    }
                    
                    // 遍历所有类型, 创建新数组
                    allType.forEach { type in
                        
                        let prepareFormulas = formulas.filter { $0.type == type }.sort { $0.name < $1.name }
                        
                        resultFormula.append(prepareFormulas)
                    }
                    
                    strongSelf.formulasData = resultFormula
                    
                }
                
                finfish?()
                
            }
        }
        
        fetchFormulaWithMode(mode, completion: completion, failureHandler: failureHandler)
        
    }
    

    
    

    func refreshFormula() {
        let formulaFile = AVFile.init(URL: "http://ac-spfbe0ly.clouddn.com/Z4qcIcQinEQBBSHIuzqwLEE.json")
        
        formulaFile.getDataInBackgroundWithBlock { (data, error) in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                dispatch_async(dispatch_get_main_queue(), {
                    print(json)
                    self.refreshControl.endRefreshing()
                    
                })
            }catch {
            }
        }
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        self.refreshControl.beginRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.refreshControl.beginRefreshing()
        
    }
    



    
}


















