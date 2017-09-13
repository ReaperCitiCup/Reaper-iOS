//
//  RPCompanyAttributionFormatter.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/13.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Charts

class RPCompanyAttributionFormatter: NSObject, IAxisValueFormatter {

    var labels: [String] = []

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return labels[Int(value)]
    }

    init(labels: [String]) {
        super.init()
        self.labels = labels
    }

}
