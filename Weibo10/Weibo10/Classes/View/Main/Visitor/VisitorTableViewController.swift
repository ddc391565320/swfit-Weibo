//
//  VisitorTableViewController.swift
//  Weibo10
//
//  Created by male on 15/10/14.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

class VisitorTableViewController: UITableViewController {

    /// 用户登录标记
    private var userLogon = UserAccountViewModel.sharedUserAccount.userLogon
    
    /**
        提问
        1. 应用程序中有几个 visitorView? - 每个控制器各自有各自不同的 访客视图！
        2. 访客视图如果用懒加载会怎样？- 如果使用懒加载，访客视图始终都会被创建出来！
    */
    /// 访客视图
    var visitorView: VisitorView?
    
    override func loadView() {
        
        // 根据用户登录情况，决定显示的根视图
        userLogon ? super.loadView() : setupVisitorView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        QL2Info("访客视图 - \(visitorView)")
    }
    
    /// 设置访客视图 - 让每一个`小`函数
    private func setupVisitorView() {
        // 替换根视图
        visitorView = VisitorView()
        
        view = visitorView
        
        // 添加监听方法
        visitorView?.registerButton.addTarget(self, action: "visitorViewDidRegister", forControlEvents: UIControlEvents.TouchUpInside)
        visitorView?.loginButton.addTarget(self, action: "visitorViewDidLogin", forControlEvents: UIControlEvents.TouchUpInside)
                
        // 设置导航栏按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .Plain, target: self, action: "visitorViewDidRegister")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: .Plain, target: self, action: "visitorViewDidLogin")
    }
}

// MARK: - 访客视图监听方法
extension VisitorTableViewController {
    
    func visitorViewDidRegister() {
        print("注册")
    }
    
    func visitorViewDidLogin() {
        let vc = OAuthViewController()
        let nav = UINavigationController(rootViewController: vc)
        
        presentViewController(nav, animated: true, completion: nil)
    }
}
