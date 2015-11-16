//
//  NetworkTools.swift
//  测试-05-AFN Swift
//
//  Created by male on 15/10/15.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import Alamofire

// MARK: 网络工具
class NetworkTools {

    // MARK: - 应用程序信息
    private let appKey = "3863118655"
    private let appSecret = "b94c088ad2cdae8c3b9641852359d28c"
    private let redirectUrl = "http://www.baidu.com"
    
    /// 网络请求完成回调，类似于 OC 的 typeDefine
    typealias HMRequestCallBack = (result: AnyObject?, error: NSError?)->()
    
    // 单例
    static let sharedTools = NetworkTools()
}

// MARK: - 发布微博
extension NetworkTools {
    
    /// 发布微博
    ///
    /// - parameter status:   微博文本
    /// - parameter image:    微博配图
    /// - parameter finished: 完成回调
    /// - see: [http://open.weibo.com/wiki/2/statuses/update](http://open.weibo.com/wiki/2/statuses/update)
    /// - see: [http://open.weibo.com/wiki/2/statuses/upload](http://open.weibo.com/wiki/2/statuses/upload)
    func sendStatus(status: String, image: UIImage?, finished: HMRequestCallBack) {
        
        // 1. 创建参数字典
        var params = [String: AnyObject]()
        
        // 2. 设置参数
        params["status"] = status
        
        // 3. 判断是否上传图片
        if image == nil {
            let urlString = "https://api.weibo.com/2/statuses/update.json"
            
            tokenRequest(.POST, URLString: urlString, parameters: params, finished: finished)
        } else {
            let urlString = "https://upload.api.weibo.com/2/statuses/upload.json"
            
            let data = UIImagePNGRepresentation(image!)
            
            upload(urlString, data: data!, name: "pic", parameters: params, finished: finished)
        }
    }
}

// MARK: - 微博数据相关方法
extension NetworkTools {
    
    /// 加载微博数据
    ///
    /// - parameter since_id:	若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0。
    /// - parameter max_id:     若指定此参数，则返回ID`小于或等于max_id`的微博，默认为0
    /// - parameter finished:   完成回调
    /// - see: [http://open.weibo.com/wiki/2/statuses/home_timeline](http://open.weibo.com/wiki/2/statuses/home_timeline)
    func loadStatus(since_id since_id: Int, max_id: Int, finished: HMRequestCallBack) {
        
        // 1. 创建参数字典
        var params = [String: AnyObject]()
        
        // 判断是否下拉
        if since_id > 0 {
            params["since_id"] = since_id
        } else if max_id > 0 {  // 上拉参数
            params["max_id"] = max_id - 1
        }

        // 2. 准备网络参数
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        
        // 3. 发起网络请求
        tokenRequest(.GET, URLString: urlString, parameters: params, finished: finished)
    }
}

// MARK: - 用户相关方法
extension NetworkTools {
    
    /// 加载用户信息
    ///
    /// - parameter uid:         uid
    /// - parameter finished:    完成回调
    /// - see: [http://open.weibo.com/wiki/2/users/show](http://open.weibo.com/wiki/2/users/show)
    func loadUserInfo(uid: String, finished: HMRequestCallBack) {
    
        // 1. 创建参数字典
        var params = [String: AnyObject]()
        
        // 2. 处理网络参数
        let urlString = "https://api.weibo.com/2/users/show.json"
        
        params["uid"] = uid
        
        tokenRequest(.GET, URLString: urlString, parameters: params, finished: finished)
    }
}

// MARK: - OAuth 相关方法
extension NetworkTools {
    
    /// OAuth 授权 URL
    /// - see: [http://open.weibo.com/wiki/Oauth2/authorize](http://open.weibo.com/wiki/Oauth2/authorize)
    var oauthURL: NSURL {
        
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(appKey)&redirect_uri=\(redirectUrl)"
        
        return NSURL(string: urlString)!
    }
    
    /// 加载 AccessToken
    func loadAccessToken(code: String, finished: HMRequestCallBack) {
        
        let urlString = "https://api.weibo.com/oauth2/access_token"
        
        let params = ["client_id": appKey,
            "client_secret": appSecret,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectUrl]
        
        request(.POST, URLString: urlString, parameters: params, finished: finished)
        // 测试返回的数据内容 - AFN 默认的响应格式是 JSON，会直接反序列化
        // 如果要确认数据格式的问题
        // 如果是 NSNumber，则没有引号！在做 KVC 指定属性类型非常重要！
//        // 1> 设置相应数据格式是二进制的
//        responseSerializer = AFHTTPResponseSerializer()
//        
//        // 2> 发起网络请求
//        POST(urlString, parameters: params, success: { (_, result) -> Void in
//            
//            // 将二进制数据转换成字符串
//            let json = NSString(data: result as! NSData, encoding: NSUTF8StringEncoding)
//            
//            print(json)
//            
//            // {"access_token":"2.00ml8IrF6dP8NEb33e7215aeRhrcdB",
//            // "remind_in":"157679999",
//            // "expires_in":157679999,
//            // "uid":"5365823342"}
//            
//            }, failure: nil)
    }
}

// MARK: - 封装 Alamofire 网络方法
extension NetworkTools {
    
    /// 向 parameters 字典中追加 token 参数
    ///
    /// - parameter parameters: 参数字典
    ///
    /// - returns: 是否追加成功
    /// - 默认情况下，关于函数参数，在调用时，会做一次 copy，函数内部修改参数值，不会影响到外部的数值
    /// - inout 关键字，相当于在 OC 中传递对象的地址
    private func appendToken(inout parameters: [String: AnyObject]?) -> Bool {

        // 1> 判断 token 是否为nil
        guard let token = UserAccountViewModel.sharedUserAccount.accessToken else {
            return false
        }
        
        // 2> 判断参数字典是否有值
        if parameters == nil {
            parameters = [String: AnyObject]()
        }
        
        // 3> 设置 token
        parameters!["access_token"] = token
        
        return true
    }
    
    /// 使用 token 进行网络请求
    ///
    /// - parameter method:     GET / POST
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter finished:   完成回调
    private func tokenRequest(method: Alamofire.Method, URLString: String, var parameters: [String: AnyObject]?, finished: HMRequestCallBack) {
        
        // 1> 如果追加 token 失败，直接返回
        if !appendToken(&parameters) {
            finished(result: nil, error: NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            
            return
        }
        
        // 2. 发起网络请求
        request(method, URLString: URLString, parameters: parameters, finished: finished)
    }
    
    /// 网络请求
    ///
    /// - parameter method:     GET / POST
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter finished:   完成回调
    private func request(method: Alamofire.Method, URLString: String, parameters: [String: AnyObject]?, finished: HMRequestCallBack) {
        
        // 显示网络指示菊花
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Alamofire.request(method, URLString, parameters: parameters).responseJSON { (response) -> Void in
        
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            // 判断是否失败
            if response.result.isFailure {
                // 在开发网络应用的时候，错误不要提示给用户，但是错误一定要输出！
                QL4Error("网络请求失败 \(response.result.error)")
            }
            // 完成回调
            finished(result: response.result.value, error: response.result.error)
        }
    }
    
    /// 上传文件
    private func upload(URLString: String, data: NSData, name: String, var parameters: [String: AnyObject]?, finished: HMRequestCallBack) {
        
        // 1> 如果追加 token 失败，直接返回
        if !appendToken(&parameters) {
            finished(result: nil, error: NSError(domain: "cn.itcast.error", code: -1001, userInfo: ["message": "token 为空"]))
            
            return
        }
        
        // 2> Alamofire 上传文件
        /**
            appendBody...方法中，如果带 mimeType 是拼接上传文件的方法
            appendBody，如果不带 mimeType 是拼接普通的二进制参数方法！
        */
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Alamofire.upload(.POST, URLString, multipartFormData: { (formData) -> Void in
        
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            // 拼接上传文件的二进制数据
            formData.appendBodyPart(data: data, name: name, fileName: "xxx", mimeType: "application/octet-stream")
            
            // 遍历参数字典，生成对应的参数数据
            if let parameters = parameters {
                for (k, v) in parameters {
                    let str = v as! String
                    let strData = str.dataUsingEncoding(NSUTF8StringEncoding)!
                    
                    // data 是 v 的二进制数据，name 是 k
                    formData.appendBodyPart(data: strData, name: k)
                }
            }
            
            }, encodingMemoryThreshold: 5 * 1024 * 1024) { (encodingResult) -> Void in
        
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) -> Void in
                        
                        // 判断是否失败
                        if response.result.isFailure {
                            // 在开发网络应用的时候，错误不要提示给用户，但是错误一定要输出！
                            print("网络请求失败 \(response.result.error)")
                        }
                        // 完成回调
                        finished(result: response.result.value, error: response.result.error)
                    })
                case .Failure(let error):
                    print("上传文件编码错误 \(error)")
                }
        }
    }
}
