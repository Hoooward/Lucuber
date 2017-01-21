//
//  EditScoreViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/21.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import RealmSwift
import TPKeyboardAvoiding

final class EditScoreViewController: UIViewController {
    
    @IBOutlet weak var tableView: TPKeyboardAvoidingTableView! {
        didSet {
            tableView.keyboardDismissMode = .onDrag
            tableView.registerNib(of: EditScoreCell.self)
        }
    }
    
    @IBOutlet weak var avtivityIndicator: UIActivityIndicatorView!
    fileprivate var realm: Realm = try! Realm()
    fileprivate var me: RUser?
    
    var oldScores: Set<CubeScores> = []
    
    fileprivate var newScores: [CubeScores]? {
        didSet {
            guard let newScores = newScores else {
                return
            }
            
            let newCategorys = newScores.map {$0.categoryString}
            
            for score in oldScores {
                let categoryString = score.categoryString
                if newCategorys.contains(categoryString) {
                    if let index = newCategorys.index(of: categoryString) {
                        newScores[index].scoreTimerString = score.scoreTimerString
                    }
                } 
            }
            
            tableView.reloadData()
        }
    }
    
    fileprivate lazy var saveBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(EditScoreViewController.save))
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "成绩"
        navigationItem.rightBarButtonItem = saveBarButtonItem
        saveBarButtonItem.isEnabled = false
        
        me = currentUser(in: realm)
        
        me?.cubeScoresList.forEach {
            if !oldScores.contains($0) {
                oldScores.insert($0)
            }
        }
        
        avtivityIndicator.startAnimating()
        fetchCubeCategorys(failureHandler: {[weak self] reason, errorMessage in
            self?.avtivityIndicator.stopAnimating()
            defaultFailureHandler(reason, errorMessage)
            
            CubeAlert.alertSorry(message: "获取魔方列表失败,请检查网络连接", inViewController: self)
            
        }, completion: { [weak self] results in
            
            self?.avtivityIndicator.stopAnimating()
            self?.newScores = results.map {
                let score = CubeScores()
                score.atRUser = self?.me
                score.categoryString = $0.categoryString
                score.scoreTimerString = ""
                return score
            }
            
        })
        
        tableView.rowHeight = 60
        var separatorInset = tableView.separatorInset
        separatorInset.left = CubeRuler.iPhoneHorizontal(15, 20, 25).value
        tableView.separatorInset = separatorInset
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarLine.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
        printLog("\(self) 已经释放")
    }
    
    @objc fileprivate func save() {
        
        guard let newScores = newScores else {
           return
        }
        
        let flatScores = newScores.filter({ $0.scoreTimerString != "" })
        
        var flatScoreResult = [CubeScores]()
        
        flatScores.forEach {
            let score = CubeScores()
            score.categoryString = $0.categoryString
            score.scoreTimerString = $0.scoreTimerString
            score.atRUser = me
            flatScoreResult.append(score)
        }
       
        printLog(flatScoreResult)
        try? realm.write {
            if let oldScores = me?.cubeScoresList {
                realm.delete(oldScores)
            }
        }
        try? realm.write {
            realm.add(flatScoreResult)
        }
        
        pushMyInfoToLeancloud(completion: { [weak self] in
            
            self?.saveBarButtonItem.isEnabled = false
            
        }, failureHandler: { [weak self] reason, errorMessage in
            
            if let nav = self?.navigationController {
                CubeAlert.alertSorry(message: "", inViewController: nav)
            }
        })
    }
}


extension EditScoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return newScores?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: EditScoreCell = tableView.dequeueReusableCell(for: indexPath)
        
        if let newScores = newScores {
            cell.cubeScores = newScores[indexPath.row]
        }

        cell.scoreTextFiledDidBeginEditingAction = { [weak self] in
            self?.saveBarButtonItem.isEnabled = false
        }
        cell.scoreTextFiledDidEndEditingAction = { [weak self] text, cell in
            
            self?.saveBarButtonItem.isEnabled = true
            
            if let indexPath = tableView.indexPath(for: cell) {
                if let newScores = self?.newScores {
                    newScores[indexPath.row].scoreTimerString = text
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        guard let cell = tableView.cellForRow(at: indexPath) as? EditScoreCell else {
            return
        }
        
        cell.scoreTextField.becomeFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "填写复原魔方的「SUB」时间，即「在 x 秒以内复原」。"
    }
}












