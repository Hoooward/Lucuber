//
//  HeaderFormulaView.swift
//  Lucuber
//
//  Created by Howard on 7/10/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class NewFormulaHeadView: UIView {
    
    class func creatHeaderFormulaViewFormNib() -> NewFormulaHeadView {
        return Bundle.main.loadNibNamed("NewFormulaHeadView", owner: nil, options: nil)!.last! as! NewFormulaHeadView
    }
    
    fileprivate var formula: Formula?
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        return dateFormatter
    }()
    
    public func configView(with formula: Formula?) {
        
        guard let formula = formula else {
            return
        }
        
        self.formula = formula
        
        imageButton.setBackgroundImage(UIImage(named:formula.imageName), for: .normal)
        setFormulaImageButtonBackgroundImage(imageName: formula.imageName)
        indicatorView.configureWithCategory(category: formula.category.rawValue)
        
        var newName = formula.name.trimming(trimmingType: .whitespaceAndNewLine)
        newName = newName.isDirty ? "名称" : newName
        
        self.nameLabel.text = newName
        
        self.starRatingView.rating = formula.rating
        self.starRatingView.maxRating = formula.rating
        
        if let realm = formula.realm {
            self.creatUserLabel.text =  "创建者: " + (currentUser(in: realm)?.nickname)!
        }
        
        
        let date = Date(timeIntervalSince1970: formula.createdUnixTime)
        self.creatTimeLabel.text = "创建时间: " + dateFormatter.string(from: date)
        
        
        
        
    }

    var isReadyforSave: Bool {
        
        guard let newName = nameLabel.text, newName.characters.count > 0 else  {
           return false
        }
        return true
        
    }

    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var creatTimeLabel: UILabel!
    @IBOutlet weak var creatUserLabel: UILabel!
    @IBOutlet weak var centerBackView: UIView!
    @IBOutlet weak var indicatorView: CategoryIndicatorView!
    @IBOutlet weak var starRatingView: StarRatingView!
    @IBOutlet weak var helpButton: UIButton!
    
    @IBOutlet weak var BLIndicatorView: UIImageView!
    @IBOutlet weak var BRIndicatorView: UIImageView!
    @IBOutlet weak var FLIndicatorView: UIImageView!
    @IBOutlet weak var FRIndicatorView: UIImageView!

    
    // MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func makeUI() {
        
        imageButton.layer.cornerRadius = 4
        imageButton.layer.masksToBounds = true
        centerBackView.layer.cornerRadius = 10
        centerBackView.layer.masksToBounds = true
        centerBackView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        centerBackView.layer.borderWidth = 1.0
        starRatingView.maxRating = 3
        
        
        helpButton.setBackgroundImage(UIImage(named: "formula_content_help"), for: .normal)
        helpButton.setBackgroundImage(UIImage(named: "formula_content_help_seleted"), for: .selected)
        
        updateRotationIndicaterStatu(show: false)
    }
    
    
    // MARK: - ACtion & Target
    
    @IBAction func helpButtonClicked(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        updateRotationIndicaterStatu(show: sender.isSelected)
    
    }
    
    private func updateRotationIndicaterStatu(show: Bool) {
        
        spring(duration: 1.0) {
            self.BLIndicatorView.alpha = show ? 1 : 0
            self.BRIndicatorView.alpha = show ? 1 : 0
            self.FLIndicatorView.alpha = show ? 1 : 0
            self.FRIndicatorView.alpha = show ? 1 : 0
        }
    }
   
    
    private func setFormulaImageButtonBackgroundImage(imageName: String?) {
        guard let imageName = imageName else {
            imageButton.setBackgroundImage(UIImage(named:"cube_Placehold_image_1"), for: .normal)
            return
        }
        imageButton.setBackgroundImage(UIImage(named:imageName), for: .normal)
    }
    
   
    
    func addFormulaDetailDidChanged(notification: NSNotification) {
        
        guard let dict = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        if
            let name = dict[Config.NewFormulaNotificationKey.name] as? String,
            let formula = formula {
            
            let newName = name.isDirty ? "Name" : name
            nameLabel.text = newName.trimming(trimmingType: .whitespaceAndNewLine)
            formula.name = newName
        }
        
        if
            let category = dict[Config.NewFormulaNotificationKey.category] as? CategoryItem,
            let formula = formula {
            
            indicatorView.configureWithCategory(category: category.chineseText)
            formula.categoryString = category.chineseText
            
        }
        
        if
            let rating = dict[Config.NewFormulaNotificationKey.starRating] as? Int,
            let formula = formula {
            
            starRatingView.rating = rating
            starRatingView.maxRating = rating
            formula.rating = rating
        }
    }
    
   
 

    

    
}
