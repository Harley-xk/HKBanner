//
//  BannerOptions.swift
//  HKBanner
//
//  Created by Harley-xk on 2019/3/18.
//  Copyright © 2019 Harley. All rights reserved.
//

import Foundation
import UIKit

public struct BannerOptions {
    /// 默认设置
    public static let `default` = BannerOptions()
    
    /// 整个 banner 的内容相对于视图向内的锁进
    public var bannerInsets = UIEdgeInsets.zero
    
    /// 单个 page 相对于自己位置向内的缩紧，通过这个配置可以实现 banner 空白间隔的效果
    public var pageInset = UIEdgeInsets.zero
    
    /// 是否支持循环滚动，默认关闭
    var isCyclic = false
    
    /// Scrollview 相关回调
    public var scrollingHandlers = ScrollingHandlers()
}

public struct ScrollingHandlers {
    
    typealias Begin = () -> ()
    typealias Running = (_ offset: CGFloat) -> ()
    typealias Finished = (_ index: Int) -> ()
    
    var begin: Begin?
    var running: Running?
    var finished: Finished?
}
