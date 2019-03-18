//
//  PageVendor.swift
//  HKBanner
//
//  Created by Harley-xk on 2019/3/18.
//  Copyright © 2019 Harley. All rights reserved.
//

import Foundation
import UIKit

/// Banner Page 的通用协议, 任何满足该协议的视图控制器都可以作为 Banner 的 Page 使用
public protocol BannerPageable {
    
    /// 当前页的索引
    var index: Int { get set }
    
    /// 当 page 重新显示时会调用该方法通知视图控制器刷新页面
    func refreshPageContent()
}

/// Banner Page 必须是 UIViewController 类型
public typealias BannerPage = (UIViewController & BannerPageable)

/// Banner Page 分发器，负责具体页面的创建和分发
public protocol BannerPageVendor {
    
    /// page 的数量
    var pageCount: Int { get }
        
    /// BannerView 会调用该方法来获取具体的一个 page, page 的 index 会自动赋值
    func getPage(at index: Int) -> BannerPage
}
