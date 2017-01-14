//
//  AboutViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/12.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import MonkeyKing

final class AboutViewController: UIViewController {
    
    @IBOutlet weak var appLogoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var appLogoImageView: UIImageView!
    
    @IBOutlet weak var appNameLabelTopContraint: NSLayoutConstraint!
    @IBOutlet weak var appNameLabel: UILabel!
    
    @IBOutlet weak var appVersionLabel: UILabel!
    
    @IBOutlet weak var aboutTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var aboutTableView: UITableView! {
        didSet {
            aboutTableView.registerNib(of: AboutCell.self)
        }
    }
    
    fileprivate let rowHeight: CGFloat = CubeRuler.iPhoneVertical(45, 50, 60, 70).value
    
    fileprivate let aboutAnnotations: [String] = [
        "Lucuber 的开源",
//        "在 App Store 上评价 Lucuber",
        "推荐 Lucuber 给朋友",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "关于"
        appLogoTopConstraint.constant = CubeRuler.iPhoneVertical(0, 20, 40, 60).value
        appNameLabelTopContraint.constant = CubeRuler.iPhoneVertical(10, 20, 20, 20).value
        
        appNameLabel.textColor = UIColor.cubeTintColor()
        
        if let releaseVersionNumber = Bundle.releaseVersionNumber,
            let buildVersionNumber = Bundle.buildVersionNumber {
            
            appVersionLabel.text = "版本 \(releaseVersionNumber)" + " (\(buildVersionNumber))"
            
        }
        
        aboutTableViewHeight.constant = rowHeight * CGFloat(aboutAnnotations.count) + 1
    }
    
}

extension AboutViewController: UITableViewDelegate, UITableViewDataSource {
    
    fileprivate enum Row: Int {
        case pods = 1
//        case review
        case share
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aboutAnnotations.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            return UITableViewCell()
        default:
            let cell: AboutCell = tableView.dequeueReusableCell(for: indexPath)
            let annotation = aboutAnnotations[indexPath.row - 1]
            cell.annotationLabel.text = annotation
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 1
        default:
            return rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        switch indexPath.row {
            
        case Row.pods.rawValue:
            performSegue(withIdentifier: "showPodHelp", sender: nil)
            
        case Row.share.rawValue:
            let lucuberURL = URL(string: "http://tychooo.com")!
            
            let info = MonkeyKing.Info(
                title: "Lucuber",
                description: "Lucuber, 魔方饲养",
                thumbnail: UIImage(named: "lucuber_icon_solo"),
                media: .url(lucuberURL)
            )
            self.share(info: info, defaultActivityItem: lucuberURL, description: "Lucuber, 魔方公式饲养")
            
        default:
            break
        }
    }
}













