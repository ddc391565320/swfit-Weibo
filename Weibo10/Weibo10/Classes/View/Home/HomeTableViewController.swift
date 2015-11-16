//
//  HomeTableViewController.swift
//  Weibo10
//
//  Created by male on 15/10/14.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit
import SVProgressHUD

/// 原创微博的可重用 ID
let StatusCellNormalId = "StatusCellNormalId"
/// 转发微博的可重用 ID
let StatusCellRetweetedId = "StatusCellRetweetedId"

class HomeTableViewController: VisitorTableViewController {

    /// 微博数据列表模型
    private lazy var listViewModel = StatusListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !UserAccountViewModel.sharedUserAccount.userLogon {
            
            visitorView?.setupInfo(nil, title: "关注一些人，回这里看看有什么惊喜")
            return
        }
        
        prepareTableView()
        
        loadData()
        
        // 注册通知 － 如果使用 通知中心的 block 监听，其中的 self 一定要 弱引用！
        NSNotificationCenter.defaultCenter().addObserverForName(WBStatusSelectedPhotoNotification,
            object: nil,
            queue: nil) { [weak self] (n) -> Void in
                
                guard let indexPath = n.userInfo?[WBStatusSelectedPhotoIndexPathKey] as? NSIndexPath else {
                    return
                }
                guard let urls = n.userInfo?[WBStatusSelectedPhotoURLsKey] as? [NSURL] else {
                    return
                }
                // 判断 cell 是否遵守了展现动画协议！
                guard let cell = n.object as? PhotoBrowserPresentDelegate else {
                    return
                }
                print("选择 照片 cell \(cell)")
                
                let vc = PhotoBrowserViewController(urls: urls, indexPath: indexPath)
                
                // 1. 设置modal的类型是自定义类型 Transition(转场)
                vc.modalPresentationStyle = UIModalPresentationStyle.Custom
                // 2. 设置动画代理
                vc.transitioningDelegate = self?.photoBrowserAnimator
                // 3. 设置 animator 的代理参数
                self?.photoBrowserAnimator.setDelegateParams(cell, indexPath: indexPath, dismissDelegate: vc)
                // 参数设置所有权交给调用方，一旦调用方失误漏传参数，可能造成不必要的麻烦
                // 会一系列的 ...
//                self?.photoBrowserAnimator.presentDelegate = cell
//                self?.photoBrowserAnimator.indexPath = indexPath
//                self?.photoBrowserAnimator.dismissDelegate = vc
                
                // 3. Modal 展现
                self?.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    deinit {
        // 注销通知
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /// 准备表格
    private func prepareTableView() {
        // 注册可重用 cell
        tableView.registerClass(StatusNormalCell.self, forCellReuseIdentifier: StatusCellNormalId)
        tableView.registerClass(StatusRetweetedCell.self, forCellReuseIdentifier: StatusCellRetweetedId)
        
        // 取消分割线
        tableView.separatorStyle = .None
        
        // 预估行高 - 需要尽量准确
        tableView.estimatedRowHeight = 400
        
        // 下拉刷新控件默认没有 - 高度 60
        refreshControl = WBRefreshControl()
        // 添加监听方法
        refreshControl?.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        
        // 上拉刷新视图
        tableView.tableFooterView = pullupView
    }
    
    /// 加载数据
    @objc private func loadData() {
        
        refreshControl?.beginRefreshing()
        listViewModel.loadStatus(isPullup: pullupView.isAnimating()) { (isSuccessed) -> () in
            
            // 关闭刷新控件
            self.refreshControl?.endRefreshing()
            // 关闭上拉刷新
            self.pullupView.stopAnimating()
            
            if !isSuccessed {
                SVProgressHUD.showInfoWithStatus("加载数据错误，请稍后再试")
                return
            }
            
            // 显示下拉刷新提示
            self.showPulldownTip()
            
            // 刷新数据
            self.tableView.reloadData()
        }
    }
    
    /// 显示下拉刷新
    private func showPulldownTip() {
        // 如果不是下拉刷新直接返回
        guard let count = listViewModel.pulldownCount else {
            return
        }
        
        QL1Debug("下拉刷新 \(count)")
        pulldownTipLabel.text = (count == 0) ? "没有新微博" : "刷新到 \(count) 条微博"
        
        let height: CGFloat = 44
        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: height)
        pulldownTipLabel.frame = CGRectOffset(rect, 0, -2 * height)
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.pulldownTipLabel.frame = CGRectOffset(rect, 0, height)
            }) { (_) -> Void in
                UIView.animateWithDuration(1.0) {
                    self.pulldownTipLabel.frame = CGRectOffset(rect, 0, -2 * height)
                }
        }
    }
    
    // MARK: - 懒加载控件
    /// 下拉刷新提示标签
    private lazy var pulldownTipLabel: UILabel = {

        let label = UILabel(title: "", fontSize: 18, color: UIColor.whiteColor())
        label.backgroundColor = UIColor.orangeColor()
        
        // 添加到 navigationBar
        self.navigationController?.navigationBar.insertSubview(label, atIndex: 0)
        
        return label
    }()
    /// 上拉刷新提示视图
    private lazy var pullupView: UIActivityIndicatorView = {
       
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        indicator.color = UIColor.lightGrayColor()
        
        return indicator
    }()
    /// 照片查看转场动画代理
    private lazy var photoBrowserAnimator: PhotoBrowserAnimator = PhotoBrowserAnimator()
}

// MARK: - 数据源方法
extension HomeTableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listViewModel.statusList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 1. 获取视图模型
        let vm = listViewModel.statusList[indexPath.row]
        
        // 2. 获取可重用 cell 会调用行高方法！
        let cell = tableView.dequeueReusableCellWithIdentifier(vm.cellId, forIndexPath: indexPath) as! StatusCell
        
        // 3. 设置视图模型
        cell.viewModle = vm
        
        // 4. 判断是否是最后一条微博
        if indexPath.row == listViewModel.statusList.count - 1 && !pullupView.isAnimating() {
            // 开始动画
            pullupView.startAnimating()
            
            // 上拉刷新数据
            loadData()
            
            print("上拉刷新数据")
        }
        
        // 5. 设置 cell 的代理
        cell.cellDelegate = self
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return listViewModel.statusList[indexPath.row].rowHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        QL2Info("选中行 \(indexPath)")
    }
}

// MARK: - StatusCellDelegate
extension HomeTableViewController: StatusCellDelegate {
    
    func statusCellDidClickUrl(url: NSURL) {

        // 建立 webView 控制器
        let vc = HomeWebViewController(url: url)
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
}