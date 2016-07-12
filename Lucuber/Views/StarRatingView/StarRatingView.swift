//
//  StartRatingView.swift
//  Lucuber
//
//  Created by Howard on 7/12/16.
//  Copyright © 2016 Howard. All rights reserved.
//
import UIKit

@objc protocol StarRatingViewDelegate {
    func ratingDidChange(rateView: StarRatingView, rating: Int)
}

class StarRatingView: UIView {
    
    var notSelectedImage: UIImage = UIImage(named: "Star-empty")! {
        didSet {
            refresh()
        }
    }
    var halfSelectedImage: UIImage = UIImage(named: "Star_full")! {
        didSet {
            refresh()
        }
    }
    var fullSelectedImage: UIImage = UIImage(named: "Star_full")! {
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
    @IBInspectable var maxRating: Int = 5 {
        didSet {
            imageViews.forEach { $0.removeFromSuperview() }
            imageViews.removeAll()
            
            for _ in 0..<maxRating {
                let imageView = UIImageView()
                imageView.contentMode = .ScaleAspectFit
                imageViews.append(imageView)
                addSubview(imageView)
            }
            
            setNeedsLayout()
            refresh()
        }
    }
    var midMargin: CGFloat = 0
    var leftMargin: CGFloat = 0
    var minImageSize: CGSize = CGSizeZero
    
    weak var delegate: StarRatingViewDelegate?
    
    @IBInspectable var editable: Bool = true
    
    
    func refresh() {
        for (index, imageView) in imageViews.enumerate() {
            if self.rating >= index + 1  {
                imageView.image = self.fullSelectedImage
            } else if self.rating > index {
                imageView.image = self.halfSelectedImage
            } else {
                imageView.image = self.notSelectedImage
            }
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let desiredImageWidth = (self.frame.size.width - (self.leftMargin * 2) - (self.midMargin * CGFloat(self.imageViews.count))) / CGFloat(self.imageViews.count)
        let imageWidth = max(self.minImageSize.width, desiredImageWidth)
        let imageHeight = max(self.minImageSize.height, self.frame.size.height)
        
        for (index, imageview) in imageViews.enumerate() {
            imageview.frame = CGRect(x: self.leftMargin + CGFloat(index) * (self.midMargin + imageWidth), y: 0, width: imageWidth, height: imageHeight)
        }
        
    }
    
    func handleTouchAtLocation(touchLocation: CGPoint) {
        if !self.editable { return }
        var newRating = 0
        for (index, imageView) in imageViews.enumerate().reverse(){
            if touchLocation.x > imageView.frame.origin.x {
                newRating = index + 1
                break
            }
        }
        self.rating = newRating
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let touchLocation = touch.locationInView(self)
        handleTouchAtLocation(touchLocation)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let touchLocation = touch.locationInView(self)
        handleTouchAtLocation(touchLocation)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.delegate?.ratingDidChange(self, rating: self.rating)
    }
    
    
    
}
