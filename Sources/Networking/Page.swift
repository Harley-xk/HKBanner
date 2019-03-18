//
//  Page.swift
//  YXT
//
//  Created by Harley.xk on 2018/11/21.
//  Copyright © 2018 Cloud World. All rights reserved.
//

import Foundation

/// 分页参数
public struct PageParam {
    public var page: Int
    public var size: Int = 10
    
    public static func first(size: Int = 10) -> PageParam {
        return PageParam(page: 0, size: size)
    }

    public func next() -> PageParam {
        return PageParam(page: page + 1, size: size)
    }
    
    public var capacity: Int {
        return page * size
    }
}

public struct Page<M: Codable>: Codable {
    public var page: Int
    public var size: Int
    public var total: Int
    public var data: [M]
    
    public var isLastPage: Bool {
        return page * size + data.count >= total
    }
    
    public func nextPageParam() -> PageParam {
        return PageParam(page: page + 1, size: size)
    }
}
