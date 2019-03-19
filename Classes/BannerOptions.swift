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

/// Banner 的各种配置项
public struct BannerOptions {
    /// 默认设置
    public static let `default` = BannerOptions()
    
    /// 整个 banner 的内容相对于视图向内的锁进
    public var bannerInsets = UIEdgeInsets.zero
    
    /// 单个 page 相对于自己位置向内的缩紧，通过这个配置可以实现 banner 空白间隔的效果
    public var pageInset = UIEdgeInsets.zero
    
    /// 自动滚屏间隔，默认 0，不自动滚屏
    public var autoScrollDelay: TimeInterval = 0
    
    /// 是否支持循环滚动，默认关闭
    public var isCyclic = false
    
    /// 页码指示器
    public var pageIndicator: (PageIndicatable & UIView)?
    
    public struct PageIndicatorPosition {
        var leftInset, rightInset, bottomInset: CGFloat
        var height: CGFloat
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
