//
//  StatusCell.swift
//  Weibo10
//
//  Created by male on 15/10/18.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import FFLabel

/// 微博 Cell 中控件的间距数值
let StatusCellMargin: CGFloat = 12
/// 微博头像的宽度
let StatusCellIconWidth: CGFloat = 35

/// 微博 Cell 代理
protocol StatusCellDelegate: NSObjectProtocol {
    /// 微博 cell 点击 URL
    func statusCellDidClickUrl(url: NSURL)
}

/// 微博 Cell
class StatusCell: UITableViewCell {

    /// cell 的代理
    weak var cellDelegate: StatusCellDelegate?
    
    /// 微博视图模型
    var viewModle: StatusViewModel? {
        didSet {
            topView.viewModle = viewModle
            
            let text = viewModle?.status.text ?? ""
            contentLabel.attributedText = EmoticonManager.sharedManager.emoticonText(text, font: contentLabel.font)
            
            // 设置配图视图 － 设置视图模型之后，配图视图有能力计算大小
            pictureView.viewModle = viewModle
            
            pictureView.snp_updateConstraints { (make) -> Void in
                make.height.equalTo(pictureView.bounds.height)
                // 直接设置宽度数值
                make.width.equalTo(pictureView.bounds.width)                
            }
        }
    }
    
    /// 根据指定的视图模型计算行高
    ///
    /// - parameter vm: 视图模型
    ///
    /// - returns: 返回视图模型对应的行高
    func rowHeight(vm: StatusViewModel) -> CGFloat {
        // 1. 记录视图模型 -> 会调用上面的 didSet 设置内容以及更新`约束`
        viewModle = vm
        
        // 2. 强制更新所有约束 -> 所有控件的frame都会被计算正确
        contentView.layoutIfNeeded()
        
        // 3. 返回底部视图的最大高度
        return CGRectGetMaxY(bottomView.frame)
    }
    
    // MARK: - 构造函数
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        
        selectionStyle = .None
    }

     required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
    
    // MARK: - 懒加载控件
    /// 顶部视图
    private lazy var topView: StatusCellTopView = StatusCellTopView()
    /// 微博正文标签
    lazy var contentLabel: FFLabel = FFLabel(title: "微博正文",
        fontSize: 15,
        color: UIColor.darkGrayColor(),
        screenInset: StatusCellMargin)
    /// 配图视图
    lazy var pictureView: StatusPictureView = StatusPictureView()
    /// 底部视图
    lazy var bottomView: StatusCellBottomView = StatusCellBottomView()
}

// MARK: - 设置界面
extension StatusCell {
    
    func setupUI() {
        // 1. 添加控件
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(pictureView)
        contentView.addSubview(bottomView)
        
        // 2. 自动布局
        // 1> 顶部视图
        topView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp_top)
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.height.equalTo(2 * StatusCellMargin + StatusCellIconWidth)
        }
        // 2> 内容标签
        contentLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(topView.snp_bottom).offset(StatusCellMargin)
            make.left.equalTo(contentView.snp_left).offset(StatusCellMargin)
            
        }
        // 4> 底部视图
        bottomView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(pictureView.snp_bottom).offset(StatusCellMargin)
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.height.equalTo(44)
        }
        
        // 3. 设置代理
        contentLabel.labelDelegate = self
    }
}

// MARK: - FFLabelDelegate
extension StatusCell: FFLabelDelegate {
    
    func labelDidSelectedLinkText(label: FFLabel, text: String) {
        QL2Info(text)
        
        // 判断 text 是否是 url
        if text.hasPrefix("http://") {
            
            guard let url = NSURL(string: text) else {
                return
            }
            
            cellDelegate?.statusCellDidClickUrl(url)
        }
        
    }
}
