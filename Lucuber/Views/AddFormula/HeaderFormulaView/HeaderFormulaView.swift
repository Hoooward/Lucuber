//
//  HeaderFormulaView.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class HeaderFormulaView: UIView {
    
    var formulaImageName: String? {
        didSet {
            setFormulaImageButtonBackgroundImage(formulaImageName)
        }
    }

    @IBOutlet var imageButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var creatTimeLabel: UILabel!
    @IBOutlet var creatUserLabel: UILabel!
    @IBOutlet var centerBackView: UIView!
    @IBOutlet var indicaterView: FormulaTypeIndicaterView!
    @IBOutlet var starRatingView: StarRatingView!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    ///设置image按钮的图片
    private func setFormulaImageButtonBackgroundImage(imageName: String?) {
        guard let imageName = imageName else {
            imageButton.setBackgroundImage(UIImage(named:"cube_Placehold_image_1"), forState: .Normal)
            return
        }
        imageButton.setBackgroundImage(UIImage(named:imageName), forState: .Normal)
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
        
        print(dict.keys.first)
         print(dict.keys)
        if let name = dict[AddFormulaNotification.NameChanged.rawValue] as? String {
            nameLabel.text = name.characters.count > 0 ? name : "Name"
        }
        
        if let category = dict[AddFormulaNotification.CategoryChanged.rawValue] as? CategoryItem {
            indicaterView.configureWithCategory(category.chineseText)
        }
        
        if let rating = dict[AddFormulaNotification.StartRatingChanged.rawValue] as? Int {
            starRatingView.rating = rating
            starRatingView.maxRating = rating
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
        starRatingView.maxRating = 3
    }
    

    
    lazy var categoryView: CubeCategoryItemView = {
        let view = CubeCategoryItemView()
        view.configureWithCategory("3x3x3")
        //TODO: 这个frame有问题
        view.frame = view.bubbleImageView.frame
        return view
    }()

    
}
