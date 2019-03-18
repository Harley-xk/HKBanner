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
        }
        
        pageContainers.last?.snp.makeConstraints {
            $0.right.equalToSuperview()
        }
        
        if options.isCyclic {
            DispatchQueue.main.async {
                self.scrollToIndex(pageVendor.pageCount)
            }
        }
    }
    
    func scrollToIndex(_ index: Int) {
        var offset = scrollView.contentOffset
        offset.x = scrollView.bounds.width * CGFloat(index)
        
        scrollView.delegate = nil
        scrollView.setContentOffset(offset, animated: false)
        scrollView.delegate = self
    }
}

extension ScrollingPageController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let count = pageVendor?.pageCount ?? 0
        
        let index = scrollView.contentOffset.x / scrollView.bounds.size.width
        
        options.scrollingHandlers.running?(scrollView.contentOffset.x)
        
        if options.isCyclic {
            if index <= 1 {
                let beginIndex = count + 1
                scrollToIndex(beginIndex)
            } else if index >= CGFloat(count * cyclicRepreat - 2) {
                var page = count - 2
                while page < 1 {
                    page += count
                }
                scrollToIndex(page)
            }
        }
    }
}
