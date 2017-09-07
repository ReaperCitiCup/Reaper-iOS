//
//  RPCompanyTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/7.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class RPCompanyTableViewController: UITableViewController {
    
    var companyModel: RPCompanyShortModel?
    var nameLabel: UILabel?
    
    @IBOutlet weak var fundPerformanceScatterChart: ScatterChartView!
    @IBOutlet weak var managerPerformanceScatterChart: ScatterChartView!
    @IBOutlet weak var productStrategyPieChart: PieChartView!
    @IBOutlet weak var assetAllocationPieChart: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = .rpColor
        
        fundPerformanceScatterChart.chartDescription?.text = ""
        managerPerformanceScatterChart.chartDescription?.text = ""
        productStrategyPieChart.chartDescription?.text = ""
        assetAllocationPieChart.chartDescription?.text = ""
        
        fundPerformanceScatterChart.rightAxis.drawLabelsEnabled = false
        managerPerformanceScatterChart.rightAxis.drawLabelsEnabled = false
        
        fundPerformanceScatterChart.xAxis.labelPosition = .bottom
        managerPerformanceScatterChart.xAxis.labelPosition = .bottom
        
        fundPerformanceScatterChart.legend.enabled = false
        managerPerformanceScatterChart.legend.enabled = false
        
        productStrategyPieChart.drawHoleEnabled = false
        assetAllocationPieChart.drawHoleEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "基金公司"
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
        queue.addOperation {
            let url = "http://localhost:3000/field-value-pie"
            // "\(BASE_URL)/company/\(self.companyModel!.code)/product-strategy"
            Alamofire.request(url).responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json).arrayValue
                    
                    var productStrategyEntry = [PieChartDataEntry]()
                    for dict in result {
                        productStrategyEntry.append(PieChartDataEntry(value: dict["value"].doubleValue,
                                                                      label: dict["field"].stringValue))
                    }
                    
                    let productStrategyDataSet = PieChartDataSet(values: productStrategyEntry, label: "")
                    productStrategyDataSet.colors = ChartColorTemplates.vordiplom()
                    productStrategyDataSet.valueTextColor = .black
                    productStrategyDataSet.entryLabelColor = .clear
                    
                    let data = PieChartData(dataSet: productStrategyDataSet)
                    self.productStrategyPieChart.data = data
                }
            }
        }
        queue.addOperation {
            let url = "http://localhost:3000/field-value-pie"
            // "\(BASE_URL)/company/\(self.companyModel!.code)/product-strategy"
            Alamofire.request(url).responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json).arrayValue
                    
                    var assetAllocationEntry = [PieChartDataEntry]()
                    for dict in result {
                        assetAllocationEntry.append(PieChartDataEntry(value: dict["value"].doubleValue,
                                                                      label: dict["field"].stringValue))
                    }
                    
                    let assetAllocationDataSet = PieChartDataSet(values: assetAllocationEntry, label: "")
                    assetAllocationDataSet.colors = ChartColorTemplates.vordiplom()
                    assetAllocationDataSet.valueTextColor = .black
                    assetAllocationDataSet.entryLabelColor = .clear
                    
                    let data = PieChartData(dataSet: assetAllocationDataSet)
                    self.assetAllocationPieChart.data = data
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SCREEN_WIDTH - 20
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60))
        let label = UILabel(frame: CGRect(x: 13, y: 6, width: SCREEN_WIDTH - 19, height: 48))
        label.font = UIFont(name: "PingFangSC-Semibold", size: 28.0)
        label.text = self.companyModel?.name
        label.textColor = .white
        self.nameLabel = label
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }

}
