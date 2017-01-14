//
//  PodHelpViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/14.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

class PodHelpViewController: UITableViewController {
    
    struct Framework {
        let name: String
        let urlString: String
        
        var url: URL? {
            return URL(string: urlString)
        }
    }
    
    fileprivate let frameworks: [Framework] = [
        Framework(
            name: "Alamofire",
            urlString: "https://github.com/Alamofire/Alamofire"
        ),
        Framework(
            name: "LeanCloud",
            urlString: "https://leancloud.cn/"
        ),
        Framework(
            name: "FXBlurView",
            urlString: "https://github.com/nicklockwood/FXBlurView"
        ),
        Framework(
            name: "KeyboardMan",
            urlString: "https://github.com/nixzhu/KeyboardMan"
        ),
        Framework(
            name: "Kingfisher",
            urlString: "https://github.com/onevcat/Kingfisher"
        ),
        Framework(
            name: "Kanna",
            urlString: "https://github.com/tid-kijyun/Kanna"
        ),
        Framework(
            name: "MonkeyKing",
            urlString: "https://github.com/nixzhu/MonkeyKing"
        ),
        Framework(
            name: "Navi",
            urlString: "https://github.com/nixzhu/Navi"
        ),
        Framework(
            name: "Pop",
            urlString: "https://github.com/facebook/pop"
        ),
        Framework(
            name: "PKHUD",
            urlString: "https://github.com/pkluz/PKHUD"
        ),
        Framework(
            name: "Proposer",
            urlString: "https://github.com/nixzhu/Proposer"
        ),
        Framework(
            name: "Spring",
            urlString: "https://github.com/MengTo/Spring"
        ),
        Framework(
            name: "ScrollableGraphView",
            urlString: "https://github.com/philackm/Scrollable-GraphView"
        ),
        Framework(
            name: "Realm",
            urlString: "https://github.com/realm/realm-cocoa"
        ),
        Framework(
            name: "Ruler",
            urlString: "https://github.com/nixzhu/Ruler"
        ),
        Framework(
            name: "TPKeyboardAvoiding",
            urlString: "https://github.com/michaeltyson/TPKeyboardAvoiding"
        ),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "开源"
        tableView.tableFooterView = UIView()
    }
    
    enum Section: Int {
        case lucuber
        case frameworks
        
        var headerTitle: String {
            switch self {
            case .lucuber:
                return "Lucuber"
            case .frameworks:
                return "第三方"
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .lucuber:
            return 2
        case .frameworks:
            return frameworks.count
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        return section.headerTitle
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .lucuber:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "LucuberCell", for: indexPath)
            if indexPath.row == 0 {
                cell.textLabel?.text = "Lucuber 的代码仓库"
                cell.detailTextLabel?.text = "欢迎提交代码"
            }
            
            if indexPath.row == 1 {
                cell.textLabel?.text = "Yep 的代码仓库"
                cell.detailTextLabel?.text = "Lucuber 参照了 Yep 的代码以及 UI 设计"
            }
            
            return cell
            
        case .frameworks:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PodCell", for: indexPath)
            let framework = frameworks[indexPath.row]
            cell.textLabel?.text = framework.name
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
        case .lucuber:
            return 60
        case .frameworks:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError()
        }
        
        switch section {
            
        case .lucuber:
            
            if indexPath.row == 0 {
                
                if let URL = URL(string: "https://github.com/Hoooward/Lucuber") {
                    cube_openURL(URL)
                }
            }
            
            if indexPath.row == 1 {
                if let URL = URL(string: "https://github.com/CatchChat/Yep") {
                    cube_openURL(URL)
                }
            }
            
        case .frameworks:
            let framework = frameworks[indexPath.row]
            if let url = framework.url {
                cube_openURL(url)
            }
        }
    }
    
}
