//
//  SearchFeedNormalImagesCell.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/16.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import AVOSCloud

final class SearchFeedNormalImagesCell: SearchFeedBasicCell {
    
    override class func heightOfFeed(_ feed: DiscoverFeed) -> CGFloat {
        let height = super.heightOfFeed(feed) + (10 + Config.SearchedFeedNormalImagesCell.imageSize.height)
        return ceil(height)
    }
    
    var tapMediaAction: tapMediaActionTypealias = nil
    
}
