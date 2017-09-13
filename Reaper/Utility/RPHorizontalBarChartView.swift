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
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawLabelsEnabled = false
//        dragEnabled = false
        doubleTapToZoomEnabled = false
//        pinchZoomEnabled = false
        xAxis.drawGridLinesEnabled = false
    }

}
