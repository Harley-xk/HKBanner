//
//  Banner.swift
//  Banner
//
//  Created by Harley-xk on 2019/3/18.
//  Copyright © 2019 Harley. All rights reserved.
//

import Foundation
import UIKit

protocol BannerPageController {
    func reload(with pageVendor: BannerPageVendor, beginIndex: Int)
}

open class Banner: UIImageView {
    
    public convenience init(options: BannerOptions) {
        self.init()
        self.options = options
        isUserInteractionEnabled = true
    }
    
    /// 配置项
    open var options: BannerOptions = .default
    
    /// 刷新页面
    open func reload(with pageVendor: BannerPageVendor, beginIndex: Int = 0) {
        self.setupPages()
        pageController?.reload(with: pageVendor, beginIndex: beginIndex)
    }
    
    // MARK: - Private
    private var pageController: (BannerPageController & UIViewController)?
    
    private func setupPages() {
        if pageController == nil {
            setupPageController()
        }
        
        if let pageIndicator = self.options.pageIndicator, pageIndicator.superview == nil {
            addSubview(pageIndicator)
            pageIndicator.snp.makeConstraints {
                $0.left.equalToSuperview().inset(options.indicatorPosition.leftInset)
                $0.right.equalToSuperview().inset(options.indicatorPosition.rightInset)
                $0.bottom.equalToSuperview().inset(options.indicatorPosition.bottomInset)
                $0.height.equalTo(options.indicatorPosition.height)
            }
        }
    }
    
    // MARK: - PageControlers
    
    func setupPageController() {
        if options.pageEngineType == .scrollView {
            pageController = ScrollingPageController(options: options)
            addSubview(pageController!.view)
            pageController?.view.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        } else {
            pageController = SystemPageController(options: options)
            addSubview(pageController!.view)
            pageController?.view.snp.makeConstraints {
                $0.edges.equalToSuperview().inset(options.bannerInsets)
            }
        }
    }
}
