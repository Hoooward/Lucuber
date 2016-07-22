//
//  FeedUploadingErrorContainerView.swift
//  Lucuber
//
//  Created by Howard on 7/22/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

class FeedUploadingErrorContainerView: UIView {

    
    var retryAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    
    lazy var leftContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 1, green: 56/255.0, blue: 36/255.0, alpha: 0.1)
        view.layer.cornerRadius = 5
        return view
    }
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tabbar_plus_sele"))
        return imageView
    }
    
    lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    

}
