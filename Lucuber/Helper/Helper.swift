//
//  Helper.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

func printLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
    
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)]:\(message)")
    #endif
}

