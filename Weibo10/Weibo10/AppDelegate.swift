//
//  AppDelegate.swift
//  Weibo10
//
//  Created by male on 15/10/14.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
 
        // 设置输出
        QorumLogs.enabled = true
        // 程序发布的时候，希望只显示错误信息
        // info以上的级别，最好都添加文字说明，这样方便查找
        // QorumLogs.minimumLogLevelShown = 4
        // 测试的时候，可以限定输出文件
        // QorumLogs.onlyShowThisFile(HomeTableViewController)
        
        // 测试归档的用户账号
        QLShortLine()
        QL2Info("用户登录账号 \(UserAccountViewModel.sharedUserAccount.account)")
        QLShortLine()
        
        setupAppearance()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        
        window?.rootViewController = defaultRootViewController
        
        window?.makeKeyAndVisible()
        
        // 监听通知
        NSNotificationCenter.defaultCenter().addObserverForName(
            WBSwitchRootViewControllerNotification, // 通知名称，通知中心用来识别通知的
            object: nil,                            // 发送通知的对象，如果为nil，监听任何对象
            queue: nil)                             // nil，主线程
            { [weak self] (notification) -> Void in // weak self，
                
                print(NSThread.currentThread())
                print(notification)
                
                let vc = notification.object != nil ? WelcomeViewController() : MainViewController()
                
                // 切换控制器
                self?.window?.rootViewController = vc
        }
        
        return true
    }
    
    //// 应用程序进入到后台
    func applicationDidEnterBackground(application: UIApplication) {
        // 清除数据库缓存
        StatusDAL.clearDataCache()
    }
    
    deinit {
        // 注销通知 - 注销指定的通知
        NSNotificationCenter.defaultCenter().removeObserver(self,   // 监听者
            name: WBSwitchRootViewControllerNotification,           // 监听的通知
            object: nil)                                            // 发送通知的对象
    }
    
    /// 设置全局外观 - 在很多应用程序中，都会在 AppDelegate 中设置所有需要控件的全局外观
    private func setupAppearance() {
        // 修改导航栏的全局外观 － 要在控件创建之前设置，一经设置全局有效
        UINavigationBar.appearance().tintColor = WBAppearanceTintColor
        UITabBar.appearance().tintColor = WBAppearanceTintColor
    }
}

// MARK: - 界面切换代码
extension AppDelegate {
    
    /// 启动的根视图控制器
    private var defaultRootViewController: UIViewController {
        
        // 1. 判断是否登录
        if UserAccountViewModel.sharedUserAccount.userLogon {
            return isNewVersion ? NewFeatureViewController() : WelcomeViewController()
        }
        
        // 2. 没有登录返回主控制器
        return MainViewController()
    }
    
    /// 判断是否新版本
    private var isNewVersion: Bool {
        
        // 1. 当前的版本 - info.plist
        // print(NSBundle.mainBundle().infoDictionary)
        let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let version = Double(currentVersion)!
        
        // 2. `之前`的版本，把当前版本保存在用户偏好 - 如果 key 不存在，返回 0
        let sandboxVersionKey = "sandboxVersionKey"
        let sandboxVersion = NSUserDefaults.standardUserDefaults().doubleForKey(sandboxVersionKey)
        QL2Info("当前版本 \(version) - 之前版本 \(sandboxVersion)")

        // 3. 保存当前版本
        NSUserDefaults.standardUserDefaults().setDouble(version, forKey: sandboxVersionKey)
        
        return version > sandboxVersion
    }
}
