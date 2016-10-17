//
//  ViewController.swift
//  test
//
//  Created by Tychooo on 16/10/16.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeHeight(_ sender: AnyObject) {
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.init(rawValue: 0), animations: {
            
            self.heightConstraint.constant = self.heightConstraint.constant == 60 ? 120 : 60
            
            self.headerView.layoutIfNeeded()
            self.view.layoutIfNeeded()
            
            }, completion: nil)
        
    }

}

