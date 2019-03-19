//
//  ImageBannerVendor.swift
//  HKBanner
//
//  Created by Harley-xk on 2019/3/18.
//  Copyright © 2019 Harley. All rights reserved.
//

import Foundation
import UIKit

/// 可以在 banner 上显示的数据协议
public protocol ImageBannerItem {
    func setImageForBanner(imageView: UIImageView)
}

/// 用户透传的 page 事件回调
public typealias BannerPageAction = (Int) -> ()

/// 默认的图片 banner 分发器
open class ImagePageVendor<T: BannerPage>: BannerPageVendor {
    
    /// 透传的图片点击事件
    private var tapAction: BannerPageAction?
    
    public init(items: [ImageBannerItem], tapAction: BannerPageAction?) {
        self.items = items
        self.pageCount = items.count
        self.tapAction = tapAction
    }
    
    private var items: [ImageBannerItem]
    
    public private(set) var pageCount: Int
    
    public func getPage(at index: Int) -> BannerPage {
        let page = ImageBannerPage()
        page.action = tapAction
        page.index = index
        page.item = items[index]
        return page
    }
}
