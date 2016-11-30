//
//  HeaderViewCell.swift
//  Lucuber
//
//  Created by Tychooo on 16/11/30.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

class HeaderViewCell: UICollectionViewCell {
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    
    var image = UIImage() {
        didSet {
            imageView.image = image
        }
    }
    
    public func configCell(with formula: Formula?) {
        
        guard let formula = formula else {
            return
        }
        
        imageView.cube_setImageAtFormulaCell(with: formula.imageURL ?? "", size: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI() {
        
        contentView.addSubview(imageView)
        imageView.frame = contentView.frame
        imageView.backgroundColor = UIColor(red: 250/255.0, green: 248/255.0, blue: 244/255.0, alpha: 1)
        
        imageView.layer.cornerRadius = 6
        imageView.layer.borderColor = UIColor.lightGray.cgColor
//        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        
    }
    
    
    
}
