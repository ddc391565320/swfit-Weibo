//
//  ProfileTableViewController.swift
//  Weibo10
//
//  Created by male on 15/10/14.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

class ProfileTableViewController: VisitorTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        visitorView?.setupInfo("visitordiscover_image_profile", title: "登录后，你的微博、相册、个人资料会显示在这里，展示给别人")
    }
}