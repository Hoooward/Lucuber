//
//  Config.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

extension Notification.Name {
    
    static let formulaCategoryMenuDidmissNotification = Notification.Name("formulaCategoryMenuDismissNotification")
    
    static let categotyPickViewDidSeletedRowNotification = Notification.Name("categotyPickViewDidSeletedRowNotification")
    
    
    static let changeRootViewControllerNotification = Notification.Name("changeRootViewController")
    
    static let updateFormulasLibraryNotification = Notification.Name("updateFormulasLibrary")
    
}

public class Config {
    
    public static let forcedHideActivityIndicatorTimeInterval: TimeInterval = 30
    
    public static let mobilePhoneCodeInSeconds = 59
    
    public struct ErrorCode {
        
        public static let registered: Int = 888888
    }
    
    public struct TopControl {
        public static let height: CGFloat = 36
        public static let indicaterHeight: CGFloat = 2
        public static let buttonTagBaseValue = 100
    }
    
    public struct BaseRotation {
        public static let FR: Rotation = Rotation.FR("FR", "图例的状态")
        public static let FL: Rotation = Rotation.FL("FL", "魔方整体顺时针旋转 90° 的状态")
        public static let BL: Rotation = Rotation.BL("BL", "魔方整体顺时针旋转 180° 的状态")
        public static let BR: Rotation = Rotation.BR("BR", "魔方整体顺时针旋转 270° 的状态")
    }
    
    public struct FormulaCell {
        
        public static let normalCellEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        public static let cardCellEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        public static let normalCellSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 80)
        
        public static let cardCellSize: CGSize = CGSize(width: (UIScreen.main.bounds.width - (10 + 10 + 10)) * 0.5, height: 280)

    }
    
    public struct DetailFormula {
        public static let screenMargin: CGFloat = 38
        public static let masterRowHeight: CGFloat = 50
        public static let separatorRowHeight: CGFloat = 40
        public static let ratingViewWidth: CGFloat = 100
        public static let commentRowHeight: CGFloat = 80
    }
   
    public struct CategoryMenu {
        
        public static let rowHeight: CGFloat = 44
        public static let menuWidth: CGFloat = UIScreen.main.bounds.width * 0.5
        public static let menuOrignX: CGFloat = UIScreen.main.bounds.width - CategoryMenu.menuWidth - 10
    }
    
    public struct InputAccessory {
        
        public static let buttonWidth: CGFloat = 35
        public static let buttonHeight: CGFloat = 25
    }
    
    public struct NewFormulaNotificationKey {
        
        public static let name: String = "nameChanged" 
        public static let category: String = "categoryChanged"
        public static let categoryEnglish: String = "categoryEnglishChanged"
        public static let categoryChinese: String = "categoryChineseChanged"
        public static let starRating: String = "starRatingChanged"
        public static let formula: String = "formulaChanged"
        
    }
    
    public struct Avatar {
        public static let maxSize: CGSize = CGSize(width: 414, height: 414)
    }
    
    public struct FormulaDetail {
        public static let screenMargin: CGFloat = 38
        public static let masterRowHeight: CGFloat = 50
        public static let separatorRowHeight: CGFloat = 40
        public static let ratingViewWidth: CGFloat = 100
        public static let commentRowHeight: CGFloat = 80
    }
    
    
}








