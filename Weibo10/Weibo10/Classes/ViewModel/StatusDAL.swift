//
//  StatusDAL.swift
//  Weibo10
//
//  Created by male on 15/10/30.
//  Copyright © 2015年 itheima. All rights reserved.
//

import Foundation

/// 最大缓存时间
private let maxCacheDateTime: NSTimeInterval = 60 // 7 * 24 * 60 * 60

/// 数据访问层 - 目标：专门负责处理本地 SQLite 和 网络数据
class StatusDAL {
    
    /**
        1. 清理缓存工作，千万不要交给用户使用！
        2. 一定要定期清理数据库的缓存，原因
        - SQLite 的数据库，随着数据的增加，会不断的变大
        - 但是：如果删除了数据，数据库不会变小！SQLite 认为，既然数据库会涨到这么大，留出空间，准备下一次涨到这么大
            - SQLite不会再额外分配磁盘空间
        - 一般不会把 图片/音频/视频 放在数据库中，不便于检索，占用磁盘空间很大！
    */
    /// 清理`早于过期日期`的缓存数据
    class func clearDataCache() {
        
        // 1. 准备日期
        let date = NSDate(timeIntervalSinceNow: -maxCacheDateTime)
        
        // 日期格式转换
        let df = NSDateFormatter()
        // 指定区域 - 在模拟器不需要，但是真机一定需要
        df.locale = NSLocale(localeIdentifier: "en")
        // 指定日期格式
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // 获取日期结果
        let dateStr = df.stringFromDate(date)
        
        // 2. 执行 SQL
        // 提示：开发调试 删除 SQL 的时候，一定先写 `SELECT *`，确认无误之后，再替换成 `DELETE`
        let sql = "DELETE FROM T_Status WHERE createTime < ?;"
        
        SQLiteManager.sharedManager.queue.inDatabase { (db) -> Void in
            if db.executeUpdate(sql, dateStr) {
                print("删除了 \(db.changes()) 条缓存数据")
            }
        }
    }
    
    /// 加载微博数据
    class func loadStatus(since_id: Int, max_id: Int, finished: (array: [[String: AnyObject]]?)->()) {
        
        // 1. 检查本地是否存在缓存数据
        let array = checkChacheData(since_id, max_id: max_id)
        
        // 2. 如果有，返回缓存数据
        if array?.count > 0 {
            print("查询到缓存数据 \(array!.count)")
            
            // 回调返回本地缓存数据
            finished(array: array!)
            
            return
        }
        
        print("加载网络数据")
        // 3. 如果没有，加载网络数据
        NetworkTools.sharedTools.loadStatus(since_id: since_id, max_id: max_id) { (result, error) -> () in
            if error != nil {
                print("出错了")
                
                finished(array: nil)
                return
            }
            
            // 判断 result 的数据结构是否争取
            guard let array = result?["statuses"] as? [[String: AnyObject]] else {
                print("数据格式错误")
                
                finished(array: nil)
                return
            }
            
            // 4. 将网络返回的数据，保存在本地数据库，以便后续使用
            StatusDAL.saveCacheData(array)
            
            // 5. 通过闭包返回网络数据
            finished(array: array)
        }
    }
    
    /// 目标：检查本地数据库中，是否存在需要的数据
    /// 参数：下拉 / 上拉 Id
    private class func checkChacheData(since_id: Int, max_id: Int) -> [[String: AnyObject]]? {
        
        print("检查本地数据 \(since_id) \(max_id)")
        
        // 0. 用户 id
        guard let userId = UserAccountViewModel.sharedUserAccount.account?.uid else {
            print("用户没有登录")
            return nil
        }
        
        // 1. 准备 SQL
        var sql = "SELECT statusId, status, userId FROM T_Status \n"
        sql += "WHERE userId = \(userId) \n"
        
        if since_id > 0 {           // 下拉刷新
            sql += "    AND statusId > \(since_id) \n"
        } else if max_id > 0 {      // 上拉刷新
            sql += "    AND statusId < \(max_id) \n"
        }
        
        sql += "ORDER BY statusId DESC LIMIT 20;"
        
        print("查询数据 SQL -> " + sql)
        
        // 2. 执行 SQL -> 返回结果集合
        let array = SQLiteManager.sharedManager.execRecordSet(sql)

        // 3. 遍历数组 -> dict["status"] JSON 反序列化
        var arrayM = [[String: AnyObject]]()
        for dict in array {
            let jsonData = dict["status"] as! NSData
            // 反序列化 -> 一条完整微博数据字典
            let result = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
            
            // 添加到数组
            arrayM.append(result as! [String : AnyObject])
        }
        
        // 返回结果 － 如果没有查询到数据，会返回一个空的数组
        return arrayM
    }
    
    /// 目标：将网络返回的数据保存至本地数据库
    /// 参数：网络返回的字典数组
    /// 对现有函数不做大的改动，找到合适的`切入点`，尽快测试！
    /**
        数据库开发，难点：SQL 的编写
    
        1> 确认并且测试 SQL
        2> 根据 SQL 的需求，确认参数
        3> 如果 SQL 比较复杂，提前测试 SQL 能够正常执行
        4> 调用 数据库方法 -> 如果是插入数据，应该使用事务！安全/快速
        5> 测试！
    */
    private class func saveCacheData(array: [[String: AnyObject]]) {
        
        // 0. 用户 id
        guard let userId = UserAccountViewModel.sharedUserAccount.account?.uid else {
            print("用户没有登录")
            return
        }
        
        // 1. 准备 SQL
        /**
            1. 微博 id -> 通过字典获取
            2. 微博 json -> 字典序列化
            3. userId -> 登录的用户
        */
        let sql = "INSERT OR REPLACE INTO T_Status (statusId, status, userId) VALUES (?, ?, ?);"
        
        // 2. 遍历数组 - 如果不能确认数据插入的消耗时间，可以在实际开发中，写测试代码
        SQLiteManager.sharedManager.queue.inTransaction { (db, rollback) -> Void in
            
            for dict in array {
                // 1> 微博 id
                let statusId = dict["id"] as! Int
                // 2> 序列化字典 -> 二进制数据
                let json = try! NSJSONSerialization.dataWithJSONObject(dict, options: [])
                
                // 3> 插入数据
                if !db.executeUpdate(sql, statusId, json, userId) {
                    print("插入数据失败")
                    // 回滚
                    rollback.memory = true
                    // break
                    break
                }
            }
        }
        print("数据插入完成！")
    }
}