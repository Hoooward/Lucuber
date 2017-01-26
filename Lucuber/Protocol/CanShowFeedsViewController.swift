//
//  CanShowFeeds.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/19.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit

protocol CanShowFeedsViewController: class {
    var showProfileViewControllerAction: ((UIStoryboardSegue, Any?) -> Void)? {get set}
    var showCommentViewControllerAction: ((UIStoryboardSegue, Any?) -> Void)? {get set}
    var showFormulaDetailViewControllerAction: ((UIStoryboardSegue, Any?) -> Void)? {get set}
    var showFormulaFeedsViewControllerAction: ((UIStoryboardSegue, Any?) -> Void)? {get set}
}
