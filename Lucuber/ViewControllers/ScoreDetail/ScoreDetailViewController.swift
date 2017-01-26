//
//  ScoreDetailViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/28.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation
import RealmSwift

class ScoreDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerNib(of: ScoreGroupDetailCell.self)
            tableView.registerNib(of: ScoreGroupDetailTimerCell.self)
        }
    }
    
    public var realm: Realm = try! Realm()
    public var scoreGroup: ScoreGroup?
    
    fileprivate var timerList: [Score] {
        if let scoreGroup = scoreGroup {
            return scoreGroup.timerList.sorted(byProperty: "createdUnixTime", ascending: false).map { $0 }
        }
        return [Score]()
    }
    
    fileprivate var collectList: [String] {
        
        let path = Bundle.main.path(forResource: "ScoreGroupDetailTitle.plist", ofType: nil)!
        if let list = NSArray(contentsOfFile: path) as? [String] {
           return list
        }
        return [String]()
    }
    
    public var didSeletedRowAtScoreGroupAction: (() -> Void)?
    
    fileprivate lazy var titleView: DetailTitleView = {
        let titleView = DetailTitleView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 150, height: 44)))
        return titleView
    }()
    
    private func updateTitleViewContent() {
        guard let scoreGroup = scoreGroup else {
            return
        }
        self.titleView.nameLabel.text = scoreGroup.category
        self.titleView.stateInfoLabel.text = scoreGroup.dateSectionString(with: .short)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        updateTitleViewContent()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain, target: self, action: #selector(ScoreDetailViewController.popViewController(sender:)))
        
        view.backgroundColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScoreDetailViewController.updateTableView), name: Config.NotificationName.updateMyScores, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func popViewController(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func updateTableView() {
        tableView.reloadData()
    }
 
}

extension ScoreDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum Section: Int {
        case top = 0
        case bottom = 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .top:
            return collectList.count
            
        case .bottom:
            guard let _ = scoreGroup else {
                return 0
            }
            return timerList.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .top: return "成绩汇总"
        case .bottom: return "详细数据"
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .top:
            let cell: ScoreGroupDetailCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configureCell(with: scoreGroup, title: collectList[indexPath.row])
            return cell
            
        case .bottom:
            let cell: ScoreGroupDetailTimerCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configureCell(with: timerList[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .top:
            return 44
          
        case .bottom:
            // TODO: - 行高可能需要计算
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        guard let score = timerList[safe: indexPath.row] else {
            return nil
        }
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "删除", handler: { [weak self] action, indexPath in
            
            guard let strongSelf = self else {
                return
            }
            
            let score = strongSelf.timerList[indexPath.row]
            
            try? strongSelf.realm.write {
//                strongSelf.realm.delete(score)
                score.isDeleteByCreator = true
                score.isPushed = false
            }
            
            tableView.reloadData()
        })
        
        let dnfAction = UITableViewRowAction(style: .normal, title: score.isDNF ? "恢复" : "DNF", handler: { [weak self] action, indexPath in 
            guard let strongSelf = self else {
                return
            }
            
            let score = strongSelf.timerList[indexPath.row]
            
            try? strongSelf.realm.write {
                score.isDNF = !score.isDNF
                score.isPushed = false
            }
            
            tableView.reloadData()
        })
        
        let copyAction = UITableViewRowAction(style: .normal, title: "复制", handler: { [weak self] action, indexPath in
            
            guard let strongSelf = self else {
                return
            }
            
            let score = strongSelf.timerList[indexPath.row]
            
            UIPasteboard.general.string = score.scramblingText
        })
        
        copyAction.backgroundColor = UIColor.orange
        
        dnfAction.backgroundColor = UIColor(red: 200/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1)
        
        return [deleteAction, copyAction, dnfAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}











