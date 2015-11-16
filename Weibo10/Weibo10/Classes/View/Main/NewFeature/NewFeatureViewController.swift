//
//  NewFeatureViewController.swift
//  Weibo10
//
//  Created by male on 15/10/17.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SnapKit

/// 可重用 CellId
private let WBNewFeatureViewCellId = "WBNewFeatureViewCellId"
/// 新特性图像的数量
private let WBNewFeatureImageCount = 4

class NewFeatureViewController: UICollectionViewController {

    // 懒加载属性，必须要在控制器实例化之后才会被创建
    // private lazy var layout = UICollectionViewFlowLayout()
    
    // MARK: - 构造函数
    init() {
        // super.指定的构造函数
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = UIScreen.mainScreen().bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        
        // 构造函数，完成之后内部属性才会被创建
        super.init(collectionViewLayout: layout)
        
        collectionView?.pagingEnabled = true
        collectionView?.bounces = false
        collectionView?.showsHorizontalScrollIndicator = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // iOS 7.0 开始，就推荐要隐藏状态栏，可以每个控制器分别设置，默认是 NO
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 注册可重用Cell
        self.collectionView!.registerClass(NewFeatureCell.self, forCellWithReuseIdentifier: WBNewFeatureViewCellId)
    }

    // MARK: UICollectionViewDataSource
    // 每个分组中，格子的数量
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return WBNewFeatureImageCount
    }

    // Cell
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(WBNewFeatureViewCellId, forIndexPath: indexPath) as! NewFeatureCell
    
        cell.imageIndex = indexPath.item
    
        return cell
    }
    
    // ScrollView 停止滚动方法
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // 再最后一页才调用动画方法
        // 根据 contentOffset 计算页数
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        // 判断是否是最后一页
        if page != WBNewFeatureImageCount - 1 {
            return
        }
        
        // Cell 播放动画
        let cell = collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: page, inSection: 0)) as! NewFeatureCell
        
        // 显示动画
        cell.showButtonAnim()
    }
}

// MARK: - 新特性 Cell
private class NewFeatureCell: UICollectionViewCell {
 
    /// 图像属性
    private var imageIndex: Int = 0 {
        didSet {
            iconView.image = UIImage(named: "new_feature_\(imageIndex + 1)")
            
            // 隐藏按钮
            startButton.hidden = true
        }
    }
    
    /// 点击开始体验按钮
    @objc private func clickStartButton() {
        print("开始体验")
        
        NSNotificationCenter.defaultCenter().postNotificationName(WBSwitchRootViewControllerNotification, object: nil)
    }
    
    /// 显示按钮动画
    private func showButtonAnim() {
        startButton.hidden = false
        startButton.transform = CGAffineTransformMakeScale(0, 0)
        startButton.userInteractionEnabled = false
        
        UIView.animateWithDuration(1.6,     // 动画时长
            delay: 0,                       // 延时时间
            usingSpringWithDamping: 0.6,    // 弹力系数，0~1，越小越弹
            initialSpringVelocity: 10,      // 初始速度，模拟重力加速度
            options: [],                    // 动画选项
            animations: { () -> Void in
                
                self.startButton.transform = CGAffineTransformIdentity
                
            }) { (_) -> Void in
                self.startButton.userInteractionEnabled = true
        }
        
    }
    
    // frame 的大小是 layout.itemSize 指定的
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        print("创建 cell")
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 1. 添加控件
        addSubview(iconView)
        addSubview(startButton)

        // 不能单纯在此设置隐藏
        startButton.hidden = true
        
        // 2. 指定位置
        iconView.frame = bounds
        
        startButton.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.snp_centerX)
            make.bottom.equalTo(self.snp_bottom).multipliedBy(0.7)
        }
        
        // 3. 监听方法
        startButton.addTarget(self, action: "clickStartButton", forControlEvents: .TouchUpInside)
    }
    
    // MARK: - 懒加载控件
    /// 图像
    private lazy var iconView: UIImageView = UIImageView()
    /// 开始体验按钮
    private lazy var startButton: UIButton = UIButton(title: "开始体验", color: UIColor.whiteColor(), backImageName: "new_feature_finish_button")
}

