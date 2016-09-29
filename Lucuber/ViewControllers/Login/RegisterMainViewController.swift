//
//  ResginViewController.swift
//  Lucuber
//
//  Created by Howard on 9/11/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

public enum LoginType {
    case register
    case login
}

class RegisterMainViewController: UIViewController, SegueHandlerType {
    
    // MARK: - Peoperties
    
    enum SegueIdentifier: String {
        case loginSegue = "LoginSegue"
        case registerSegue = "RegisterSegue"
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: nil, action: nil)
        
        navigationController?.navigationBar.tintColor = UIColor.cubeTintColor()
    }
    
    
    deinit {
        printLog("注册试图已死")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifier(for: segue) {
            
        case .loginSegue:
            
            let vc = segue.destination as! RegisterPickMobileViewController
            vc.loginType = .login
            
        case .registerSegue:
            
            let vc = segue.destination as! RegisterPickNameViewController
            vc.loginType = .register
            
        }
    }

}
