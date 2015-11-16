//
//  SQLiteManager.swift
//  01-FMDB演练
//
//  Created by male on 15/10/30.
//  Copyright © 2015年 itheima. All rights reserved.
//

import Foundation

/// 数据库名称 - 关于数据名称 readme.txt
private let dbName = "readme.db"

class SQLiteManager {
    
    /// 单例
    static let sharedManager = SQLiteManager()
    
    /// 全局数据库操作队列
    let queue: FMDatabaseQueue
    
    private init() {
        
        // 0. 数据库路径 - 全路径(可读可写)
        var path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        path = (path as NSString).stringByAppendingPathComponent(dbName)
        
        print("数据库路径 " + path)
        
        // 1. 打开数据库队列
        // 如果数据库不存在，会建立数据库，然后，再创建队列并且打开数据库
        // 如果数据库存在，会直接创建队列并且打开数据库
        queue = FMDatabaseQueue(path: path)
        
        createTable()
    }
    
    /// 执行 SQL 返回字典数组
    ///
    /// - parameter sql: SQL
    ///
    /// - returns: 字典数组
    func execRecordSet(sql: String) -> [[String: AnyObject]] {

        // 定义结果[字典数组]
        var result = [[String: AnyObject]]()
        
        // `同步`执行数据库查询 - FMDB 默认情况下，都是在主线程上执行的
        SQLiteManager.sharedManager.queue.inDatabase { (db) -> Void in
            
            print(NSThread.currentThread())
            
            guard let rs = db.executeQuery(sql) else {
                print("没有结果")
                
                return
            }
            
            while rs.next() {
                // 1. 列数
                let colCount = rs.columnCount()
                
                // 创建字典
                var dict = [String: AnyObject]()
                
                // 2. 遍历每一列
                for col in 0..<colCount {
                    // 1> 列名
                    let name = rs.columnNameForIndex(col)
                    // 2> 值
                    let obj = rs.objectForColumnIndex(col)
                    
                    // 3> 设置字典
                    dict[name] = obj
                }
                // 将字典插入数组
                result.append(dict)
            }
        }
        
        // 返回结果
        return result
    }
    
    private func createTable() {
        
        // 1. 准备 SQL(只读，创建应用程序时，准备的素材)
        let path = NSBundle.mainBundle().pathForResource("db.sql", ofType: nil)!
        let sql = try! String(contentsOfFile: path)
        
        // 2. 执行 SQL
        queue.inDatabase { (db) -> Void in
            
            // 创建数据表的时候，最好选择 executeStatements，可以执行多个 SQL 
            // 保证能够一次性创建所有的数据表！
            if db.executeStatements(sql) {
                print("创表成功")
            } else {
                print("创表失败")
            }
        }
    }
}