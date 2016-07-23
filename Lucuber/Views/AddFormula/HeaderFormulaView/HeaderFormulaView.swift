//
//  HeaderFormulaView.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class HeaderFormulaView: UIView {
    
    var formula: Formula? {
        didSet {
            guard let formula = formula else {
                return
            }
            setFormulaImageButtonBackgroundImage(formula.imageName)
            
        }
    }

    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var creatTimeLabel: UILabel!
    @IBOutlet weak var creatUserLabel: UILabel!
    @IBOutlet weak var centerBackView: UIView!
    @IBOutlet weak var indicaterView: CategoryIndicaterView!
    @IBOutlet weak var starRatingView: StarRatingView!
    @IBOutlet weak var helpButton: UIButton!
    
    @IBOutlet weak var BLIndicaterView: UIImageView!
    @IBOutlet weak var BRIndicaterView: UIImageView!
    @IBOutlet weak var FLIndicaterView: UIImageView!
    @IBOutlet weak var FRIndicaterView: UIImageView!

    
    @IBAction func helpButtonClicked(sender: UIButton) {
        sender.selected = !sender.selected
        updateRotationIndicaterStatu(sender.selected)
    
    }
    
    private func updateRotationIndicaterStatu(show: Bool) {
        spring(1.0) {
            self.BLIndicaterView.alpha = show ? 1 : 0
            self.BRIndicaterView.alpha = show ? 1 : 0
            self.FLIndicaterView.alpha = show ? 1 : 0
            self.FRIndicaterView.alpha = show ? 1 : 0
        }
    }
    
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
        if let name = dict[AddFormulaNotification.NameChanged.rawValue] as? String,
           let formula = formula {
            let newName = name.characters.count > 0 ? name : "Name"
            nameLabel.text = newName
            formula.name = newName
        }
        
        if let category = dict[AddFormulaNotification.CategoryChanged.rawValue] as? CategoryItem,
           let formula = formula {
            indicaterView.configureWithCategory(category.chineseText)
            formula.category = Category(rawValue: category.chineseText)!
            
        }
        
        if let rating = dict[AddFormulaNotification.StartRatingChanged.rawValue] as? Int,
            let formula = formula {
            starRatingView.rating = rating
            starRatingView.maxRating = rating
            formula.rating = rating
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
        
        
        helpButton.setBackgroundImage(UIImage(named: "formula_content_help"), forState: .Normal)
        helpButton.setBackgroundImage(UIImage(named: "formula_content_help_seleted"), forState: .Selected)
        
        updateRotationIndicaterStatu(false)
    }
    

    
    lazy var categoryView: CubeCategoryItemView = {
        let view = CubeCategoryItemView()
        view.configureWithCategory("3x3x3")
        //TODO: 这个frame有问题
        view.frame = view.bubbleImageView.frame
        return view
    }()

    
}
