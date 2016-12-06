//
//  URL+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/6.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import Foundation




extension URL {
    
    var cube_isNetworkURL: Bool {
       
        if let scheme = scheme {
            
            switch scheme {
            case "http", "https":
                return true
            default:
                return false
            }
        }
        return false
        
    }
    
    var validNetworkURL: URL? {
        
        if let scheme = scheme {
            
            if scheme.isEmpty {
                
                guard var URLComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
                    return nil
                }
                
                URLComponents.scheme = "http"
                
                return URLComponents.url
                
            } else {
                
                if cube_isNetworkURL {
                    return self
                } else {
                    return nil
                }
                
            }
        }
            
    }
}
