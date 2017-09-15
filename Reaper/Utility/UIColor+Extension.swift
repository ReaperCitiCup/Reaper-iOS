//
//  UIColor+Extension.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/3.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

extension UIColor {
    
    @nonobjc class var rpColor: UIColor {
        return UIColor(red: 80.0 / 255.0, green: 170.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
    }
    
    class func reaperColors () -> [UIColor] {
        return [
            UIColor("#F48984"), UIColor("#F48984"), UIColor("#FDB8A1"), UIColor("#F7CC9B"),
            UIColor("#F8D76E"), UIColor("#FEE9A5"), UIColor("#F0E0BC"), UIColor("#D1CCC6"),
            UIColor("#B6D7B3"), UIColor("#BEE1DA"), UIColor("#A7DAD8"), UIColor("#92BCC3"),
            UIColor("#93A9BD"), UIColor("#B9CDDC"), UIColor("#BABBDE"), UIColor("#928BA9"),
            UIColor("#CA9ECE"), UIColor("#EFCEED"), UIColor("#FECEDC"), UIColor("#FAA5B3")
        ]
    }
    
}
