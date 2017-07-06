//
//  NSObject+Extension.swift
//  DDY_Swift
//
//  Created by zhouwu on 2017/1/22.
//  Copyright © 2017年 Lvmama. All rights reserved.
//

import UIKit

extension NSObject {
    class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last! as String
    }
    
    //用于获取 cell 的 reuse identifier
    class var cellIdentifier: String {
        return String(format: "%@Identifier", self.nameOfClass)
    }
}
