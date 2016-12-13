//
//  UICollectionView+Cube.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/13.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    func registerClass<T: UICollectionViewCell>(of _: T.Type) where T: Reusable {
        
        register(T.self, forCellWithReuseIdentifier: T.cube_reuseIdentifier)
    }
    
    func registerNib<T: UICollectionViewCell>(of _: T.Type) where T: Reusable, T: NibLoad {
        
        let nib = UINib(nibName: T.cube_nibName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.cube_reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: Reusable {
    
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.cube_reuseIdentifier, for: indexPath) as? T else {
            fatalError("无法重用 identifier 为: \(T.cube_reuseIdentifier) 的 cell ")
        }
        
        return cell
    }
}
