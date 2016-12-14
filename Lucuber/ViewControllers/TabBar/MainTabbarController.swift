//
//  MainTabbarController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/17.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud

class MainTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = UIColor.cubeTintColor()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let push = AVPush()
        push.setMessage("啊啊啊")
        
        push.sendInBackground()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
