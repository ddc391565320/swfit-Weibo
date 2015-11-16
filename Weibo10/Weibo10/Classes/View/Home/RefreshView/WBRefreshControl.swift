//
//  WBRefreshControl.swift
//  Weibo10
//
//  Created by male on 15/10/21.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 下拉刷新控件偏移量
private let WBRefreshControlOffset: CGFloat = -60

/// 自定义刷新控件 - 负责处理刷新逻辑
class WBRefreshControl: UIRefreshControl {

    // MARK: - 重写系统方法
    override func endRefreshing() {
        super.endRefreshing()
        
        // 停止动画
        refreshView.stopAnimation()
    }
    
    /// 主动触发开始刷新动画 － 不会触发监听方法
    override func beginRefreshing() {
        super.beginRefreshing()
        
        refreshView.startAnimation()
    }
    
    
    // MARK: - KVO 监听方法
    /**
        1. 始终待在屏幕上
        2. 下拉的时候，frame 的 y 一直变小，相反（向上推）一直变大
        3. 默认的 y 是 0
    */
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if frame.origin.y > 0 {
            return
        }
        
        // 判断是否正在刷新
        if refreshing {
            refreshView.startAnimation()
            return
        }
        
        if frame.origin.y < WBRefreshControlOffset && !refreshView.rotateFlag {
            print("反过来")
            refreshView.rotateFlag = true
        } else if frame.origin.y >= WBRefreshControlOffset && refreshView.rotateFlag {
            print("转过去")
            refreshView.rotateFlag = false
        }
    }
    
    // MARK: - 构造函数
    override init() {
        super.init()
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    private func setupUI() {
        // 隐藏转轮
        tintColor = UIColor.clearColor()
        
        // 添加控件
        addSubview(refreshView)
        
        // 自动布局 - 从 `XIB 加载的控件`需要指定大小约束
        refreshView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.snp_center)
            make.size.equalTo(refreshView.bounds.size)
        }
        
        // 使用 KVO 监听位置变化 - 主队列，当主线程有任务，就不调度队列中的任务执行
        // 让当前运行循环中所有代码执行完毕后，运行循环结束前，开始监听
        // 方法触发会在下一次运行循环开始！
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.addObserver(self, forKeyPath: "frame", options: [], context: nil)
        }
    }
    
    deinit {
        // 删除 KVO 监听方法
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    // MARK: - 懒加载控件
    private lazy var refreshView = WBRefreshView.refreshView()
}

/// 刷新视图 - 负责处理`动画显示`
class WBRefreshView: UIView {
    
    /// 旋转标记
    var rotateFlag = false {
        didSet {
            rotateTipIcon()
        }
    }
    
    @IBOutlet weak var loadingIconView: UIImageView!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipIconView: UIImageView!
    
    /// 从 XIB 加载 视图
    class func refreshView() -> WBRefreshView {
    
        // 推荐使用 UINib 的方法是加载 XIB
        let nib = UINib(nibName: "WBRefreshView", bundle: nil)
    
        return nib.instantiateWithOwner(nil, options: nil)[0] as! WBRefreshView
    }
    
    /// 旋转图标动画
    private func rotateTipIcon() {
        
        var angle = CGFloat(M_PI)
        angle += rotateFlag ? -0.0000001 : 0.0000001
        
        // 旋转动画，特点：顺时针优先 + `就近原则`
        UIView.animateWithDuration(0.5) { () -> Void in
            
            self.tipIconView.transform = CGAffineTransformRotate(self.tipIconView.transform, CGFloat(angle))
        }
    }
    
    /// 播放加载动画
    private func startAnimation() {
        
        tipView.hidden = true
        
        // 判断动画是否已经被添加
        let key = "transform.rotation"
        if loadingIconView.layer.animationForKey(key) != nil {
            return
        }
        
        print("加载动画播放")
        
        let anim = CABasicAnimation(keyPath: key)
        
        anim.toValue = 2 * M_PI
        anim.repeatCount = MAXFLOAT
        anim.duration = 0.5
        anim.removedOnCompletion = false
        
        loadingIconView.layer.addAnimation(anim, forKey: key)
    }
    
    /// 停止加载动画
    private func stopAnimation() {
        tipView.hidden = false
        
        loadingIconView.layer.removeAllAnimations()
    }
}
