//
//  Banner.swift
//  Banner
//
//  Created by Harley-xk on 2019/3/18.
//  Copyright © 2019 Harley. All rights reserved.
//

import Foundation
import UIKit

open class Banner: UIImageView {
    
    public convenience init(options: BannerOptions) {
        self.init()
        self.options = options
    }

    /// 配置项
    open var options: BannerOptions = .default
    
    /// 刷新页面
    open func reload(with pageVendor: BannerPageVendor, beginIndex: Int = 0) {
        self.setupPages()
        pageController?.reload(with: pageVendor, beginIndex: beginIndex)
    }
    
    // MARK: - Private    
    private var pageController: ScrollingPageController?
    
    private func setupPages() {
        if pageController == nil {
            pageController = ScrollingPageController(options: options)
            addSubview(pageController!.view)
            pageController?.view.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
}
