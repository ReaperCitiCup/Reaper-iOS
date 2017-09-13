//
//  RPHorizontalBarChartView.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/13.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Charts

class RPHorizontalBarChartView: HorizontalBarChartView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupProperties()
    }

    private func setupProperties() {
        chartDescription?.text = ""
        legend.enabled = false
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.wordWrapEnabled = true
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawLabelsEnabled = false
        doubleTapToZoomEnabled = false
        xAxis.avoidFirstLastClippingEnabled = true
        xAxis.labelWidth = 50.0
    }

}
