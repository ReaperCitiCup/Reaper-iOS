//
//  RPLineChartViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/12.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Charts

class RPLineChartViewController: UIViewController {

    @IBOutlet weak var lineChartView: LineChartView!

    var dataModel: RPChartViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.lineChartView.chartDescription?.text = ""
        self.lineChartView.xAxis.labelPosition = .bottom
        self.lineChartView.xAxis.drawGridLinesEnabled = false
        self.lineChartView.rightAxis.drawAxisLineEnabled = false
        self.lineChartView.rightAxis.drawLabelsEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = dataModel?.title
        self.lineChartView.data = dataModel?.data
        if let fmt = dataModel?.valueFormatter {
            self.lineChartView.xAxis.valueFormatter = fmt
        }
    }

}
