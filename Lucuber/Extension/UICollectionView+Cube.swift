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
    
    func registerHeaderNibOf<T: UICollectionReusableView>(_: T.Type) where T: Reusable, T: NibLoad {
        
        let nib = UINib(nibName: T.cube_nibName, bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: T.cube_reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: Reusable {
    
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.cube_reuseIdentifier, for: indexPath) as? T else {
            fatalError("无法重用 identifier 为: \(T.cube_reuseIdentifier) 的 cell ")
        }
        
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, forIndexPath indexPath: IndexPath) -> T where T: Reusable {
        
        guard let view = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.cube_reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue supplementary view with identifier: \(T.cube_reuseIdentifier), kind: \(kind)")
        }
        
        return view
    }
    
}
