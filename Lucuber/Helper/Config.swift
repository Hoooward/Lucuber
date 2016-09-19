//
//  Config.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

public class Config {
    
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
    
    public struct DetailFormula {
        public static let screenMargin: CGFloat = 38
        public static let masterRowHeight: CGFloat = 50
        public static let separatorRowHeight: CGFloat = 40
        public static let ratingViewWidth: CGFloat = 100
        public static let commentRowHeight: CGFloat = 80
    }
}
