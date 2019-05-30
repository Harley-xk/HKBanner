//
//  BannerOptions.swift
//  HKBanner
//
//  Created by Harley-xk on 2019/3/18.
//  Copyright © 2019 Harley. All rights reserved.
//

import Foundation
import UIKit

/// 页码指示器通用协议
public protocol PageIndicatable {
    var numberOfPages: Int { get set }
    var currentPage: Int { get set }
}

/// 使系统的页码指示器满足协议
extension UIPageControl: PageIndicatable {}

/// 分页驱动器
public enum BannerPageEngineType {
    case scrollView
    case pageController
}

/// Banner 的各种配置项
public struct BannerOptions {
    /// 默认设置
    public static let `default` = BannerOptions()
    
    /// 整个 banner 的内容相对于视图向内的缩进
    public var bannerInsets = UIEdgeInsets.zero
    
    /// 单个 page 相对于自己位置向内的缩进，通过这个配置可以实现 banner 空白间隔的效果
    /// - Attention: 该属性对 pageController 模式无效
    public var pageInset = UIEdgeInsets.zero
    
    /// 分页间隔，该属性只对 pageController 模式生效
    public var pageSpacing: CGFloat = 0
    
    /// 自动滚屏间隔，默认 0，不自动滚屏
    public var autoScrollDelay: TimeInterval = 0
    
    /// 是否支持循环滚动，默认关闭
    public var isCyclic = false
    
    /// 底层的分页驱动器, 可以选择是使用 UIPageController 驱动或者使用 UIScrollView 驱动
    /// 默认使用 UIScrollView，可以支持更丰富的样式定制，不过在某些场景下可能存在手势冲突，此时建议切换为 UIPageController
    public var pageEngineType = BannerPageEngineType.scrollView
    
    /// 页码指示器
    public var pageIndicator: (PageIndicatable & UIView)?
    
    public struct PageIndicatorPosition {
        public var leftInset, rightInset, bottomInset: CGFloat
        public var height: CGFloat
    }
    /// 页码指示器的位置偏移, 默认定位在 banner 底部剧中
    public var indicatorPosition = PageIndicatorPosition(leftInset: 0, rightInset: 0, bottomInset: 5, height: 1)
    
    /// Scrollview 相关回调
    public var scrollingHandlers = ScrollingHandlers()
    
    public init(bannerInsets: UIEdgeInsets = .zero, pageInset: UIEdgeInsets = .zero, isCyclic: Bool = false) {
        self.bannerInsets = bannerInsets
        self.pageInset = pageInset
        self.isCyclic = isCyclic
    }
}

public struct ScrollingHandlers {
    
    public typealias Begin = () -> ()
    public typealias Running = (_ offset: CGFloat) -> ()
    public typealias Finished = (_ index: Int) -> ()
    
    public var begin: Begin?
    public var running: Running?
    public var finished: Finished?
    
    public init(begin: Begin? = nil, running: Running? = nil, finished: Finished? = nil) {
        self.begin = begin
        self.running = running
        self.finished = finished
    }
}
