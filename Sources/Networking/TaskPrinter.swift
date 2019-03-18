//
//  TaskPrinter.swift
//  Comet-Networking
//
//  Created by Harley.xk on 2018/11/12.
//  Copyright © 2018年 Harley-xk. All rights reserved.
//

import UIKit
import Alamofire

open class TaskPrinter {
    
    public init(bindTo center: TaskCenter) {
        taskCenter = center
    }
    
    public private(set) weak var taskCenter: TaskCenter!
    
    public func taskStarted<T: Taskable>(_ task: T, request: DataRequest) {
        let date = Date().string(format: "yyyy-MM-dd HH:mm:ss.SSS")
        let server = task.targetServer ?? taskCenter.defaultServer
        print()
        print("TaskStarted: ", date, "-+-+-+-+-+-+-+-+-+->")
        print("       Host: ", server.pathWithService)
        print("        Api: ", task.method.rawValue, task.api)
        print("     Header: ", request.request?.allHTTPHeaderFields ?? [:])
        print("     Params: ", task.parameters)
        print()
    }
    
    public func taskCanceled(_ task: URLSessionTask) {
        let date = Date().string(format: "yyyy-MM-dd HH:mm:ss.SSS")
        print()
        print("TaskCanceled: ", date, "-+-+-+-+-+-+-+-+-+->")
        print("         URL: ", task.currentRequest?.url?.absoluteString ?? "")
        print()
    }
    
    public func taskFinished<T: Taskable>(_ task: T, response: DataResponse<Data>) {
        let date = Date().string(format: "yyyy-MM-dd HH:mm:ss.SSS")
        let server = task.targetServer ?? taskCenter.defaultServer
        print()
        print("TaskFinished: ", date, "------------------->")
        print("        Host: ", server.pathWithService)
        print("         Api: ", task.method.rawValue, task.api)
        print("      Status: ", response.response?.statusCode ?? "-1")
        if case let .failure(error) = response.result {
            print("       Error: ", error.localizedDescription)
        }
        
        if var jsonData = response.data {
            if let json = try? JSONSerialization.jsonObject(with: jsonData), let dataForPrint = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                jsonData = dataForPrint
            }
            let string = String(data: jsonData, encoding: .utf8)
            print("    Response: ")
            print(string ?? "<null>")            
        } else {
            print("    Response: ", "<null>")
        }
        print()
    }
}
