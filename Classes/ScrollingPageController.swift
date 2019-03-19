//
//  ScrollingPageController.swift
//  HKBanner
//
//  Created by Harley-xk on 2019/3/18.
//  Copyright © 2019 Harley. All rights reserved.
//

import UIKit
import SnapKit

class ScrollingPageController: UIViewController {
    
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
    
    private var cyclicRepreat = 1
    
    func reload(with pageVendor: BannerPageVendor, beginIndex: Int = 0) {
        self.pageVendor = pageVendor
        
        pageContainers.forEach { $0.removeFromSuperview() }
        pageContainers.removeAll()
        
        if options.isCyclic {
            if pageVendor.pageCount == 1 {
                cyclicRepreat = 4
            } else if pageVendor.pageCount == 2 {
                cyclicRepreat = 3
            } else {
                cyclicRepreat = 2
            }
        }
        
        var leading: ConstraintRelatableTarget = scrollView.snp.left
        for i in 0 ..< pageVendor.pageCount * cyclicRepreat {
            let container = UIView()
            scrollView.addSubview(container)
            container.snp.makeConstraints {
                $0.left.equalTo(leading)
                $0.top.bottom.width.height.equalToSuperview()
            }
            leading = container.snp.right
            pageContainers.append(container)
            
            let index = i % pageVendor.pageCount
            
            let page = pageVendor.getPage(at: index)
            container.addSubview(page.view)
            page.view.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(options.pageInset)
            }
            pages.append(page)
            
            let label = UILabel()
            label.text = "p: \(index), i: \(i)"
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            page.view.addSubview(label)
            label.snp.makeConstraints { $0.center.equalToSuperview() }
            label.backgroundColor = .black
        }
        
        pageContainers.last?.snp.makeConstraints {
            $0.right.equalToSuperview()
        }
        
        if options.isCyclic {
            DispatchQueue.main.async {
                self.scrollToIndex(pageVendor.pageCount)
            }
        }
        
        options.pageIndicator?.numberOfPages = pageVendor.pageCount
    }
    
    // MARK: - Scrolling
    
    private var pageCount: Int {
        return pageVendor?.pageCount ?? 0
    }
    
    func scrollToIndex(_ index: Int, animated: Bool = true) {
        
        print("Will scroll to page: \(index % pageCount), at index: \(index), animated: \(animated)")

        var offset = scrollView.contentOffset
        offset.x = scrollView.bounds.width * CGFloat(index)
        
        scrollView.delegate = nil
        scrollView.setContentOffset(offset, animated: animated)
        scrollView.delegate = self
        
        if !animated {
            didScroll(to: index % pageCount)
        }
    }
    
    private var currentPage: Int = -1
    private var currentIndex: Int = -1
    
    private func didScroll(to index: Int) {
        guard index != currentIndex else {
            return
        }
        currentIndex = index
        currentPage = index % pageCount
        options.pageIndicator?.currentPage = currentPage
        
        beginAutoScroll()
        options.scrollingHandlers.finished?(currentPage)
        
        print("Did scroll to page: \(currentPage), at index: \(index)")
    }
    
    private func scrollTo(_ page: Int) {
        var index = currentIndex + (page - currentPage)
        if index <= 1 {
            index += pageCount
        }
        if index >= pageCount * cyclicRepreat - 2 {
            index -= pageCount
        }
        scrollToIndex(index - 1, animated: false)
        scrollToIndex(index)
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
        
        let index = scrollView.contentOffset.x / scrollView.bounds.size.width
        didScroll(to: Int(index))

        options.scrollingHandlers.running?(scrollView.contentOffset.x)
        
        if options.isCyclic {
            if index <= 1 {
                let beginIndex = pageCount + 1
                scrollToIndex(beginIndex, animated: false)
            } else if index >= CGFloat(pageCount * cyclicRepreat - 2) {
                var page = pageCount - 2
                while page < 1 {
                    page += pageCount
                }
                scrollToIndex(page, animated: false)
            }
        }
    }
}
