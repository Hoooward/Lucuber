//
//  Config.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

public class Config {
    
    public static let forcedHideActivityIndicatorTimeInterval: TimeInterval = 30
    
    
    public struct TopControl {
        public static let height: CGFloat = 36
        public static let indicaterHeight: CGFloat = 2
        public static let buttonTagBaseValue = 100
    }
    
    public struct BaseRotation {
        public static let FRrotation: Rotation = Rotation.FR("FR", "图例的状态")
        public static let FLrotation: Rotation = Rotation.FL("FL", "魔方整体顺时针旋转 90° 的状态")
        public static let BLrotation: Rotation = Rotation.BL("BL", "魔方整体顺时针旋转 180° 的状态")
        public static let BRrotation: Rotation = Rotation.BR("BR", "魔方整体顺时针旋转 270° 的状态")
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
}
