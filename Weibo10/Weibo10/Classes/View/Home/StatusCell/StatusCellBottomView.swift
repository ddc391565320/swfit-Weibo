//
//  StatusCellBottomView.swift
//  Weibo10
//
//  Created by male on 15/10/18.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 底部视图
class StatusCellBottomView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    /// 转发按钮
    private lazy var retweetedButton: UIButton = UIButton(title: " 转发", fontSize: 12, color: UIColor.darkGrayColor(), imageName: "timeline_icon_retweet")
    /// 评论按钮
    private lazy var commentButton: UIButton = UIButton(title: " 评论", fontSize: 12, color: UIColor.darkGrayColor(), imageName: "timeline_icon_comment")
    /// 点赞按钮
    private lazy var likeButton: UIButton = UIButton(title: " 赞", fontSize: 12, color: UIColor.darkGrayColor(), imageName: "timeline_icon_unlike")
}

// MARK: - 设置界面
extension StatusCellBottomView {
    
    private func setupUI() {
        // 0. 设置背景颜色
        backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        // 1. 添加控件
        addSubview(retweetedButton)
        addSubview(commentButton)
        addSubview(likeButton)
        
        // 2. 自动布局
        retweetedButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_top)
            make.left.equalTo(self.snp_left)
            make.bottom.equalTo(self.snp_bottom)
        }
        commentButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(retweetedButton.snp_top)
            make.left.equalTo(retweetedButton.snp_right)
            make.width.equalTo(retweetedButton.snp_width)
            make.height.equalTo(retweetedButton.snp_height)
        }
        likeButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(commentButton.snp_top)
            make.left.equalTo(commentButton.snp_right)
            make.width.equalTo(commentButton.snp_width)
            make.height.equalTo(commentButton.snp_height)
            
            make.right.equalTo(self.snp_right)
        }
        
        // 3. 分隔视图
        let sep1 = sepView()
        let sep2 = sepView()
        addSubview(sep1)
        addSubview(sep2)
        
        // 布局
        let w = 0.5
        let scale = 0.4
        
        sep1.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(retweetedButton.snp_right)
            make.centerY.equalTo(retweetedButton.snp_centerY)
            make.width.equalTo(w)
            make.height.equalTo(retweetedButton.snp_height).multipliedBy(scale)
        }
        sep2.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(commentButton.snp_right)
            make.centerY.equalTo(retweetedButton.snp_centerY)
            make.width.equalTo(w)
            make.height.equalTo(retweetedButton.snp_height).multipliedBy(scale)
        }
        
    }
    
    /// 创建分隔视图
    /// 此处如果使用计算型属性 － 会让代码的阅读产生困难
//    private var sepView: UIView {
//        let v = UIView()
//        
//        v.backgroundColor = UIColor.darkGrayColor()
//        
//        return v
//    }
    private func sepView() -> UIView {
        let v = UIView()
        
        v.backgroundColor = UIColor.darkGrayColor()
        
        return v
    }
}
