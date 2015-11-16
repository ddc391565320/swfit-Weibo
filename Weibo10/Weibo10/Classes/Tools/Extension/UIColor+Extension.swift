//
//  UIColor+Extension.swift
//  Weibo10
//
//  Created by male on 15/10/26.
//  Copyright © 2015年 itheima. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func randomColor() -> UIColor {
        
        // 0~255
        let r = CGFloat(random() % 256) / 255.0
        let g = CGFloat(random() % 256) / 255.0
        let b = CGFloat(random() % 256) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
