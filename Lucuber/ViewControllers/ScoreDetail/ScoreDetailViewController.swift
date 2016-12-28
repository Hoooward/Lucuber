//
//  ScoreDetailViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/28.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation

class ScoreDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerNib(of: ScoreGroupDetailCell.self)
            tableView.registerNib(of: ScoreGroupDetailTimerCell.self)
        }
    }
    
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
    }
    
    @objc func popViewController(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sharedScoreGroup(_ sender: UIBarButtonItem) {
        printLog("")
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
        case .top:
            return "成绩汇总"
            
        case .bottom:
            return "详细数据"
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
            return 80
        }
    }
    
}











