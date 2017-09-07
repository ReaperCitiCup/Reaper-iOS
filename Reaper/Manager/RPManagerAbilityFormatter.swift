//
//  RPManagerAbilityFormatter.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/7.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Charts

class RPManagerAbilityFormatter: NSObject, IAxisValueFormatter {
    
    var labels = ["经验值", "择时能力", "收益率", "稳定性", "抗风险"]
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return labels[Int(value) % self.labels.count]
    }
    
}
