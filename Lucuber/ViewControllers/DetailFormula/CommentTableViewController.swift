//
//  CommentTableViewController.swift
//  Lucuber
//
//  Created by Howard on 16/6/27.
//  Copyright © 2016年 Howard. All rights reserved.
//

import UIKit

class CommentTableViewController: UITableViewController {
    
    var formulaComments: [FormulaComment] = []
    
    private lazy var indicatorTitleView = ConversationIndicatorTitleView(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .Minimal
        searchBar.placeholder = NSLocalizedString("搜索", comment: "")
        searchBar.setSearchFieldBackgroundImage(UIImage(named: "searchbar_textfield_background"), forState: .Normal)
        searchBar.delegate = self
        return searchBar
    }()

    private let CommentCellIdentifier = "CommentCell"
    var formula: Formula? {
        didSet {
            if let formula = formula {
               printLog("Comment-formula: \(formula)")
            }
        }
    }
    
    func loadNewComment() {
        let query = AVQuery(className: FormulaComment.parseClassName())
        query.addDescendingOrder("updatedAt")
        query.whereKey(FormulaComment.FormulaCommentKey_atFormula, equalTo: formula?.name)
        
        query.findObjectsInBackgroundWithBlock({ (result, error) in
            if error == nil {
                self.formulaComments = result as! [FormulaComment]
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        })
    }
    
    func creatNewComment() {
        printLog("写新评论")
//        let content = "S deletes the whole line you are on and enters into insert mode."
        let content = "评论" + NSUUID().UUIDString
        
        printLog("上传中")
        
        
        
        let newComment = FormulaComment()
        newComment.content = content
        newComment.author = AVUser.currentUser()
        newComment.atFormulaName = formula?.name
        
        newComment.saveInBackgroundWithBlock({ (success, error) in
            if success {
                self.formulaComments.append(newComment)
                printLog("发布成功")
                dispatch_async(dispatch_get_main_queue(), { 
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    // MARK: - 声明周期
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        
        
        loadNewComment()
    }
    func makeUI() {
        title = "讨论"
        
        let newComment = UIButton(type: .Custom)
        newComment.setTitle("写评论", forState: .Normal)
        newComment.setTitleColor(UIColor.cubeTintColor(), forState: .Normal)
        newComment.addTarget(self, action: #selector(CommentTableViewController.creatNewComment), forControlEvents: .TouchUpInside)
        newComment.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newComment)
    }
    
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formulaComments.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CommentCellIdentifier, forIndexPath: indexPath)
        let comment = formulaComments[indexPath.row]
        cell.textLabel?.text = comment.content
        return cell
    }
}

extension CommentTableViewController: UISearchBarDelegate{
}









