//
//  SystemPageController.swift
//  CommonUI
//
//  Created by Harley.xk on 2018/6/4.
//  Copyright © 2018年 Harley. All rights reserved.
//

import UIKit
import SnapKit

class SystemPageController: UIPageViewController, BannerPageController {
    
    typealias BannerPage = (UIViewController & BannerPageable)
    
    private var options: BannerOptions = .default

    convenience init(options: BannerOptions) {
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal,
                  options: [.interPageSpacing: options.pageSpacing])
        self.options = options
    }

    var beginIndex = 0
    
    /// page 分发器，用于分发每一页实际的视图控制器
    private var pageVender: BannerPageVendor?

    func reload(with pageVendor: BannerPageVendor, beginIndex: Int) {
        self.pageVender = pageVendor
        self.beginIndex = beginIndex
        options.pageIndicator?.numberOfPages = pageVendor.pageCount
        loadPage(at: beginIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        view.backgroundColor = .clear
        
        loadPage(at: beginIndex)
    }
    
    var pageCount: Int {
        return pageVender?.pageCount ?? 0
    }
    
    func loadPage(at index: Int = 0) {
        guard let page = getPage(at: index) else {
            return
        }
        setViewControllers([page], direction: .forward, animated: false, completion: nil)
        options.pageIndicator?.currentPage = index
        options.scrollingHandlers.finished?(index)
    }
    
    func scrollToNext() {
        if let page = viewControllers?.first as? BannerPage {
            var index = page.index + 1
            var direction = UIPageViewController.NavigationDirection.forward
            if index >= pageCount {
                index = 0
                direction = .reverse
            }
            guard let nextPage = getPage(at: index) else {
                return
            }
            setViewControllers([nextPage], direction: direction, animated: true) { (_) in
                self.options.pageIndicator?.currentPage = index
                self.options.scrollingHandlers.finished?(index)
            }
        }
    }
    
    private var cachedPages: [Int: BannerPage] = [:]
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        cachedPages.removeAll()
    }
    
    private func getPage(at index: Int) -> BannerPage? {
        
        guard let pageVender = pageVender else {
            return nil
        }
        
        var index = index
        let count = pageCount
        if options.isCyclic {
            if index < 0 { index = count - 1}
            if index >= count { index = 0 }
        }
        if index < 0 || index >= count {
            return nil
        }
        if let page = cachedPages[index] {
            DispatchQueue.main.async {
                page.refreshPageContent()
            }
            return page
        } else {
            var page = pageVender.getPage(at: index)
            page.index = index
            return page
        }
    }
}

extension SystemPageController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? BannerPage else {
            return nil
        }
        return getPage(at: page.index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? BannerPage else {
            return nil
        }
        return getPage(at: page.index + 1)
    }
    
}

extension SystemPageController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished, completed, let vc = viewControllers?.first as? BannerPage {
            options.pageIndicator?.currentPage = vc.index
            options.scrollingHandlers.finished?(vc.index)
        }
    }
}
