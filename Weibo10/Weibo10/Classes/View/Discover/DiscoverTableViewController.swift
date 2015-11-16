//
//  DiscoverTableViewController.swift
//  Weibo10
//
//  Created by male on 15/10/14.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

class DiscoverTableViewController: VisitorTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        visitorView?.setupInfo("visitordiscover_image_message", title: "登录后，最新、最热微博尽在掌握，不再会与实事潮流擦肩而过")
    }
}