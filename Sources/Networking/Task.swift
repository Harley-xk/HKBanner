//
//  Task.swift
//  Comet-Networking
//
//  Created by Harley.xk on 2018/11/12.
//  Copyright © 2018年 Harley-xk. All rights reserved.
//

import UIKit
import Comet
import Alamofire

public typealias TaskMethod = Alamofire.HTTPMethod
public typealias TaskParamEncoding = Alamofire.ParameterEncoding

public protocol Taskable {
    
    // MARK: - Request
    
    /// 请求的目标服务器, 如果为空则使用 TaskCenter 的默认服务器
    var targetServer: Server? { get }
    
    /// 请求方法，GET、POST等
    var method: TaskMethod { get }
    
    /// api 接口地址
    var api: String { get }
    
    /// 请求头部域的自定义数据
    /// 注意：Alamofire 会根据情况自动添加一些通用字段
    var additionalHeaders: [String : String] { get }
    
    /// 接口参数
    var parameters: [String : Any] { get }
    
    /// 请求参数编码方式，默认为 url-encoding
    var paramEncoding: TaskParamEncoding { get }
    
    /// 请求是否需要身份验证
    var authenticationNeeded: Bool { get }

    // MARK: - Response
    
    /// 请求返回值的类型
    associatedtype Model: Codable
    
    /// json 解析器
    var decoder: JSONDecoder { get }
    
    /// 解析数据
    func decodeData(from response: DataResponse<Data>) -> Response<Model>
    
    /// 从 json 解析数据模型
    func decodeModel(from json: Data) throws -> Response<Model>
}


extension Taskable {
    
    /// 解析数据的默认实现
    public func decodeData(from dataResponse: DataResponse<Data>) -> Response<Model> {
        
        let status = dataResponse.response?.statusCode ?? -1
        
        if case let .failure(error) = dataResponse.result {
            return Response(error: error as NSError)
        } else if !(200 ..< 300).contains(status) {
            return Response(error: NSError(httpCode: status))
        } else if let jsonData = dataResponse.data {
            do {
                return try decodeModel(from: jsonData)
            } catch {
                return Response(error: error as NSError)
            }
        } else {
            return Response(error: NSError(errorMessage: "没有返回数据"))
        }
    }
    
    /// 从 json 解析数据模型, 默认将整个返回的 body 作为模型来解析, 重写该方法以实现自定义的解析方案
    public func decodeModel(from json: Data) throws -> Response<Model> {
        let entity = try decoder.decode(Model.self, from: json)
        return Response(data: entity)
    }
}


/// Taskable 协议的默认实现，可以直接使用该类发送请求
public struct Task<T: Codable>: Taskable {
    
    public typealias Model = T
    
    public var targetServer: Server?
    
    public var method: TaskMethod
    
    public var api: String
    
    public var additionalHeaders: [String : String]
    
    public var parameters: [String : Any]
    
    public var decoder = TaskCenter.main.defaultDecoder
    
    public var paramEncoding: TaskParamEncoding
    
    public var authenticationNeeded = true
    
    /// 初始化
    init(method: TaskMethod = .get, api: String, additionalHeaders: [String : String] = [:], params: [String : Any] = [:], paramEncoding: TaskParamEncoding = URLEncoding()) {
        self.method = method
        self.api = api
        self.additionalHeaders = additionalHeaders
        self.parameters = params
        self.paramEncoding = paramEncoding
    }
    
    mutating public func basicAuthenticateWith(username: String, passowrd: String) {
        let credential = "\(username):\(passowrd)".base64Encode ?? ""
        additionalHeaders["Authorization"] = "Basic \(credential)"
        authenticationNeeded = false
    }
    
    public func paginated(_ param: PageParam) -> Task {
        var task = self
        task.parameters["page"] = param.page
        task.parameters["size"] = param.size
        return task
    }
}

