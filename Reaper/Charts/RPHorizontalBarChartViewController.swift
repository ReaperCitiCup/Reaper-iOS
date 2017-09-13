//
//  RPHorizontalBarChartViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/13.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit

class RPHorizontalBarChartViewController: UIViewController {

    @IBOutlet weak var barView: RPHorizontalBarChartView!

    var dataModel: RPChartViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = dataModel?.title
        self.barView.data = dataModel?.data
        if let fmt = dataModel?.valueFormatter {
            self.barView.xAxis.valueFormatter = fmt
            self.barView.xAxis.labelCount = (dataModel?.data.entryCount)!
        }
        self.barView.xAxis.labelWidth = 100.0
    }

}
