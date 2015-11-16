//
//  OAuthViewController.swift
//  Weibo10
//
//  Created by male on 15/10/15.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SVProgressHUD

/// 用户登录控制器
class OAuthViewController: UIViewController {

    private lazy var webView = UIWebView()
    
    // MARK: - 监听方法
    @objc private func close() {
        SVProgressHUD.dismiss()

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// 自动填充用户名和密码 － web 注入（以代码的方式向web页面添加内容）
    @objc private func autoFill() {
        
        let js = "document.getElementById('userId').value = 'daoge10000@sina.cn';" +
            "document.getElementById('passwd').value = 'qqq123';"
        
        // 让 webView 执行 js 
        webView.stringByEvaluatingJavaScriptFromString(js)
    }
    
    // MARK: - 设置界面
    override func loadView() {
        view = webView
        
        // 设置代理
        webView.delegate = self
        
        // 设置导航栏
        title = "登录新浪微博"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "close")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", style: .Plain, target: self, action: "autoFill")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 加载页面
        self.webView.loadRequest(NSURLRequest(URL: NetworkTools.sharedTools.oauthURL))
    }
}

// MARK: - UIWebViewDelegate
extension OAuthViewController: UIWebViewDelegate {
    
    /// 将要加载请求的代理方法
    ///
    /// - parameter webView:        webView
    /// - parameter request:        将要加载的请求
    /// - parameter navigationType: navigationType，页面跳转的方式
    ///
    /// - returns: 返回 false 不加载，返回 true 继续加载
    /// 如果 iOS 的代理方法中有返回 bool，通常返回 true 很正常，返回 false 不能正常工作
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // 目标：如果是百度，就不加载
        // 1. 判断访问的主机是否是 www.baidu.com
        guard let url = request.URL where url.host == "www.baidu.com" else {
            return true
        }
        
        // 2. 从百度地址的 url 中提取 `code=` 是否存在
        guard let query = url.query where query.hasPrefix("code=") else {
            print("取消授权")
            close()
            return false
        }
        
        // 3. 从 query 字符串中提取 `code=` 后面的授权码
        let code = query.substringFromIndex("code=".endIndex)
        
        print(query)
        print("授权码是 " + code)
        
        // 4. 加载 accessToken
        UserAccountViewModel.sharedUserAccount.loadAccessToken(code) { (isSuccessed) -> () in
            
            // finished 的完整代码
            if !isSuccessed {
                SVProgressHUD.showInfoWithStatus("您的网络不给力")
                
                delay(0.5) { self.close() }
                
                return
            }
            
            print("成功了")
            // dismissViewControllerAnimated 方法不会立即将控制器销毁
            self.dismissViewControllerAnimated(false) {
                
                // 停止指示器
                SVProgressHUD.dismiss()
                
                // 通知中心是同步的 - 一旦发送通知，会先执行监听方法，直接结束后，才执行后续代码
                NSNotificationCenter.defaultCenter().postNotificationName(WBSwitchRootViewControllerNotification, object: "welcome")
            }
        }
        
        return false
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
}

