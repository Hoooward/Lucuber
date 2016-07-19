//
//  ActionSheetView.swift
//  Lucuber
//
//  Created by Howard on 7/15/16.
//  Copyright © 2016 Howard. All rights reserved.
//

import UIKit

// MARK: - ActionSheetDefaultCell

final private class ActionSheetDefaultCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var colorTitlelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        return label
    }()
    
    var colorTitleLabeltextColor: UIColor = UIColor.cubeTintColor() {
        willSet {
            colorTitlelabel.textColor = newValue
        }
    }
    
    func makeUI() {
        
        contentView.addSubview(colorTitlelabel)
        colorTitlelabel.translatesAutoresizingMaskIntoConstraints = false
        
        let centerY = NSLayoutConstraint(item: colorTitlelabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
        let centerX = NSLayoutConstraint(item: colorTitlelabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([centerX, centerY])
    }
}

// MARK: - ACtionSheetDetailCell

final private class ActionSheetDetailCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
   
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .DisclosureIndicator
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        textLabel?.textColor = UIColor.darkGrayColor()
        textLabel?.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ActionSheetSwitchCell 

final private class ActionSheetSwitchCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    var action: (Bool -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        textLabel?.textColor = UIColor.darkGrayColor()
        textLabel?.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var checkedSwitch: UISwitch = {
        let s = UISwitch()
        s.addTarget(self, action: #selector(ActionSheetSwitchCell.toggleSwitch(_:)), forControlEvents: .ValueChanged)
        return s
    }()
    
    @objc func toggleSwitch(sender: UISwitch) {
        action?(sender.on)
    }
    
    func makeUI() {
        contentView.addSubview(checkedSwitch)
        checkedSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let centerY = NSLayoutConstraint(item: checkedSwitch, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: checkedSwitch, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -20)
        
        NSLayoutConstraint.activateConstraints([centerY, trailing])
    }
    
}


final private class ActionSheetSubtitleSwitchCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    var action: (Bool -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        makeUI()
            
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(19, weight: UIFontWeightLight)
        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(10, weight: UIFontWeightLight)
        label.textColor = UIColor.lightGrayColor()
        return label
    }()
    
    
    lazy var checkedSwitch: UISwitch = {
        let s = UISwitch()
        s.addTarget(self, action: #selector(ActionSheetSubtitleSwitchCell.toggleSwitch(_:)), forControlEvents: .ValueChanged)
        return s
    }()
    
    @objc private func toggleSwitch(sender: UISwitch) {
        action?(sender.on)
    }
    
    func makeUI() {
        
        contentView.addSubview(checkedSwitch)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkedSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        
        titleStackView.axis = .Vertical
        titleStackView.distribution = .Fill
        titleStackView.alignment = .Fill
        titleStackView.spacing = 2
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleStackView)
        
        do {
            let centerY = NSLayoutConstraint(item: titleStackView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView
                , attribute: .CenterY, multiplier: 1, constant: 0)
            let leading = NSLayoutConstraint(item: titleStackView, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1, constant: 20)
            
            NSLayoutConstraint.activateConstraints([centerY, leading])
        }
        
        do {
            let centerY = NSLayoutConstraint(item: checkedSwitch, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
            let trailing = NSLayoutConstraint(item: checkedSwitch, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activateConstraints([centerY, trailing])
        }
        
        let gap = NSLayoutConstraint(item: checkedSwitch, attribute: .Leading, relatedBy: .Equal, toItem: titleStackView, attribute: .Trailing, multiplier: 1, constant: 10)
        
        NSLayoutConstraint.activateConstraints([gap])
    }
}

final private class ActionSheetCheckCell: UITableViewCell {
    
    class var reuseIdentifier: String {
        return "\(self)"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var colorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        return label
    }()
    
    lazy var checkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_location_checkmark"))
        return imageView
    }()
    
    var colorTitleLabelTextColor: UIColor = UIColor.cubeTintColor() {
        willSet {
            colorTitleLabel.textColor = newValue
        }
    }
    
    func makeUI() {
        
        contentView.addSubview(colorTitleLabel)
        contentView.addSubview(checkImageView)
        colorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        do {
            let centerY = NSLayoutConstraint(item: colorTitleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)
            let centerX = NSLayoutConstraint(item: colorTitleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activateConstraints([centerY, centerX])
        }
        
        do {
            let centerY = NSLayoutConstraint(item: checkImageView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 0, constant: 1)
            let trailing = NSLayoutConstraint(item: checkImageView, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: -20)
            
            NSLayoutConstraint.activateConstraints([centerY, trailing])
        }
    }
}

final class ActionSheetView: UIView{
    
    enum Item {
        case Default(title: String, titleColor: UIColor, action: () -> Bool)
        case Detail(title: String, titleColor: UIColor, action: () -> Void)
        case Switch(title: String, titleColor: UIColor, switchOn: Bool, action: (switchOn: Bool) -> Void)
        case SubtitleSwitch(title: String, titleColor: UIColor, subtitle: String, subtitleColor: UIColor, switchOn: Bool, action: (switchOn: Bool) -> Void)
        case Check(title: String, titleColor: UIColor, checked: Bool, action: () -> Void)
        case Cancel
    }
    
    var items: [Item]
    
    private let rowHeight: CGFloat = 60
    
    private var totalHeight: CGFloat {
        return CGFloat(items.count) * rowHeight
    }
    
    init(items: [Item]) {
        self.items = items
        
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var containerView: UIView =  {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }()
    
    private lazy var tableView: UITableView = {
        [unowned self] in
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = self.rowHeight
        
        tableView.registerClass(ActionSheetDetailCell.self, forCellReuseIdentifier: ActionSheetDetailCell.reuseIdentifier)
        tableView.registerClass(ActionSheetDefaultCell.self, forCellReuseIdentifier: ActionSheetDefaultCell.reuseIdentifier)
        tableView.registerClass(ActionSheetSwitchCell.self, forCellReuseIdentifier: ActionSheetSwitchCell.reuseIdentifier)
        tableView.registerClass(ActionSheetSubtitleSwitchCell.self, forCellReuseIdentifier: ActionSheetSubtitleSwitchCell.reuseIdentifier)
        tableView.registerClass(ActionSheetCheckCell.self, forCellReuseIdentifier: ActionSheetCheckCell.reuseIdentifier)
        
        return tableView
        
    }()
    
    private var isFirstTimeBeenAddedAsSubview = true
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if isFirstTimeBeenAddedAsSubview {
            isFirstTimeBeenAddedAsSubview = false
            
            makeUI()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(ActionSheetView.hide))
            containerView.addGestureRecognizer(tap)
            
            tap.cancelsTouchesInView = true
            tap.delegate = self
        }
    }
    
    func refreshItems() {
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private var tableViewBottomConstraint: NSLayoutConstraint?
    
    func makeUI() {
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsDictionary: [String: AnyObject] = [
            "containerView": containerView,
            "tableView": tableView
        ]
        
        do {
            let constraintH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[containerView]|", options: [], metrics: nil, views: viewsDictionary)
            let constraintV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[containerView]|", options: [], metrics: nil, views: viewsDictionary)
            
            NSLayoutConstraint.activateConstraints(constraintH)
            NSLayoutConstraint.activateConstraints(constraintV)
        }
        
        do {
            let constrainH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: [], metrics: nil, views: viewsDictionary)
            
            let bottom = NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1, constant: 0)
            
            self.tableViewBottomConstraint = bottom
            
            let height = NSLayoutConstraint(item: tableView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.totalHeight)
            
            NSLayoutConstraint.activateConstraints(constrainH)
            NSLayoutConstraint.activateConstraints([bottom, height])
        }
    }
    
    
    func showInView(view: UIView) {
        
        frame = view.bounds
        
        view.addSubview(self)
        
        layoutIfNeeded()
        
        containerView.alpha = 1
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseIn, animations: {
            
            self.containerView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.3)
            
            }, completion: { _ in })
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            
            self.tableViewBottomConstraint?.constant = 0
            self.layoutIfNeeded()
            
            }, completion: { _ in })
        
    }
    
    func hide() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseIn, animations: {
            
            self.containerView.backgroundColor = UIColor.clearColor()
            
            }, completion: { _ in })
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            
            self.tableViewBottomConstraint?.constant = self.totalHeight
            self.layoutIfNeeded()
            
            }, completion: { _ in })
    }
    
    
    func hideAndDo(afterHideAction: (() -> Void)?) {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveLinear, animations: { _ in
            self.containerView.alpha = 0
            
            self.tableViewBottomConstraint?.constant = self.totalHeight
            
            self.layoutIfNeeded()
            
            }, completion: { finished in
                self.removeFromSuperview()
        })
        
        delay(0.1) {
            afterHideAction?()
        }
    }
}


// MARK: - UIGestureRecognizerDelegate

extension ActionSheetView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if touch.view! == containerView {
            return false
        }
        return true
    }
}

// MARK: - UITableViewDataSource&Delegate


extension ActionSheetView: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        
        switch item {
        case let .Default(title, titleColor, _):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(ActionSheetDefaultCell.reuseIdentifier) as! ActionSheetDefaultCell
            cell.colorTitlelabel.text = title
            cell.colorTitleLabeltextColor = titleColor
            
            return cell
            
        case let .Detail(title, titleColor, _):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(ActionSheetDetailCell.reuseIdentifier) as! ActionSheetDetailCell
            cell.textLabel?.text = title
            cell.textLabel?.textColor = titleColor
            
            return cell
            
        case let .Switch(title, titleColor, switchOn, action):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(ActionSheetSwitchCell.reuseIdentifier) as! ActionSheetSwitchCell
            cell.textLabel?.text = title
            cell.textLabel?.textColor = titleColor
            cell.checkedSwitch.on = switchOn
            cell.action = action
            
            return cell
            
        case let .SubtitleSwitch(title, titleColor, subtitle, subtitleColor, switchOn, action):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(ActionSheetSubtitleSwitchCell.reuseIdentifier) as! ActionSheetSubtitleSwitchCell
            cell.titleLabel.text = title
            cell.titleLabel.textColor = titleColor
            cell.subtitleLabel.text = subtitle
            cell.subtitleLabel.textColor = subtitleColor
            cell.checkedSwitch.on = switchOn
            cell.action = action
            
            return cell
            
        case let .Check(title, titleColor, checked, _):
            
            let cell = tableView.dequeueReusableCellWithIdentifier(ActionSheetCheckCell.reuseIdentifier) as! ActionSheetCheckCell
            cell.colorTitleLabel.text = title
            cell.colorTitleLabelTextColor = titleColor
            cell.checkImageView.hidden = !checked
            
            return cell
            
        case .Cancel:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(ActionSheetDefaultCell.reuseIdentifier) as! ActionSheetDefaultCell
            cell.colorTitlelabel.text = NSLocalizedString("Cancel", comment: "")
            cell.colorTitleLabeltextColor = UIColor.cubeTintColor()
            
            return cell
        }
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        let item = items[indexPath.row]
        
        switch item {
            
        case .Default(_, _, let action):
            
            if action() {
                hide()
            }
            
        case .Detail(_, _, let action):
            
            hideAndDo(action)
            
        case .Switch:
            
            break
            
        case .SubtitleSwitch:
            
            break
            
        case .Check(_, _, _, let action):
            
            action()
            hide()
            
        case .Cancel:
            
            hide()
            break
        }
    }
}



































