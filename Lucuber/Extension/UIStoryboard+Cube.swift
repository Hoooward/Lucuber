//
//  UIStoryboard+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/18.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

protocol SegueHandlerType {
    
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func cube_performSegue(with identifier: SegueIdentifier, sender: AnyObject?) {
        
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
    
    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
              let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            fatalError("无效的 Segue Identifier")
        }
        
        return segueIdentifier
    }
    
}
