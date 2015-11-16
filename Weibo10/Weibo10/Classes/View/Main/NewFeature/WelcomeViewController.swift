//
//  WelcomeViewController.swift
//  Weibo10
//
//  Created by male on 15/10/18.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SDWebImage

class WelcomeViewController: UIViewController {

    // 设置界面，视图的层次结构
    override func loadView() {
        // 直接使用背景图像作为根视图，不用关心图像的缩放问题
        view = backImageView
        
        setupUI()
    }
    
    // 视图加载完成之后的后续处理，通常用来设置数据
    override func viewDidLoad() {
        super.viewDidLoad()

        // 异步加载用户头像
        iconView.sd_setImageWithURL(UserAccountViewModel.sharedUserAccount.avatarUrl,
            placeholderImage: UIImage(named: "avatar_default_big"))
    }
    
    // 视图已经显示，通常可以动画／键盘处理
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // 1. 更改约束 -> 改变位置
        // snp_updateConstraints 更新已经设置过的约束
        // multiplier 属性是只读属性，创建之后，不允许修改
        /**
            使用自动布局开发，有一个原则：
            - 所有`使用约束`设置位置的控件，不要再设置 `frame`
        
            * 原因：自动布局系统会根据设置的约束，自动计算控件的 frame
            * 在 layoutSubviews 函数中设置 frame
            * 如果程序员主动修改 frame，会引起 自动布局系统计算错误！
        
            - 工作原理：当有一个运行循环启动，自动布局系统，会`收集`所有的约束变化
            - 在运行循环结束前，调用 layoutSubviews 函数`统一`设置 frame
            - 如果希望某些约束提前更新！使用 `layoutIfNeeded` 函数让自动布局系统，提前更新当前收集到的约束变化
        */
        iconView.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(view.snp_bottom).offset(-view.bounds.height + 200)
        }
        
        // 2. 动画
        welcomeLabel.alpha = 0
        UIView.animateWithDuration(1.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: { () -> Void in
            
            // 修改所有`可动画`属性 - 自动布局的动画
            self.view.layoutIfNeeded()
            
            }) { (_) -> Void in
                
                UIView.animateWithDuration(0.8, animations: { () -> Void in
                    self.welcomeLabel.alpha = 1
                    }, completion: { (_) -> Void in
                        
                        print("OK")
                        // 不推荐的写法
                        // UIApplication.sharedApplication().keyWindow?.rootViewController = MainViewController()
                        // 发送通知
                        NSNotificationCenter.defaultCenter().postNotificationName(WBSwitchRootViewControllerNotification, object: nil)
                })
        }
    }

    // MARK: - 懒加载控件
    /// 背景图像
    private lazy var backImageView: UIImageView = UIImageView(imageName: "ad_background")
    /// 头像
    private lazy var iconView: UIImageView = {
        
        let iv = UIImageView(imageName: "avatar_default_big")
        
        // 设置圆角
        iv.layer.cornerRadius = 45
        iv.layer.masksToBounds = true
        
        return iv
    }()
    /// 欢迎标签
    private lazy var welcomeLabel: UILabel = UILabel(title: "欢迎归来", fontSize: 18)
}

// MARK: - 设置界面
extension WelcomeViewController {
    
    private func setupUI() {
        
        // 1. 添加控件
        view.addSubview(iconView)
        view.addSubview(welcomeLabel)
        
        // 2. 自动布局
        iconView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.bottom.equalTo(view.snp_bottom).offset(-200)
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        
        welcomeLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(iconView.snp_centerX)
            make.top.equalTo(iconView.snp_bottom).offset(16)
        }
    }
}
