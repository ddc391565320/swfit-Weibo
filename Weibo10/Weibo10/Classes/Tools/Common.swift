//
//  Common.swift
//  Weibo10
//
//  Created by male on 15/10/15.
//  Copyright © 2015年 itheima. All rights reserved.
//

// 目的：提供全局共享属性或者方法，类似于 pch 文件
import UIKit

// MARK: - 全局通知定义
/// 切换根视图控制器通知 － 一定要够长，要有前缀
let WBSwitchRootViewControllerNotification = "WBSwitchRootViewControllerNotification"

/// 选中照片通知
let WBStatusSelectedPhotoNotification = "WBStatusSelectedPhotoNotification"
/// 选中照片的 KEY - IndexPath
let WBStatusSelectedPhotoIndexPathKey = "WBStatusSelectedPhotoIndexPathKey"
/// 选中照片的 KEY - URL 数组
let WBStatusSelectedPhotoURLsKey = "WBStatusSelectedPhotoURLsKey"

/// 全局外观渲染颜色 -> 延展出`配色`的管理类
let WBAppearanceTintColor = UIColor.orangeColor()

// MARK: - 全局函数，可以直接使用
/// 延迟在主线程执行函数
///
/// - parameter delta:    延迟时间
/// - parameter callFunc: 要执行的闭包
func delay(delta: Double, callFunc: ()->()) {
    
    dispatch_after(
        dispatch_time(DISPATCH_TIME_NOW, Int64(delta * Double(NSEC_PER_SEC))),
        dispatch_get_main_queue()) {
        
        callFunc()
    }
}
