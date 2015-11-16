//
//  StatusPictureView.swift
//  Weibo10
//
//  Created by male on 15/10/20.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SDWebImage

/// 照片之间的间距
private let StatusPictureViewItemMargin: CGFloat = 8
/// 可重用表示符号
private let StatusPictureCellId = "StatusPictureCellId"

/// 配图视图
class StatusPictureView: UICollectionView {

    /// 微博视图模型
    var viewModle: StatusViewModel? {
        didSet {
            // 自动计算大小
            sizeToFit()
            
            // 刷新数据 － 如果不刷新，后续的 collectionView 一旦被复用，不再调用数据源方法
            reloadData()
        }
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return calcViewSize()
    }
    
    // MARK: - 构造函数
    init() {
        let layout = UICollectionViewFlowLayout()
        
        // 设置间距 － 默认 itemSize 50 * 50
        layout.minimumInteritemSpacing = StatusPictureViewItemMargin
        layout.minimumLineSpacing = StatusPictureViewItemMargin
        
        super.init(frame: CGRectZero, collectionViewLayout: layout)
        
        backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        
        // 设置数据源 - 自己当自己的数据源
        dataSource = self
        // 设置代理
        delegate = self
        
        // 注册可重用 cell
        registerClass(StatusPictureViewCell.self, forCellWithReuseIdentifier: StatusPictureCellId)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDataSource
extension StatusPictureView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    /// 选中照片
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // 测试动画转场协议函数
//        photoBrowserPresentFromRect(indexPath)
//        photoBrowserPresentToRect(indexPath)
        
        // 明确问题：传递什么数据？当前 URL 的数组／当前用户选中的索引
        // 如何传递：通知
        // 通知：名字(通知中心监听)/object：发送通知的同时传递对象(单值)/ userInfo 传递多值的时候，使用的数据字典 -> Key
        let userInfo = [WBStatusSelectedPhotoIndexPathKey: indexPath,
            WBStatusSelectedPhotoURLsKey: viewModle!.thumbnailUrls!]
        
        NSNotificationCenter.defaultCenter().postNotificationName(WBStatusSelectedPhotoNotification,
            object: self,
            userInfo: userInfo)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModle?.thumbnailUrls?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StatusPictureCellId, forIndexPath: indexPath) as! StatusPictureViewCell
        
        cell.imageURL = viewModle!.thumbnailUrls![indexPath.item]
        
        return cell
    }
}

// MARK: - 照片查看器的展现协议
extension StatusPictureView: PhotoBrowserPresentDelegate {
    
    /// 创建一个 imageView 在参与动画
    func imageViewForPresent(indexPath: NSIndexPath) -> UIImageView {
        
        let iv = UIImageView()
        
        // 1. 设置内容填充模式
        iv.contentMode = .ScaleAspectFill
        iv.clipsToBounds = true
        
        // 2. 设置图像（缩略图的缓存）- SDWebImage 如果已经存在本地缓存，不会发起网络请求
        if let url = viewModle?.thumbnailUrls?[indexPath.item] {
            iv.sd_setImageWithURL(url)
        }
        
        return iv
    }
    
    /// 动画起始位置
    func photoBrowserPresentFromRect(indexPath: NSIndexPath) -> CGRect {
        
        // 1. 根据 indexPath 获得当前用户选择的 cell
        let cell = self.cellForItemAtIndexPath(indexPath)!
        
        // 2. 通过 cell 知道 cell 对应在屏幕上的准确位置
        // 在不同视图之间的 `坐标系的转换` self. 是 cell 都父视图
        // 由 collectionView 将 cell 的 frame 位置转换的 keyWindow 对应的 frame 位置
        let rect = self.convertRect(cell.frame, toCoordinateSpace: UIApplication.sharedApplication().keyWindow!)
        
        // 测试转换 rect 的位置
//        let v = UIView(frame: rect)
//        v.backgroundColor = UIColor.redColor()
        // 再次测试
//        let v = imageViewForPresent(indexPath)
//        v.frame = rect
//        
//        UIApplication.sharedApplication().keyWindow?.addSubview(v)
        
        return rect
    }
    
    /// 目标位置
    func photoBrowserPresentToRect(indexPath: NSIndexPath) -> CGRect {
        
        // 根据缩略图的大小，等比例计算目标位置
        guard let key = viewModle?.thumbnailUrls?[indexPath.item].absoluteString else {
            return CGRectZero
        }
        // 从 sdwebImage 获取本地缓存图片
        guard let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(key) else {
            return CGRectZero
        }
        
        // 根据图像大小，计算全屏的大小
        let w = UIScreen.mainScreen().bounds.width
        let h = image.size.height * w / image.size.width
        
        // 对高度进行额外处理
        let screenHeight = UIScreen.mainScreen().bounds.height
        var y: CGFloat = 0
        if h < screenHeight {       // 图片短，垂直居中显示
            y = (screenHeight - h) * 0.5
        }
        
        let rect = CGRect(x: 0, y: y, width: w, height: h)
        
        // 测试位置
//        let v = imageViewForPresent(indexPath)
//        v.frame = rect
//        
//        UIApplication.sharedApplication().keyWindow?.addSubview(v)

        return rect
    }
}

// MARK: - 计算视图大小
extension StatusPictureView {
    
    /// 计算视图大小
    private func calcViewSize() -> CGSize {
        
        // 1. 准备
        // 每行的照片数量
        let rowCount: CGFloat = 3
        // 最大宽度
        let maxWidth = UIScreen.mainScreen().bounds.width - 2 * StatusCellMargin
        let itemWidth = (maxWidth - 2 * StatusPictureViewItemMargin) / rowCount
        
        // 2. 设置 layout 的 itemSize
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)

        // 3. 获取图片数量
        let count = viewModle?.thumbnailUrls?.count ?? 0
        
        // 计算开始
        // 1> 没有图片
        if count == 0 {
            return CGSizeZero
        }
        
        // 2> 一张图片
        if count == 1 {
            var size = CGSize(width: 150, height: 120)
            
            // 利用 SDWebImage 检查本地的缓存图像 - key 就是 url 的完整字符串
            // 问：SDWebImage 是如何设置缓存图片的文件名 完整 URL 字符串 -> `MD5`
            if let key = viewModle?.thumbnailUrls?.first?.absoluteString {
                
                if let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(key) {
                    
                    size = image.size
                }
            }
            
            // 过窄处理 - 针对长图
            size.width = size.width < 40 ? 40 : size.width
            // 过宽的图片
            if size.width > 300 {
                let w: CGFloat = 300
                let h = size.height * w / size.width
                
                size = CGSize(width: w, height: h)
            }
            
            // 内部图片的大小
            layout.itemSize = size
            
            // 配图视图的大小
            return size
        }
        
        // 3> 四张图片 2 * 2 的大小
        if count == 4 {
            let w = 2 * itemWidth + StatusPictureViewItemMargin
            
            return CGSize(width: w, height: w)
        }
        
        // 4> 其他图片 按照九宫格来显示
        // 计算出行数
        /**
            2 3
            5 6
            7 8 9
        */
        let row = CGFloat((count - 1) / Int(rowCount) + 1)
        let h = row * itemWidth + (row - 1) * StatusPictureViewItemMargin + 1
        let w = rowCount * itemWidth + (rowCount - 1) * StatusPictureViewItemMargin + 1
        
        return CGSize(width: w, height: h)
    }
}

// MARK: - 配图 cell
private class StatusPictureViewCell: UICollectionViewCell {
    
    var imageURL: NSURL? {
        didSet {
            iconView.sd_setImageWithURL(imageURL,
                placeholderImage: nil,                      // 在调用 OC 的框架时，可/必选项不严格
                options: [SDWebImageOptions.RetryFailed,    // SD 超时时长 15s，一旦超时会记入黑名单
                    SDWebImageOptions.RefreshCached])       // 如果 URL 不变，图像变
            
            // 根据文件的扩展名判断是否是 gif，但是不是所有的 gif 都会动！
            let ext = ((imageURL?.absoluteString ?? "") as NSString).pathExtension.lowercaseString
            gifIconView.hidden = (ext != "gif")
        }
    }
    
    // MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 1. 添加控件
        contentView.addSubview(iconView)
        iconView.addSubview(gifIconView)
        
        // 2. 设置布局 - 提示因为 cell 会变化，另外，不同的 cell 大小可能不一样
        iconView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(contentView.snp_edges)
        }
        
        gifIconView.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(iconView.snp_right)
            make.bottom.equalTo(iconView.snp_bottom)
        }
    }
    
    // MARK: - 懒加载控件
    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        
        // 设置填充模式
        iv.contentMode = UIViewContentMode.ScaleAspectFill
        // 需要裁切图片
        iv.clipsToBounds = true
        
        return iv
    }()
    /// GIF 提示图片
    private lazy var gifIconView: UIImageView = UIImageView(imageName: "timeline_image_gif")
}

