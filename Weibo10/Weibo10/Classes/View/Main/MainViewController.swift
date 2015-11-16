//
//  MainViewController.swift
//  Weibo10
//
//  Created by male on 15/10/14.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    // MARK: - 监听方法
    /// 点击撰写按钮
    /// 如果`单纯`使用 `private` 运行循环将无法正确发送消息，导致崩溃
    /// 如果使用 @objc 修饰符号，可以保证运行循环能够发送此消息，即使函数被标记为 private
    @objc private func clickComposedButton() {
        
        // 判断用户是否登录
        var vc: UIViewController
        if UserAccountViewModel.sharedUserAccount.userLogon {
            vc = ComposeViewController()
        } else {
            vc = OAuthViewController()
        }
        
        let nav = UINavigationController(rootViewController: vc)
        
        presentViewController(nav, animated: true, completion: nil)
    }
    
    // MARK: - 视图生命周期函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加控制器，并不会创建 tabBar 中的按钮！
        // 懒加载是无处不在的，所有控件都是延迟创建的！
        addChildViewControllers()
        
        print(tabBar.subviews)
        
        setupComposedButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        // 会创建 tabBar 中的所有控制器对应的按钮！
        super.viewWillAppear(animated)
        
        // 将撰写按钮弄到最前面
        tabBar.bringSubviewToFront(composedButton)
    }
    
    // MARK: - 懒加载控件
    private lazy var composedButton: UIButton = UIButton(
        imageName: "tabbar_compose_icon_add",
        backImageName: "tabbar_compose_button")
}

// MARK: - 设置界面
// extension 类似于 OC 的分类，分类中不能定义`存储性`属性！Swift 中同样如此！
extension MainViewController {
    
    /// 设置撰写按钮
    private func setupComposedButton() {
        // 1. 添加按钮
        tabBar.addSubview(composedButton)
        
        // 2. 调整按钮
        let count = childViewControllers.count
        // 让按钮宽一点点，能够解决手指触摸的容错问题
        let w = tabBar.bounds.width / CGFloat(count) - 1
        
        composedButton.frame = CGRectInset(tabBar.bounds, 2 * w, 0)
        
        // 3. 添加监听方法
        composedButton.addTarget(self, action: "clickComposedButton", forControlEvents: .TouchUpInside)
    }
    
    /// 添加所有的控制器
    private func addChildViewControllers() {
        
        addChildViewController(HomeTableViewController(), title: "首页", imageName: "tabbar_home")
        addChildViewController(MessageTableViewController(), title: "消息", imageName: "tabbar_message_center")
        
        addChildViewController(UIViewController())
        
        addChildViewController(DiscoverTableViewController(), title: "发现", imageName: "tabbar_discover")
        addChildViewController(ProfileTableViewController(), title: "我", imageName: "tabbar_profile")
    }
    
    /// 添加控制器
    ///
    /// - parameter vc:        vc
    /// - parameter title:     标题
    /// - parameter imageName: 图像名称
    private func addChildViewController(vc: UIViewController, title: String, imageName: String) {
        
        // 设置标题 － 由内至外设置的
        vc.title = title
        
        // 设置图像
        vc.tabBarItem.image = UIImage(named: imageName)
        
        // 导航控制器
        let nav = UINavigationController(rootViewController: vc)
        
        addChildViewController(nav)
    }
}
