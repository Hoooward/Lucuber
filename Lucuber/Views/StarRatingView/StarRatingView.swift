//
//  StarRatingView.swift
//  Lucuber
//
//  Created by Tychooo on 16/9/19.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit

@objc protocol StarRatingViewDelegate {
    func ratingDidChange(rateView: StarRatingView, rating: Int)
}

class StarRatingView: UIView {
    
    var notSelectedImage: UIImage = UIImage(named: "star_empty")! {
        didSet {
            refresh()
        }
    }
    
    var fullSelectedImage: UIImage = UIImage(named: "star_full")! {
        didSet {
            refresh()
        }
    }
    
    var halfSeletedImage: UIImage = UIImage(named: "star_full")! {
        didSet {
            refresh()
        }
    }
    
    @IBInspectable var rating: Int = 0 {
        didSet {
            refresh()
        }
    }
    
    var imageViews = [UIImageView]()
    var maxRating: Int = 5 {
        didSet {
            imageViews.forEach { $0.removeFromSuperview() }
            imageViews.removeAll()
            
            for _ in 0..<maxRating {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFit
                imageViews.append(imageView)
                addSubview(imageView)
            }
            
            setNeedsLayout()
            refresh()
        }
    }
    
    var midMargin: CGFloat = 0
    var leftMargin: CGFloat = 0
    var minImageSize: CGSize = CGSize.zero
    
    weak var delegate: StarRatingViewDelegate?
    
    @IBInspectable var editable: Bool = true
    
    private func refresh() {
        
        imageViews.enumerated().forEach {
            index, imageView in
            
            if self.rating >= index + 1 {
                imageView.image = fullSelectedImage
            } else if rating > index {
                imageView.image = halfSeletedImage
            } else {
                imageView.image = notSelectedImage
            }
        }
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var desiredImageWidth: CGFloat = 0
        
        if editable {
            desiredImageWidth = (self.frame.size.width - (self.leftMargin * 2) - (self.midMargin * CGFloat(self.imageViews.count))) / CGFloat(self.imageViews.count)
        } else {
            desiredImageWidth = self.frame.size.width / 5
        }
        
        let imageWidth = max(self.minImageSize.width, desiredImageWidth)
        let imageHeight = max(self.minImageSize.height, self.frame.size.height)
        
        imageViews.enumerated().forEach {
            index, imageView in
            
            imageView.frame = CGRect(x: self.leftMargin + CGFloat(index) * (self.midMargin + imageWidth), y: 0, width: imageWidth, height: imageHeight)
        }
        
    }
    
    func handleTouch(location: CGPoint) {
        
        if !self.editable { return }
        var newRating = 0
        
        for (index, imageView) in imageViews.enumerated().reversed() {
            if location.x > imageView.frame.origin.x {
                newRating = index + 1
                break
            }
        }
        self.rating = newRating

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        handleTouch(location: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        handleTouch(location: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.delegate?.ratingDidChange(rateView: self, rating: self.rating)
    }
    
    
}
