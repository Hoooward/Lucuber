//
//  HeaderFormulaView.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class HeaderFormulaView: UIView {

    @IBOutlet var imageButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var creatTimeLabel: UILabel!
    @IBOutlet var creatUserLabel: UILabel!
    @IBOutlet var centerBackView: UIView!
    @IBOutlet var indicaterView: FormulaTypeIndicaterView!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HeaderFormulaView.addFormulaDetailDidChanged(_:)), name: AddFormulaDetailDidChangedNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HeaderFormulaView.addFormulaDetailDidChanged(_:)), name: CategotyPickViewDidSeletedRowNotification, object: nil)
    }
    
    func addFormulaDetailDidChanged(notification: NSNotification) {
        guard let dict = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        if let name = dict[AddFormulaNotification.NameChanged.rawValue] as? String {
            nameLabel.text = name.characters.count > 0 ? name : "Name"
        }
        
        if let item = dict[AddFormulaNotification.CategoryChanged.rawValue] as? CategoryItem {
            indicaterView.configureWithCategory(item.chineseText)
        }
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func makeUI() {
        imageButton.layer.cornerRadius = 4
        imageButton.layer.masksToBounds = true
        centerBackView.layer.cornerRadius = 10
        centerBackView.layer.masksToBounds = true
        centerBackView.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3).CGColor
        centerBackView.layer.borderWidth = 1.0
    }
    

    
    lazy var categoryView: CubeCategoryItemView = {
        let view = CubeCategoryItemView()
        view.configureWithCategory("3x3x3")
        //TODO: 这个frame有问题
        view.frame = view.bubbleImageView.frame
        return view
    }()

    
}
