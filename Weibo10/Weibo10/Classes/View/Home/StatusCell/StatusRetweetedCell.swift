//
//  StatusRetweetedCell.swift
//  Weibo10
//
//  Created by male on 15/10/21.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import FFLabel

/// 转发微博的 Cell
class StatusRetweetedCell: StatusCell {

    /// 微博视图模型
    /// 如果继承父类的属性
    /// 1. 需要 override
    /// 2. 不需要 super
    /// 3. 先执行父类的 didSet，再执行子类的 didSet -> 只关心 子类相关设置就够了！
    override var viewModle: StatusViewModel? {
        didSet {
            // 转发微博的文字
            let text = viewModle?.retweetedText ?? ""
            retweetedLabel.attributedText = EmoticonManager.sharedManager.emoticonText(text, font: retweetedLabel.font)
            
            pictureView.snp_updateConstraints { (make) -> Void in
                
                // 根据配图数量，决定配图视图的顶部间距
                let offset = viewModle?.thumbnailUrls?.count > 0 ? StatusCellMargin : 0
                make.top.equalTo(retweetedLabel.snp_bottom).offset(offset)
            }
        }
    }
    
    // MARK: - 懒加载控件
    /// 背景按钮
    private lazy var backButton: UIButton = {
       
        let button = UIButton()
        
        button.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        return button
    }()
    /// 转发标签
    private lazy var retweetedLabel: FFLabel = FFLabel(
        title: "转发微博",
        fontSize: 14,
        color: UIColor.darkGrayColor(),
        screenInset: StatusCellMargin)
}

// MARK: - 设置界面
extension StatusRetweetedCell {
    
    override func setupUI() {
        super.setupUI()
        
        // 1. 添加控件
        contentView.insertSubview(backButton, belowSubview: pictureView)
        contentView.insertSubview(retweetedLabel, aboveSubview: backButton)
        
        // 2. 自动布局
        // 1> 背景按钮
        backButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(contentLabel.snp_bottom).offset(StatusCellMargin)
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.bottom.equalTo(bottomView.snp_top)
        }
        
        // 2> 转发标签
        retweetedLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(backButton.snp_top).offset(StatusCellMargin)
            make.left.equalTo(backButton.snp_left).offset(StatusCellMargin)
        }
        // 3> 配图视图
        pictureView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(retweetedLabel.snp_bottom).offset(StatusCellMargin)
            make.left.equalTo(retweetedLabel.snp_left)
            make.width.equalTo(300)
            make.height.equalTo(90)
        }
        
        // 3. 设置代理
        retweetedLabel.labelDelegate = self
    }
}
