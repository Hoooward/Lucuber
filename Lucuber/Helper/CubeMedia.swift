//
//  CubeMedia.swift
//  Lucuber
//
//  Created by Tychooo on 16/12/15.
//  Copyright © 2016年 Tychooo. All rights reserved.
//

import UIKit
import Navi

public func metaDataOfImage(_ image: UIImage, needBlurThumbnail: Bool) -> Data? {

    let metaDataInfo: [String: Any]

    let imageWidth = image.size.width
    let imageHeight = image.size.height

    let thumbnailWidth: CGFloat
    let thumbnailHeight: CGFloat

    if imageWidth > imageHeight {

        thumbnailWidth = min(imageWidth, Config.MetaData.thumbnailMaxSize)
        thumbnailHeight = imageHeight * (thumbnailWidth / imageWidth)

    } else {

        thumbnailHeight = min(imageHeight, Config.MetaData.thumbnailMaxSize)
        thumbnailWidth = imageWidth * (thumbnailHeight / imageHeight)

    }

    let thumbnailSize = CGSize(width: thumbnailWidth, height: thumbnailHeight)

    if let thumbnail = image.resizeTo(targetSize: thumbnailSize, quality: CGInterpolationQuality.high) {

        if needBlurThumbnail {

            metaDataInfo = [
                    Config.MetaData.imageWidth: imageWidth,
                    Config.MetaData.imageHeight: imageHeight,
            ]

        } else {

            let data = UIImageJPEGRepresentation(thumbnail, 0.7)

            let string = data!.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))

            metaDataInfo = [
                    Config.MetaData.imageWidth: imageWidth,
                    Config.MetaData.imageHeight: imageHeight,
                    Config.MetaData.thumbnailString: string,
            ]
        }

    } else {

        metaDataInfo = [
                Config.MetaData.imageWidth: imageWidth,
                Config.MetaData.imageHeight: imageHeight
        ]

    }

    var metaDataString: String? = nil

    if let metaData = try? JSONSerialization.data(withJSONObject: metaDataInfo, options: []) {
        return metaData
    }
    return nil
}

public func metaDataStringOfImage(_ image: UIImage, needBlurThumbnail: Bool) -> String? {
    
    let metaDataInfo: [String: Any]
    
    let imageWidth = image.size.width
    let imageHeight = image.size.height
    
    let thumbnailWidth: CGFloat
    let thumbnailHeight: CGFloat
    
    if imageWidth > imageHeight {
        
        thumbnailWidth = min(imageWidth, Config.MetaData.thumbnailMaxSize)
        thumbnailHeight = imageHeight * (thumbnailWidth / imageWidth)
        
    } else {
        
        thumbnailHeight = min(imageHeight, Config.MetaData.thumbnailMaxSize)
        thumbnailWidth = imageWidth * (thumbnailHeight / imageHeight)
        
    }
    
    let thumbnailSize = CGSize(width: thumbnailWidth, height: thumbnailHeight)
    
    if let thumbnail = image.resizeTo(targetSize: thumbnailSize, quality: CGInterpolationQuality.high) {
        
        if needBlurThumbnail {
            
            metaDataInfo = [
                Config.MetaData.imageWidth: imageWidth,
                Config.MetaData.imageHeight: imageHeight,
            ]
            
        } else {
            
            let data = UIImageJPEGRepresentation(thumbnail, 0.7)
            
            let string = data!.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
            
            metaDataInfo = [
                Config.MetaData.imageWidth: imageWidth,
                Config.MetaData.imageHeight: imageHeight,
                Config.MetaData.thumbnailString: string,
            ]
        }
        
    } else {
        
        metaDataInfo = [
            Config.MetaData.imageWidth: imageWidth,
            Config.MetaData.imageHeight: imageHeight
        ]
        
    }
    
    var metaDataString: String? = nil
    
    if let metaData = try? JSONSerialization.data(withJSONObject: metaDataInfo, options: []) {
        metaDataString = NSString(data: metaData, encoding: String.Encoding.utf8.rawValue) as? String
    }
    
    return metaDataString
}





