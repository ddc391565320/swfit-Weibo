//
//  User.swift
//  Weibo10
//
//  Created by male on 15/10/18.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

/// 用户模型
class User: NSObject {

    /// 用户UID
    var id: Int = 0
    /// 用户昵称
    var screen_name: String?
    /// 用户头像地址（中图），50×50像素
    var profile_image_url: String?
    /// 认证类型，-1：没有认证，0，认证用户，2,3,5: 企业认证，220: 达人
    var verified_type: Int = 0
    /// 会员等级 0-6
    var mbrank: Int = 0
    
    init(dict: [String: AnyObject]) {
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}

    override var description: String {
        let keys = ["id", "screen_name", "profile_image_url", "verified_type", "mbrank"]
        
        return dictionaryWithValuesForKeys(keys).description
    }
}
