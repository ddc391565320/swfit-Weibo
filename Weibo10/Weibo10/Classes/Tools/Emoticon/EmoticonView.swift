//
//  EmoticonView.swift
//  01-表情键盘
//
//  Created by male on 15/10/23.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 可重用 Cell Id
private let EmoticonViewCellId = "EmoticonViewCellId"

// MARK: 表情键盘视图
class EmoticonView: UIView {
    
    /// 选中表情回调
    private var selectedEmoticonCallBack: (emoticon: Emoticon)->()
    
    // MARK: - 监听方法
    @objc private func clickItem(item: UIBarButtonItem) {
        print("选中分类 \(item.tag)")
        
        let indexPath = NSIndexPath(forItem: 0, inSection: item.tag)
        
        // 滚动 collectionView 
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: true)
    }
    
    // MARK: - 构造函数
    init(selectedEmoticon: (emoticon: Emoticon)->()) {
        // 记录闭包属性
        selectedEmoticonCallBack = selectedEmoticon
        
        // 调用父类的构造函数
        var rect = UIScreen.mainScreen().bounds
        rect.size.height = 226
        
        super.init(frame: rect)
        
        backgroundColor = UIColor.whiteColor()
        
        setupUI()
        
        // 滚动到第一页
        let indexPath = NSIndexPath(forItem: 0, inSection: 1)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Left, animated: false)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 懒加载控件
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: EmoticonLayout())
    private lazy var toolbar = UIToolbar()
    
    /// 表情包数组
    private lazy var packages = EmoticonManager.sharedManager.packages
    
    // MARK: - 表情布局(类中类－只允许被包含的类使用)
    private class EmoticonLayout: UICollectionViewFlowLayout {
        
        // collectionView 第一次布局的时候被自动调用
        // collectionView 的尺寸已经设置好 216 toolbar 36，如果在 iPhone 6+ 屏幕宽度是 414
        // 如果 toolbar 设置为 44，同样只能显示两行
        private override func prepareLayout() {
            super.prepareLayout()
            
            let col: CGFloat = 7
            let row: CGFloat = 3
            
            let w = collectionView!.bounds.width / col
            // 如果在 iPhone 4 的屏幕，只能显示两行
            let margin = (collectionView!.bounds.height - row * w) * 0.499
            
            itemSize = CGSize(width: w, height: w)
            minimumInteritemSpacing = 0
            minimumLineSpacing = 0
            sectionInset = UIEdgeInsets(top: margin, left: 0, bottom: margin, right: 0)
            
            scrollDirection = .Horizontal
            
            collectionView?.pagingEnabled = true
            collectionView?.bounces = false
            collectionView?.showsHorizontalScrollIndicator = false
        }
    }
}

// MARK: - 设置界面
// private 修饰的 extension 内部的所有函数都是私有的
private extension EmoticonView {
    
    /// 设置界面
    func setupUI() {
        // 1. 添加控件
        addSubview(toolbar)
        addSubview(collectionView)
        
        // 2. 自动布局
        toolbar.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.snp_bottom)
            make.left.equalTo(self.snp_left)
            make.right.equalTo(self.snp_right)
            make.height.equalTo(44)
        }
        collectionView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_top)
            make.bottom.equalTo(toolbar.snp_top)
            make.left.equalTo(self.snp_left)
            make.right.equalTo(self.snp_right)
        }
        
        // 3. 准备控件
        prepareToolbar()
        prepareCollectionView()
    }
    
    /// 准备工具栏
    private func prepareToolbar() {
        // 0. tintColor
        toolbar.tintColor = UIColor.darkGrayColor()
        
        // 1. 设置按钮内容
        var items = [UIBarButtonItem]()
        
        // toolbar 中，通常是一组功能相近的操作，只是操作的类型不同，通常利用 tag 来区分
        var index = 0
        for p in packages {
            
            items.append(UIBarButtonItem(title: p.group_name_cn, style: .Plain, target: self, action: "clickItem:"))
            items.last?.tag = index++
            
            // 添加弹簧
            items.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        
        // 2. 设置 items
        toolbar.items = items
    }
    
    /// 准备 collectionView
    private func prepareCollectionView() {
        collectionView.backgroundColor = UIColor.whiteColor()
        
        // 注册 cell
        collectionView.registerClass(EmoticonViewCell.self, forCellWithReuseIdentifier: EmoticonViewCellId)
        
        // 设置数据源
        collectionView.dataSource = self
        // 设置代理
        collectionView.delegate = self
    }
}

// MARK: - UICollectionViewDataSource
extension EmoticonView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // 获取表情模型
        let em = packages[indexPath.section].emoticons[indexPath.item]
        
        // 执行`回调`
        selectedEmoticonCallBack(emoticon: em)
        
        // 添加最近表情
        // 第0个分组不参加排序
        if indexPath.section > 0 {
            EmoticonManager.sharedManager.addFavorite(em)
        }
    }
    
    /// 返回分组数量 － 表情包的数量
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    /// 返回每个表情包中的表情数量
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return packages[section].emoticons.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(EmoticonViewCellId, forIndexPath: indexPath) as! EmoticonViewCell
        
        cell.emoticon = packages[indexPath.section].emoticons[indexPath.item]
        
        return cell
    }
}

// MARK: - 表情视图 Cell
private class EmoticonViewCell: UICollectionViewCell {
    
    /// 表情模型
    var emoticon: Emoticon? {
        didSet {
            emoticonButton.setImage(UIImage(contentsOfFile: emoticon!.imagePath), forState: UIControlState.Normal)
            emoticonButton.setTitle(emoticon?.emoji, forState: UIControlState.Normal)
            
            // 设置删除按钮
            if emoticon!.isRemoved {
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete"), forState: UIControlState.Normal)
            }
            
            // 设置 emoji，千万不要加上判断，否则显示会不正常
            if emoticon?.emoji != nil {
            }
        }
    }
    
    // MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emoticonButton)
        
        emoticonButton.backgroundColor = UIColor.whiteColor()
        emoticonButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        emoticonButton.frame = CGRectInset(bounds, 4, 4)
        
        // 字体的大小和高度相近
        emoticonButton.titleLabel?.font = UIFont.systemFontOfSize(32)
        
        emoticonButton.userInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    private lazy var emoticonButton: UIButton = UIButton()
}

