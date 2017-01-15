//
//  FeedsContainerViewController.swift
//  Lucuber
//
//  Created by Tychooo on 17/1/15.
//  Copyright © 2017年 Tychooo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class FeedsContainerViewController: UIPageViewController, CanScrollsToTop   {
    
    enum Option: Int {
        case subscribe
        case feeds
        
        static let count = 2
        
        var title: String {
            switch self {
            case .subscribe:
                return "我的订阅"
            case .feeds:
                return "话题"
            }
        }
    }
    
    fileprivate lazy var disposeBag = DisposeBag()
    
    var scrollView: UIScrollView? {
        
        switch currentOption {
        case .feeds:
            return feedsViewController.tableView
        case .subscribe:
            return subscribesViewController.tableView
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.removeAllSegments()
            
            (0..<Option.count).forEach({
                let option = Option(rawValue: $0)
                segmentedControl.insertSegment(withTitle: option?.title, at: $0, animated: false)
            })
            let font = UIFont.systemFont(ofSize: CubeRuler.iPhoneHorizontal(13, 14, 15).value)
            let padding: CGFloat = CubeRuler.iPhoneHorizontal(8, 11, 12).value
            segmentedControl.setTitleFont(font, withPadding: padding)
        }
    }
    
     lazy var feedsViewController: FeedsViewController = {
        
        let vc = UIStoryboard(name: "Feed", bundle: nil).instantiateViewController(withIdentifier: "FeedsViewController") as! FeedsViewController
        return vc
    }()
    
    fileprivate lazy var subscribesViewController: SubscribesViewController = {
       let vc = UIStoryboard(name: "Feed", bundle: nil).instantiateViewController(withIdentifier: "SubscribesViewController") as! SubscribesViewController
        return vc
    }()
    
    
    fileprivate lazy var creatNewFeedsButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(FeedsContainerViewController.createNewFeedsAction))
        return item
    }()
    
    var currentOption: Option = .feeds {
        didSet {
            segmentedControl.selectedSegmentIndex = currentOption.rawValue
            switch currentOption {
            case .subscribe:
                
                setViewControllers([subscribesViewController], direction: .reverse, animated: true, completion: nil)
                
                navigationItem.leftBarButtonItem = nil
                navigationItem.rightBarButtonItem = nil
                
            case .feeds:
                setViewControllers([feedsViewController], direction: .forward, animated: true, completion: nil)
                
                navigationItem.rightBarButtonItem = creatNewFeedsButtonItem
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarLine.isHidden = false
        
        currentOption = .subscribe
        segmentedControl.selectedSegmentIndex = currentOption.rawValue
        
        
        segmentedControl.rx.value
            .map({ Option(rawValue: $0) })
            .subscribe(onNext: { [weak self] in self?.currentOption = $0 ?? .subscribe })
            .addDisposableTo(disposeBag)
        
        
        self.dataSource = self
        self.delegate = self
        
        if traitCollection.forceTouchCapability == .available {
//            registerForPreviewing(with: self, sourceView: view)
        }
    }
    
    
    
    
    // MARK: - Target & Action
    func createNewFeedsAction() {
        
    }
    
    func clearUnread() {
        
    }
    
    
}

extension FeedsContainerViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController == feedsViewController {
            return subscribesViewController
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController == subscribesViewController {
            return feedsViewController
        }
        return nil
    }
}

extension FeedsContainerViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else {
            return
        }
        
        if previousViewControllers.first == subscribesViewController {
            currentOption = .feeds
        } else if previousViewControllers.first == feedsViewController {
            currentOption = .subscribe
        }
        segmentedControl.selectedSegmentIndex = currentOption.rawValue
    }
}

