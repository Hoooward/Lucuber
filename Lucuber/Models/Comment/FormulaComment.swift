//
//  FormulaComment.swift
//  Lucuber
//
//  Created by Howard on 16/6/27.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class FormulaComment: AVObject, AVSubclassing {
    
    ///对哪个公式的评论
    static let FormulaCommentKey_atFormula = "atFormulaName"
    @NSManaged var atFormulaName: String?
    
    /// 评论内容
    static let FormulaCommentKey_author = "author"
    @NSManaged var content: String?
    
    /// 被喜欢
    static let FormulaCommentKey_likeCount = "likeCount"
    @NSManaged var likeCount: Int
    
    /// 评论作者
    static let FormulaCommentkey_author = "author"
    @NSManaged var author: AVUser?
    
    ///新公式文本
    static let FormulaCommetnKey_fromulaText = "formulaText"
    @NSManaged var formulaText: String?
    
    class func parseClassName() -> String {
        return "FormulaComment"
    }
    
    /*
    init(author: AVUser?, content: String, formulaString: String?, likeCount: Int = 0) {
        self.author = author
        self.content = content
        self.formulaString = formulaString
        self.likeCount = likeCount
        
        super.init()
    }
    */
}

extension FormulaComment {
    class func CuberFormulaCommentQueryIncludeKeys() -> [String] {
        return [FormulaCommentKey_author, FormulaCommentKey_atFormula]
    }
}