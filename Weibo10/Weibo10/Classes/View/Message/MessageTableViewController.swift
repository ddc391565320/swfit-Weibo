//
//  MessageTableViewController.swift
//  Weibo10
//
//  Created by male on 15/10/14.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

class MessageTableViewController: VisitorTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        visitorView?.setupInfo("visitordiscover_image_message", title: "登录后，别人评论你的微博，发给你的消息，都会在这里收到通知")
    }
}