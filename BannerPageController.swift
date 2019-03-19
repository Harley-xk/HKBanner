//
//  BannerPageController.swift
//  CommonUI
//
//  Created by Harley.xk on 2018/6/4.
//  Copyright © 2018年 Harley. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

protocol ImageBannerItem {
    var bannerTitle: String? { get }
    func setImageForBanner(imageView: UIImageView)
}

extension URL: ImageBannerItem {
    var bannerTitle: String? {
        return nil
    }

    func setImageForBanner(imageView: UIImageView) {
        imageView.image = nil
        imageView.kf.setImage(with: self)
    }
}

class BannerPageController: UIPageViewController {
    
    typealias BannerPage = (UIViewController & BannerPageable)
    
    /// 是否可以循环滚动
    @IBInspectable var isCyclic: Bool = false
    
    var beginIndex = 0
    
    /// page 分发器，用于分发每一页实际的视图控制器
    private var pageVender: BannerPageVender!

    init(vender: BannerPageVender, in view: UIView, edgeInsets: UIEdgeInsets, scrollHandler h: BannerView.ScrollHandler?) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageVender = vender
        container = view
        scrollHandler = h
        
        DispatchQueue.main.async {
            self.container.insertSubview(self.view, at: 0)
            self.view.snp.makeConstraints { (maker) in
                maker.left.equalToSuperview().inset(edgeInsets.left)
                maker.right.equalToSuperview().inset(edgeInsets.right)
                maker.top.equalToSuperview().inset(edgeInsets.top)
                maker.bottom.equalToSuperview().inset(edgeInsets.bottom)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        view.backgroundColor = .clear
        
        loadPage(at: beginIndex)
    }

    func updatePages(with vender: BannerPageVender, beginAt index: Int = 0) {
        pageVender = vender
        loadPage(at: index)
    }
    
    func loadPage(at index: Int = 0) {
        let page = getPage(at: index)!
        setViewControllers([page], direction: .forward, animated: false, completion: nil)
        scrollHandler?(index)
    }
    
    func scrollToNext() {
        if let page = viewControllers?.first as? BannerPage {
            var index = page.index + 1
            var direction = UIPageViewController.NavigationDirection.forward
            if index >= pageVender.pageCount {
                index = 0
                direction = .reverse
            }
            let nextPage = getPage(at: index)!
            setViewControllers([nextPage], direction: direction, animated: true) { (_) in
                self.scrollHandler?(index)
            }
            
        }
    }
    
    var scrollHandler: BannerView.ScrollHandler?
    
    private weak var container: UIView!
    private var cachedPages: [Int: BannerPage] = [:]
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        cachedPages.removeAll()
    }
    
    private func getPage(at index: Int) -> BannerPage? {
        var index = index
        let count = pageVender.pageCount
        if isCyclic {
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

extension BannerPageController: UIPageViewControllerDataSource {
    
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

extension BannerPageController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished, completed, let vc = viewControllers?.first as? BannerPage {
            scrollHandler?(vc.index)
        }
    }
}
