//
//  UIViewController +Extension.swift
//  DDY_Swift
//
//  Created by zhouwu on 2017/1/23.
//  Copyright © 2017年 Lvmama. All rights reserved.
//

import UIKit
import Foundation

public extension UIViewController {
    class func initFromNib() -> UIViewController {
        let hasNib: Bool = Bundle.main.path(forResource: self.nameOfClass, ofType: "nib") != nil
        guard hasNib else {
            assert(!hasNib, "Invalid parameter") // here
            return UIViewController()
        }
        return self.init(nibName: self.nameOfClass, bundle: nil)
    }
}
