//
//  RegisterPickMobileViewController.swift
//  Lucuber
//
//  Created by Howard on 6/6/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class RegisterPickMobileViewController: UIViewController {

    var mobile: String?
    var areaCode: String?
    @IBOutlet var mobileTextFiled: UITextField!
    @IBOutlet var leftTextFiled: BorderTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

//        let rect = CGRectMake(20, 0, leftTextFiled.width - 40, leftTextFiled.height)
//        leftTextFiled.textRectForBounds(rect)
        view.backgroundColor = UIColor.cubeViewBackgroundColor()
        mobileTextFiled.backgroundColor = UIColor.whiteColor()
        mobileTextFiled.textColor = UIColor.cubeInputTextColor()
        leftTextFiled.backgroundColor = UIColor.whiteColor()
        leftTextFiled.addTarget(self, action: #selector(RegisterPickMobileViewController.leftTextFiledChanged(_:)), forControlEvents: .EditingChanged)
    }
    
    func leftTextFiledChanged(textFiled: UITextField) {
        view.layoutIfNeeded()
        leftTextFiled.layoutIfNeeded()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
