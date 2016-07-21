//
//  CubeConfig.swift
//  Lucuber
//
//  Created by Howard on 7/15/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit


final public class CubeConfig {
   
    public static let forcedHideActivityIndicatorTimeInterval: NSTimeInterval = 30
    
    
    
    public struct CagetoryMenu {
        public static let rowHeight: CGFloat = 44
        public static let menuWidth: CGFloat = screenWidth / 2
        public static let menuOrignX: CGFloat = screenWidth - CagetoryMenu.menuWidth - 10
    }
    
    public struct DetailFormula {
        public static let screenMargin: CGFloat = 38
        public static let masterRowHeight: CGFloat = 50
        public static let separatorRowHeight: CGFloat = 40
        public static let ratingViewWidth: CGFloat = 100
        public static let commentRowHeight: CGFloat = 80
    }
    
}