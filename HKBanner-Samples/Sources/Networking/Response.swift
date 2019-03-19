//
//  ResponseEntity.swift
//  Comet-Networking
//
//  Created by Harley.xk on 2018/11/12.
//  Copyright © 2018年 Harley-xk. All rights reserved.
//

import UIKit
import Alamofire

public struct Response<T: Codable> {
    
    var succeed: Bool = false
    
    var data: T?
    var message: String?
    var statusCode = -1
    var error: Error?
    
    public init(data: T) {
        self.succeed = true
        self.data = data
    }
    
    public init(error: NSError) {
        self.error = error
        self.statusCode = error.code
        self.message = error.localizedDescription
    }
}

