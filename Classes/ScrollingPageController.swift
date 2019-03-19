//
//  ScrollingPageController.swift
//  HKBanner
//
//  Created by Harley-xk on 2019/3/18.
//  Copyright © 2019 Harley. All rights reserved.
//

import UIKit
import SnapKit

class ScrollingPageController: UIViewController, BannerPageController {
    
    convenience init(options: BannerOptions) {
        self.init()
        self.options = options
    }
    
    private var options: BannerOptions = .default
    private var pageVendor: BannerPageVendor?
    private var pageContainers: [UIView] = []
    private var pages: [BannerPage] = []
    
    weak var scrollView: UIScrollView!
    
    override func loadView() {
        super.loadView()
        let sc = UIScrollView()
        view.addSubview(sc)
        scrollView = sc
        scrollView.isPagingEnabled = true
        scrollView.clipsToBounds = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(options.bannerInsets)
        }
    }
    
    func reload(with pageVendor: BannerPageVendor, beginIndex: Int = 0) {
        self.pageVendor = pageVendor
        
        pageContainers.forEach { $0.removeFromSuperview() }
        pageContainers.removeAll()
        
        let count = pageVendor.pageCount
        var indexList: [Int] = (0 ..< count).compactMap{ $0 }
        if options.isCyclic {
            /// 只有一个对象的补齐为5个
            if count == 1 {
                indexList += [0, 0, 0, 0]
            } else {
                indexList = [count - 2, count - 1] + indexList + [0, 1]
            }
        }
                
        var leading: ConstraintRelatableTarget = scrollView.snp.left
        for page in indexList {
            let container = UIView()
            scrollView.addSubview(container)
            container.snp.makeConstraints {
                $0.left.equalTo(leading)
                $0.top.bottom.width.height.equalToSuperview()
            }
            leading = container.snp.right
            pageContainers.append(container)
            
            let pageView = pageVendor.getPage(at: page)
            container.addSubview(pageView.view)
            pageView.view.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(options.pageInset)
            }
            pages.append(pageView)
        }
        
        pageContainers.last?.snp.makeConstraints {
            $0.right.equalToSuperview()
        }
        
        DispatchQueue.main.async {
            self.scrollTo(0, animated: false)
        }
        
        options.pageIndicator?.numberOfPages = pageVendor.pageCount
    }
    
    // MARK: - Scrolling
    
    private var pageCount: Int {
        return pageVendor?.pageCount ?? 0
    }
    
    private func getPage(from index: Int) -> Int {
        if !options.isCyclic {
            return index
        }
        var p = index - 2
        if p < 0 {
            p += pageCount
        }
        return p
    }
    
    private func getIndex(from page: Int) -> Int {
        return options.isCyclic ? page + 2 : page
    }
    
    func scrollToIndex(_ index: Int, animated: Bool = true) {
        
        var offset = scrollView.contentOffset
        offset.x = scrollView.bounds.width * CGFloat(index)
        
        scrollView.delegate = nil
        scrollView.setContentOffset(offset, animated: animated)
        scrollView.delegate = self
        
        if !animated {
            didScroll(to: index)
        }
    }
    
    private var currentPage: Int = -1
    private var currentIndex: Int = -1
    
    private func didScroll(to index: Int) {
        guard index != currentIndex else {
            return
        }
        currentIndex = index
        currentPage = getPage(from: index)
        options.pageIndicator?.currentPage = currentPage
        
        beginAutoScroll()
        options.scrollingHandlers.finished?(currentPage)
    }
    
    private func scrollTo(_ page: Int, animated: Bool = true) {
        let index = getIndex(from: page)
        if animated {
            scrollToIndex(index - 1, animated: false)
        }
        scrollToIndex(index, animated: animated)
    }
    
    private func scrollToNext() {
        var target = currentPage + 1
        if target == pageCount {
            target = 0
        }
        scrollTo(target)
    }
    
    // MARK: - AutoScroll
    /// 自动滚屏的定时器
    private var autoScrollTimer: Timer?
    
    /// 开始自动滚屏
    func beginAutoScroll() {
        
        stopAutoScroll()
        
        guard options.autoScrollDelay > 0 else {
            return
        }
        autoScrollTimer = Timer(timeInterval: options.autoScrollDelay, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: false)
        RunLoop.main.add(autoScrollTimer!, forMode: .common)
        autoScrollTimer?.fireDate = Date().addingTimeInterval(options.autoScrollDelay)
    }
    
    @objc
    private func autoScroll() {
        scrollToNext()
        stopAutoScroll()
    }
    
    func stopAutoScroll() {
        if autoScrollTimer != nil {
            autoScrollTimer?.invalidate()
            autoScrollTimer = nil
        }
    }
}

extension ScrollingPageController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        didScroll(to: index)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        didScroll(to: index)

        options.scrollingHandlers.running?(scrollView.contentOffset.x)
        
        if options.isCyclic {
            if index < 1 {
                scrollTo(pageCount - 1, animated: false)
            } else if index >= pageCount + 2 {
                scrollTo(0, animated: false)
            }
        }
    }
}
