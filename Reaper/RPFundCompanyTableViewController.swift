//
//  RPFundCompanyTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/7.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class RPFundCompanyTableViewController: UITableViewController {
    
    var companyModel: RPCompanyShortModel?
    var nameLabel: UILabel?
    
    @IBOutlet weak var fundPerformanceScatterChart: ScatterChartView!
    @IBOutlet weak var managerPerformanceScatterChart: ScatterChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = .rpColor
        
        fundPerformanceScatterChart.chartDescription?.text = ""
        managerPerformanceScatterChart.chartDescription?.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "基金公司"
        self.nameLabel?.text = self.companyModel?.name
        self.updateCharts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func updateCharts() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation {
            Alamofire.request("\(BASE_URL)/company/\(self.companyModel!.code)/fund-performance").responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json).arrayValue
                    
                    print(result)
                    
                    var fundPerformanceEntry = [ChartDataEntry]()
                    for dict in result {
                        fundPerformanceEntry.append(ChartDataEntry(x: dict["rate"].doubleValue,
                                                                   y: dict["risk"].doubleValue))
                    }
                    let fundPerformanceDataSet = ScatterChartDataSet(values: fundPerformanceEntry)
                    let data = ScatterChartData(dataSet: fundPerformanceDataSet)
                    self.fundPerformanceScatterChart.data = data
                }
            }
        }
        queue.addOperation {
            Alamofire.request("\(BASE_URL)/company/\(self.companyModel!.code)/manager-performance").responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json).arrayValue
                    
                    print(result)
                    
                    var managerPerformanceEntry = [ChartDataEntry]()
                    for dict in result {
                        managerPerformanceEntry.append(ChartDataEntry(x: dict["rate"].doubleValue,
                                                                   y: dict["risk"].doubleValue))
                    }
                    let managerPerformanceDataSet = ScatterChartDataSet(values: managerPerformanceEntry)
                    let data = ScatterChartData(dataSet: managerPerformanceDataSet)
                    self.managerPerformanceScatterChart.data = data
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SCREEN_WIDTH - 20
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60))
        let label = UILabel(frame: CGRect(x: 13, y: 6, width: SCREEN_WIDTH - 19, height: 48))
        label.font = UIFont(name: "PingFangSC-Semibold", size: 28.0)
        label.text = ""
        label.textColor = .white
        self.nameLabel = label
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }

}
