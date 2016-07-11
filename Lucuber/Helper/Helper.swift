//
//  Helper.swift
//  Lucuber
//
//  Created by Howard on 6/3/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit


//公式视图导航栏下面的切换条高度
let topControlHeight: CGFloat = 36

let navigationBarImage = "navigationbarBackgroundWhite"

let screenHeight = UIScreen.mainScreen().bounds.size.height
let screenWidth = UIScreen.mainScreen().bounds.size.width
let screenBounds = UIScreen.mainScreen().bounds

// MARK：- NotificationName
let DetailCellShowCommentNotification = "DetailCellShowCommentNotification"
let ContainerDidScrollerNotification = "ContainerDidScrollerNotification"
let FormulaTypePopMenuDismissNotification = "FormulaTypePopMenuDismissNotification"
let CategotyPickViewDidSeletedRowNotification = "CategotyPickViewDidSeletedRowNotification"
let AddFormulaDetailDidChangedNotification = "AddFormulaDetailDidChangedNotification"

enum AddFormulaNotification: String {
    case NameChanged = "NameChanged"
    case CategoryChanged = "CategoryChanged"
    case CategoryInEnglishChanged = "CategoryChanged_English"
    case CategoryInChineseChanged = "CategoryChanged_Chinese"
    case FormulaChanged = "FormulaChanged"
}

/**
 * 自定义 print 用于 Debug， 利用 #file #function #line 来分别输出
 * 文件名 函数名 行号
 * 可以利用 #if DEBUG
 * #endif 来分割print方法，让此print失效，达到发布程序取消print并节省性能的目的。
 */
func printLog<T>(message: T,
              file: String = #file,
              method: String = #function,
              line: Int = #line) {
    //
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    //
}


// MARK: - 方便访问 View 子类的宽度和高度
extension UIView {
    
    var width: CGFloat {
        get { return self.frame.size.width }
        set { self.frame.size.width = newValue }
    }
    
    var height: CGFloat {
        get { return self.frame.size.height }
        set { self.frame.size.height = newValue }
    }
    
    var size: CGSize {
        get { return self.frame.size }
        set { self.frame.size = newValue }
    }
    
    var x: CGFloat {
        get { return self.frame.origin.x }
        set { self.frame.origin.x = newValue }
    }
    
    var y: CGFloat {
        get { return self.frame.origin.y }
        set { self.frame.origin.y = newValue }
    }
}