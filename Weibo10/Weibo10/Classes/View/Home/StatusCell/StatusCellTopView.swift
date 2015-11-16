//
//  StatusCellTopView.swift
//  Weibo10
//
//  Created by male on 15/10/18.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 顶部视图
class StatusCellTopView: UIView {

    /// 微博视图模型
    var viewModle: StatusViewModel? {
        didSet {
            // 姓名
            nameLabel.text = viewModle?.status.user?.screen_name
            
            // 头像
            iconView.sd_setImageWithURL(viewModle?.userProfileUrl,
                placeholderImage: viewModle?.userDefaultIconView)
            // 会员图标
            memberIconView.image = viewModle?.userMemberImage
            // 认证图标
            vipIconView.image = viewModle?.userVipImage
            // 时间
            timeLabel.text = viewModle?.createAt
            // 来源
            sourceLabel.text = viewModle?.status.source
        }
    }
    
    // MAKR: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    /// 头像
    private lazy var iconView: UIImageView = UIImageView(imageName: "avatar_default_big")
    /// 姓名
    private lazy var nameLabel: UILabel = UILabel(title: "王老五", fontSize: 14)
    /// 会员图标
    private lazy var memberIconView: UIImageView = UIImageView(imageName: "common_icon_membership_level1")
    /// 认证图标
    private lazy var vipIconView: UIImageView = UIImageView(imageName: "avatar_vip")
    /// 时间标签
    private lazy var timeLabel: UILabel = UILabel(title: "现在", fontSize: 11, color: UIColor.orangeColor())
    /// 来源标签
    private lazy var sourceLabel: UILabel = UILabel(title: "来源", fontSize: 11)
}

// MARK: - 设置界面
extension StatusCellTopView {
    
    private func setupUI() {
        backgroundColor = UIColor.whiteColor()

        // 0. 添加分隔视图
        let sepView = UIView()
        sepView.backgroundColor = UIColor.lightGrayColor()
        addSubview(sepView)
        
        // 1. 添加控件
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(memberIconView)
        addSubview(vipIconView)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        
        // 2. 自动布局
        sepView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_top)
            make.left.equalTo(self.snp_left)
            make.right.equalTo(self.snp_right)
            make.height.equalTo(StatusCellMargin)
        }
        iconView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(sepView.snp_bottom).offset(StatusCellMargin)
            make.left.equalTo(self.snp_left).offset(StatusCellMargin)
            make.width.equalTo(StatusCellIconWidth)
            make.height.equalTo(StatusCellIconWidth)
        }
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(iconView.snp_top)
            make.left.equalTo(iconView.snp_right).offset(StatusCellMargin)
        }
        memberIconView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(nameLabel.snp_top)
            make.left.equalTo(nameLabel.snp_right).offset(StatusCellMargin)
        }
        vipIconView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(iconView.snp_right)
            make.centerY.equalTo(iconView.snp_bottom)
        }
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(iconView.snp_bottom)
            make.left.equalTo(iconView.snp_right).offset(StatusCellMargin)
        }
        sourceLabel.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(timeLabel.snp_bottom)
            make.left.equalTo(timeLabel.snp_right).offset(StatusCellMargin)
        }
    }
}
