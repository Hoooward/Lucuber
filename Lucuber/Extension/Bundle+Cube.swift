//
//  Bundle+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/14.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import Foundation

extension Bundle {
    
    static var releaseVersionNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var buildVersionNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
}
