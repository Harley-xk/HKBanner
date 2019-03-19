//
//  NetworkCenter.swift
//  Comet-Networking
//
//  Created by Harley.xk on 2018/11/12.
//  Copyright © 2018年 Harley-xk. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Comet

/// 网络请求的调度中心
public class TaskCenter: SessionManager {

    /// 指定接口服务器，初始化网络主控制器。
    ///
    /// - Parameters:
    ///   - server: 目标服务器，发送请求的目标服务器未设置时，会使用该值
    ///   - configuration: 网络配置参数
    /// - Attention: 没有初始化而直接调用 TaskCenter.main 会导致 Crash！
    /// - Note: 初始化不是必须的，但是只有初始化之后才能直接使用 TaskCenter.main 主控制器，否则需要自行创建服务器
    public static func setupMainCenterWith(server: Server, configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        let configuration = URLSessionConfiguration.default
        let taskCenter = TaskCenter(server: server, configuration: configuration)
        #if DEBUG
        taskCenter.printer = TaskPrinter(bindTo: taskCenter)
        #endif
        mainTaskCenter = taskCenter
    }
    
    /// 全局默认控制器，需要初始化后才能使用
    /// - Seealso: setupMainCenterWith(server:, configuration:) 
    public static var main: TaskCenter {
        assert(mainTaskCenter != nil, "Main TaskCenter called before initialize!")
        return mainTaskCenter!
    }

    /// 请求的默认目标服务器，如果没有给 Task 指定目标服务器，就会使用该值
    /// 如果两个服务器都没有制定，会造成 App Crash ！
    public var defaultServer: Server
    
    /// 默认解码器，新创建的 Task 如果不另外指定将使用该解码器
    public var defaultDecoder = JSONDecoder()
    
    /// 负责日志打印，一般只在 DEBUG 模式下实例化
    public var printer: TaskPrinter?

    /// 启动任务
    @discardableResult
    public func startTask<T: Taskable>(_ task: T, completion: ((Response<T.Model>) -> ())?) -> Request {
        
        let server = task.targetServer ?? defaultServer
        
        var headers = task.additionalHeaders
//        if task.authenticationNeeded, let token = UserCenter.shared.token?.value {
//            headers["Authorization"] = "Bearer \(token)"
//        }
        let request = self.request(server.fullPath(with: task.api),
                                   method: task.method,
                                   parameters: task.parameters,
                                   encoding: task.paramEncoding,
                                   headers: headers)
        
        request.responseData { (dataResponse) in
            self.printer?.taskFinished(task, response: dataResponse)
            let response = task.decodeData(from: dataResponse)
            
            /// 需要身份验证的 api 返回 401，发出身份验证失败的通知
            if task.authenticationNeeded, response.statusCode == 401 {
                NotificationCenter.default.post(name: NotificationName.UserAuthenticationFailed, object: nil)
            }
            
            completion?(response)
        }
        
        /// 打印请求数据
        printer?.taskStarted(task, request: request)
        
        return request
    }
    
    // MARK: - Reachablity
    private var reachabilityManager: NetworkReachabilityManager?
    
    typealias ReachabilityStatus = NetworkReachabilityManager.NetworkReachabilityStatus
    
    /// 网络连接状态
    var networkReachabilityStatus: ReachabilityStatus = .unknown
    
    /// 网络连通
    var isNetworkReachable: Bool {
        if case .reachable(_) = networkReachabilityStatus {
            return true
        }
        return false
    }
    
    /// Wifi 连接
    var isWiFiReachable: Bool {
        if case .reachable(.ethernetOrWiFi) = networkReachabilityStatus {
            return true
        }
        return false
    }

    /// 网络状态监听器，状态变化后会通过 Notification 广播
    private func networkReachabilityChanged(to newStatus: ReachabilityStatus) {
        #if DEBUG
        print("TaskCenter Message: NetworkReachability changed to: \(newStatus)")
        #endif
        
        let reachableChanged = checkIsReachableChanged(with: newStatus)
        
        networkReachabilityStatus = newStatus
        
        if reachableChanged {
            /// 只有当网络可用状态发生变化时才会广播，建议使用该通知来监听网络变化
            NotificationCenter.default.post(name: NotificationName.ReachableStatusChanged, object: nil, userInfo: nil)
        }
        
        /// 只要网络连接状态发生变化都会广播
        NotificationCenter.default.post(name: NotificationName.ConnectionStatusChanged, object: nil, userInfo: nil)
    }
    
    /// 判断网络可用状态是否发生改变
    private func checkIsReachableChanged(with newStatus: ReachabilityStatus) -> Bool {
        if case .reachable(_) = networkReachabilityStatus, case .notReachable = newStatus {
            return true
        }
        if case .reachable(_) = newStatus, case .notReachable = networkReachabilityStatus {
            return true
        }
        return false
    }
    
    // MARK: - Private
    // MARK: - Initialize
    private static var mainTaskCenter: TaskCenter?
    
    private init(server: Server, configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        
        if let manager = NetworkReachabilityManager() {
            reachabilityManager = manager
        } else {
            #if DEBUG
            print("TaskCenter Error: Failed to initialize NetworkReachabilityManager")
            #endif
        }
        
        defaultServer = server

        super.init(configuration: configuration)
        
        reachabilityManager?.listener = networkReachabilityChanged(to:)
        reachabilityManager?.startListening()

        NotificationCenter.default.addObserver(forName: Notification.Name.Task.DidCancel, object: nil, queue: nil) { [weak self] (notification) in
            if let task = notification.userInfo?[Notification.Key.Task] as? URLSessionTask {
                self?.printer?.taskCanceled(task)
            }
        }
    }
}

// MARK: - Internal Types
extension TaskCenter {
    
    struct NotificationName {
        /// 网络连接状态广播，只要状态发生变更就会广播
        static let ConnectionStatusChanged = Foundation.Notification.Name("NetworkCenter.Reachability.StatusChanged")
        /// 网络可用状态广播，只有网络可用状态发生改变才会广播
        static let ReachableStatusChanged = Foundation.Notification.Name("NetworkCenter.Reachability.ReachableStatusChanged")
        
        /// 用户认证失败通知
        static let UserAuthenticationFailed = Foundation.Notification.Name("NetworkCenter.Authentication.Failed")
    }
}
