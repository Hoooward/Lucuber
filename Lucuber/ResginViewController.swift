//
//  ResginViewController.swift
//  Lucuber
//
//  Created by Howard on 9/11/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit


enum LoginType {
    case Resgin
    case Login
}

class ResginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "LoginSegue":
            
            let vc = segue.destinationViewController as! RegisterPickMobileViewController
            vc.loginType = .Login
            
            break
            
        case "ResginSegue":
            
            let vc = segue.destinationViewController as! RegisterPickNameViewController
            vc.loginType = .Resgin
            break
            
        default:
            break
        }
    }

}
