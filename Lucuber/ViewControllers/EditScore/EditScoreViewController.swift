//
//  EditScoreViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/21.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift

//typealias UserCubeScore = (String, String)

final class EditScoreViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomButtonView: BottomButtonView!
    
    fileprivate var realm: Realm = try! Realm()
    fileprivate var me: RUser?
    
    var scores: [CubeScores]?
    var oldScores: [CubeScores]?
    
    fileprivate var cubeCategarys: [CubeCategoryMaster]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "成绩"
        
        me = currentUser(in: realm)
        oldScores = me?.cubeScoresList.map { $0 }
        
        fetchCubeCategorys(failureHandler: { reason, errorMessage in
            defaultFailureHandler(reason, errorMessage)
        }, completion: { [weak self] results in
            
            self?.cubeCategarys = results.map {
                let cube = CubeCategoryMaster()
                cube.atRUser = self?.me
                cube.categoryString = $0.categoryString
                return cube
            }
        })
        var contentInset = tableView.contentInset
        contentInset.bottom = bottomButtonView.frame.height
        tableView.contentInset = contentInset
        
        tableView.rowHeight = 60
        var separatorInset = tableView.separatorInset
        separatorInset.left = CubeRuler.iPhoneHorizontal(15, 20, 25).value
        tableView.separatorInset = separatorInset
        
        tableView.registerNib(of: EditScoreCell.self)
        
        bottomButtonView.title = "添加新成绩"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 每次视图出现, 重置 selectedCategory
        navigationController?.navigationBarLine.isHidden = false
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pushMyInfoToLeancloud(completion: {
            
        }, failureHandler: { [weak self] reason, errorMessage in
            
            if let nav = self?.navigationController {
                CubeAlert.alertSorry(message: "设置擅长魔方失败", inViewController: nav)
            }
        })
    }
}


extension EditScoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let me = me {
            return me.cubeScoresList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: EditScoreCell = tableView.dequeueReusableCell(for: indexPath)
        
        var score: CubeScores?
        
        if let me = me {
            score = me.cubeScoresList[indexPath.row]
        }
        
        cell.cubeScores = score
        
        cell.deleteScoreAction = { [weak self] cell, score in
            
            if let me = self?.me {
                let rowToDelete: Int? = me.cubeScoresList.index(of: score)
                
                try? self?.realm.write {
                    self?.realm.delete(score)
                    
                    cell.cubeScores = nil
                }
                
                if let rowToDelete = rowToDelete {
                    
                    let indexPathToDelete = IndexPath(row: rowToDelete, section: 0)
                    self?.tableView.deleteRows(at: [indexPathToDelete], with: .automatic)
                }
               self?.tableView.reloadData()
            }
            
        }
        return cell
    }
}












