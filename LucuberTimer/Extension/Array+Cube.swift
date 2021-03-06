//
//  Array+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/24.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation

extension Collection {
    
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
