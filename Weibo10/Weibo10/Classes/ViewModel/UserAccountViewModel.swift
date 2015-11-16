//
//  UserAccountViewModel.swift
//  Weibo10
//
//  Created by male on 15/10/17.
//  Copyright © 2015年 itheima. All rights reserved.
//

import Foundation

/// 用户账号视图模型 - 没有父类
/**
    模型通常继承自 NSObject -> 可以使用 KVC 设置属性，简化对象构造
    如果没有父类，所有的内容，都需要从头创建，量级更轻

    视图模型的作用：封装`业务逻辑`，通常没有复杂的属性
*/
class UserAccountViewModel {

    /// 单例 - 解决避免重复从沙盒加载 归档 文件，提高效率，让 access_token 便于被访问到
    static let sharedUserAccount = UserAccountViewModel()
    
    /// 用户模型
    var account: UserAccount?
    
    // MARK: - 计算型属性封装的小的`业务逻辑`
    /// 返回有效的 token
    var accessToken: String? {
        
        // 如果 token 没有过期，返回 account.中的 token 属性
        if !isExpired {
            return account?.access_token
        }
        return nil
    }
    
    /// 用户登录标记
    var userLogon: Bool {
        
        // 1. 如果 token 有值，说明登录成功
        // 2. 如果没有过期，说明登录有效
        return account?.access_token != nil && !isExpired
    }
    
    /// 用户头像 URL
    var avatarUrl: NSURL {
        return NSURL(string: account?.avatar_large ?? "")!
    }
    
    /// 归档保存的路径 - 计算型属性(类似于有返回值的函数，可以让调用的时候，语义会更清晰)
    /// 如果在 OC 中，可以通过只读属性／函数的方式实现
    private var accountPath: String {
        
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        
        return (path as NSString).stringByAppendingPathComponent("account.plist")
    }
    
    /// 判断账户是否过期
    private var isExpired: Bool {
        
        // 判断用户账户过期日期与当前系统日期`进行比较`
        // 自己改写日期，测试逻辑是否正确，创建日期的时候，如果给定 负数，返回比当前时间早的日期
        // account?.expiresDate = NSDate(timeIntervalSinceNow: -3600)
        
        // 如果 account 为 nil，不会调用后面的属性，后面的比较也不会继续...
        if account?.expiresDate?.compare(NSDate()) == NSComparisonResult.OrderedDescending {
            // 代码执行到此，一定进行过比较！
            return false
        }
        
        // 如果过期返回 true
        return true
    }
    
    // MARK: - 构造函数
    /// 构造函数 － 私有化，会要求外部只能通过单例常量访问，而不能 () 实例化
    private init() {
        
        // 从沙盒解档数据，恢复当前数据 - 磁盘读写的速度最慢，不如内存读写效率高！
        account = NSKeyedUnarchiver.unarchiveObjectWithFile(accountPath) as? UserAccount
        
        // 判断token是否过期
        if isExpired {
            print("已经过期")
            
            // 如果过期，清空解档的数据
            account = nil
        }
    }
}

// MARK: - 用户账户相关的网络方法
/*
    代码重构的步骤
    1. 新方法
    2. 粘贴代码
    3. 根据上下文调整参数和返回值
    4. 移动其他`子`方法
*/
extension UserAccountViewModel {
    
    /// 加载 token
    ///
    /// - parameter code:     授权码
    /// - parameter finished: 完成回调(是否成功)
    func loadAccessToken(code: String, finished: (isSuccessed: Bool)->()) {

        NetworkTools.sharedTools.loadAccessToken(code) { (result, error) -> () in
            
            // 1> 判断错误
            if error != nil {
                print("出错了")
                
                // 失败的回调
                finished(isSuccessed: false)
                return
            }
            
            // 2> 输出结果 － 在 Swift 中任何 AnyObject 在使用前，必须转换类型 -> as ?/! 类型
            // 创建账户对象 - 保存在 self.account 属性中
            self.account = UserAccount(dict: result as! [String: AnyObject])
            
            self.loadUserInfo(self.account!, finished: finished)
        }
    }
    
    /// 加载用户信息
    ///
    /// - parameter account: 用户账户对象
    private func loadUserInfo(account: UserAccount, finished: (isSuccessed: Bool)->()) {
        
        NetworkTools.sharedTools.loadUserInfo(account.uid!) { (result, error) -> () in
            
            if error != nil {
                
                print("加载用户出错了")
                
                finished(isSuccessed: false)
                return
            }
            
            // 提示：如果使用 if let / guard let 统统使用 `?`
            // 作了两个判断
            // 1. result 一定有内容
            // 2. 一定是字典
            guard let dict = result as? [String: AnyObject] else {
                print("格式错误")
                
                finished(isSuccessed: false)
                return
            }
            
            // dict 一定是一个有值的字典
            // 将用户信息保存
            account.screen_name = dict["screen_name"] as? String
            account.avatar_large = dict["avatar_large"] as? String
            
            // 保存对象 － 会调用对象的 encodeWithCoder 方法
            NSKeyedArchiver.archiveRootObject(account, toFile: self.accountPath)
            
            print(self.accountPath)
            
            // 需要完成回调!!!
            finished(isSuccessed: true)
        }
    }
}