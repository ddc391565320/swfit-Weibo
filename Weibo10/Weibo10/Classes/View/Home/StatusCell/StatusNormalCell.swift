//
//  StatusNormalCell.swift
//  Weibo10
//
//  Created by male on 15/10/21.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 原创微博 Cell
class StatusNormalCell: StatusCell {

    /// 微博视图模型
    override var viewModle: StatusViewModel? {
        didSet {
            pictureView.snp_updateConstraints { (make) -> Void in
                // 根据配图数量，决定配图视图的顶部间距
                let offset = viewModle?.thumbnailUrls?.count > 0 ? StatusCellMargin : 0
                make.top.equalTo(contentLabel.snp_bottom).offset(offset)
            }
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        // 3> 配图视图
        pictureView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(contentLabel.snp_bottom).offset(StatusCellMargin)
            make.left.equalTo(contentLabel.snp_left)
            make.width.equalTo(300)
            make.height.equalTo(90)
        }
    }
}
