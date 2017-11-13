//
//  RPFundDateFormatter.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/4.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Charts

class RPFundDateFormatter: NSObject, IAxisValueFormatter {
    
    var labels: [String] = []
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if labels.count == 0 {
            return ""
        }
        return labels[Int(value * Double(labels.count)) % labels.count]
    }
    
    init(labels: [String]) {
        super.init()
        self.labels = labels
    }
    
}
