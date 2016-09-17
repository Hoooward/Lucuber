//
//  FormulaViewController.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/17.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class FormulaViewController: UIViewController {
    
    // MARK: - Properties
    
    let topControl = UIView()
    let topIndicater = UIView()
    var topControlSeletedButton: UIButton?
    var containerScrollerView = UIScrollView()
    
    var containerScrollerOffsetX: CGFloat = 0
    
    // MARK: - Segue
    
    enum SegueIdentifier: String {
        case ShowFormulaDetail = "ShowFormulaDetail"
        case ShowAddFormula = "ShowAddFormula"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
