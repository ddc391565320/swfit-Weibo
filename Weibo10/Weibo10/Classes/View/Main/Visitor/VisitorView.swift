//
//  VisitorView.swift
//  Weibo10
//
//  Created by male on 15/10/14.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SnapKit

/// 访客视图 － 处理用户未登录的界面显示
class VisitorView: UIView {
    
    // MARK: - 设置视图信息
    /// 设置视图信息
    ///
    /// - parameter imageName: 图片名称，首页设置为 nil
    /// - parameter title:     消息文字
    func setupInfo(imageName: String?, title: String) {
        
        messageLabel.text = title
        
        // 如果图片名称为 nil，说明是首页，直接返回
        guard let imgName = imageName else {
            // 播放动画
            startAnim()
            
            return
        }
        
        iconView.image = UIImage(named: imgName)
        // 隐藏小房子
        homeIconView.hidden = true
        // 将遮罩图像移动到底层
        sendSubviewToBack(maskIconView)
    }
    
    /// 开启首页转轮动画
    private func startAnim() {
        
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        anim.toValue = 2 * M_PI
        anim.repeatCount = MAXFLOAT
        anim.duration = 20
        
        // 用在不断重复的动画上，当动画绑定的图层对应的视图被销毁，动画会自动被销毁
        anim.removedOnCompletion = false
        
        // 添加到图层
        iconView.layer.addAnimation(anim, forKey: nil)
    }
    
    // MARK: - 构造函数
    // initWithFrame 是 UIView 的指定构造函数
    // 使用纯代码开发使用的
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    // initWithCoder - 使用 SB & XIB 开发加载的函数
    // 使用 sb 开始的入口
    required init?(coder aDecoder: NSCoder) {
        // 导致如果使用 SB 开发，调用这个视图，会直接崩溃
        // fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    // MARK: - 懒加载控件
    /// 图标，使用 image: 构造函数创建的 imageView 默认就是 image 的大小
    private lazy var iconView: UIImageView = UIImageView(imageName: "visitordiscover_feed_image_smallicon")
    
    /// 遮罩图像
    private lazy var maskIconView: UIImageView = UIImageView(imageName: "visitordiscover_feed_mask_smallicon")
    
    /// 小房子
    private lazy var homeIconView: UIImageView = UIImageView(imageName: "visitordiscover_feed_image_house")
    
    /// 消息文字
    private lazy var messageLabel: UILabel = UILabel(title: "关注一些人，回这里看看有什么惊喜关注一些人，回这里看看有什么惊喜")
    /// 注册按钮
    lazy var registerButton: UIButton = UIButton(title: "注册", color: UIColor.orangeColor(), backImageName: "common_button_white_disable")
    /// 登录按钮
    lazy var loginButton: UIButton = UIButton(title: "登录", color: UIColor.darkGrayColor(), backImageName: "common_button_white_disable")
}

// MARK: - 设置界面
extension VisitorView {
    
    /// 设置界面
    private func setupUI() {
        // 1. 添加控件
        addSubview(iconView)
        addSubview(maskIconView)
        addSubview(homeIconView)
        addSubview(messageLabel)
        addSubview(registerButton)
        addSubview(loginButton)
        
        // 2. 设置自动布局 
        // 1> 图标
        // make 理解为要添加的约束对象
        iconView.snp_makeConstraints { (make) -> Void in
            // 指定 centerX 属性 等于 `参照对象`.`snp_`参照属性值
            // offset 就是指定相对视图约束的偏移量
            make.centerX.equalTo(self.snp_centerX)
            make.centerY.equalTo(self.snp_centerY).offset(-60)
        }
        // 2> 小房子
        homeIconView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(iconView.snp_center)
        }
        // 3> 消息文字
        messageLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(iconView.snp_centerX)
            make.top.equalTo(iconView.snp_bottom).offset(16)
            make.width.equalTo(224)
            make.height.equalTo(36)
        }
        // 4> 注册按钮
        registerButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(messageLabel.snp_left)
            make.top.equalTo(messageLabel.snp_bottom).offset(16)
            make.width.equalTo(100)
            make.height.equalTo(36)
        }
        // 5> 登录按钮
        loginButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(messageLabel.snp_right)
            make.top.equalTo(registerButton.snp_top)
            make.width.equalTo(registerButton.snp_width)
            make.height.equalTo(registerButton.snp_height)
        }
        // 6. 遮罩图像
        maskIconView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_top)
            make.left.equalTo(self.snp_left)
            make.right.equalTo(self.snp_right)
            make.bottom.equalTo(registerButton.snp_bottom)
        }
        // 设置背景颜色 - 灰度图 R = G = B，在 UI 元素中，大多数都使用灰度图，或者纯色图(安全色)
        backgroundColor = UIColor(white: 237.0 / 255.0, alpha: 1.0)
    }
}
