//
//  RPManagerFundRankFormatter.swift
//  
//
//  Created by 宋 奎熹 on 2017/9/8.
//

import UIKit
import Charts

class RPManagerFundRankFormatter: NSObject, IAxisValueFormatter {
    
    var labels = ["1月", "3月", "6月", "1年", "2年", "3年"]
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return labels[Int(value) - 1]
    }
    
}
