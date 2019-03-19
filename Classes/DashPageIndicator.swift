//
//  DashPageIndicator.swift
//  YXT
//
//  Created by Harley.xk on 2018/11/21.
//  Copyright © 2018 Cloud World. All rights reserved.
//

import UIKit
import SnapKit

/// 自定义短横线风格的页码指示器
open class DashPageIndicator: UIView, PageIndicatable {
    
    /// 每一页短横线的长度，默认 12
    open var dashLength: CGFloat = 12
    /// 两个短横线之间的间隔， 默认 8
    open var dashPadding: CGFloat = 8
    /// 表示当前页的短横线的长度，默认 12
    open var currentDashLength: CGFloat = 12
    
    /// 总页数
    open var numberOfPages: Int = 2 {
        didSet {
            update()
        }
    }
    /// 当前页码
    open var currentPage: Int = 0 {
        didSet {
            update()
        }
    }
    
    public typealias ColorProvider = (_ page: Int, _ isCurrentPage: Bool) -> (UIColor)
    
    /// 提供颜色的回调，可以用来自定义指示器的颜色，默认颜色：当前页 白色，其他页：白色半透明
    open var colorProvider: ColorProvider = { (index, currentPage) in
        if currentPage {
           return UIColor.white
        } else {
            return UIColor.white.withAlphaComponent(0.5)
        }
    }
    
    /// 更新视图
    func update() {
        backgroundColor = .clear
        setNeedsDisplay()
    }
    
    override open func draw(_ rect: CGRect) {
        // Drawing code
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let totalLength = (dashLength + dashPadding) * CGFloat(numberOfPages - 1) + currentDashLength - dashPadding
        let begin = (rect.width - totalLength) / 2
        
        var previous = begin
        for i in 0 ..< numberOfPages {
            let length = i <= currentPage ? currentDashLength : dashLength
            let padding = dashPadding
            let dash = CGRect(x: previous + padding, y: 0, width: length, height: rect.height)
            previous += padding + length
            let color = colorProvider(i, i == currentPage)
            color.set()
            context.fill(dash)
        }
    }
}
