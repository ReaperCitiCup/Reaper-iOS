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
import SVProgressHUD

class RPCompanyTableViewController: UITableViewController {
    
    var companyModel: RPCompanyShortModel?
    private var nameLabel: UILabel?
    
    @IBOutlet weak var fundPerformanceScatterChart: ScatterChartView!
    @IBOutlet weak var managerPerformanceScatterChart: ScatterChartView!
    @IBOutlet weak var assetAllocationPieChart: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = .rpColor
        
        fundPerformanceScatterChart.chartDescription?.text = ""
        managerPerformanceScatterChart.chartDescription?.text = ""
        assetAllocationPieChart.chartDescription?.text = ""
        
        fundPerformanceScatterChart.rightAxis.drawLabelsEnabled = false
        managerPerformanceScatterChart.rightAxis.drawLabelsEnabled = false
        
        fundPerformanceScatterChart.xAxis.labelPosition = .bottom
        managerPerformanceScatterChart.xAxis.labelPosition = .bottom
        
        fundPerformanceScatterChart.legend.enabled = false
        managerPerformanceScatterChart.legend.enabled = false

        assetAllocationPieChart.drawHoleEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "基金公司"
        self.updateCharts()

        print("Company Code : \(companyModel?.code)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func updateCharts() {
        guard companyModel != nil else {
            return
        }

        SVProgressHUD.show()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation {
            Alamofire.request("\(BASE_URL)/company/\(self.companyModel!.code)/fund-performance").responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json).dictionaryValue["funds"]?.arrayValue

                    print("Company fund-performance \(result)")

                    var fundPerformanceEntry = [ChartDataEntry]()
                    for dict in result ?? [] {
                        fundPerformanceEntry.append(ChartDataEntry(x: dict["rate"].doubleValue,
                                                                   y: dict["risk"].doubleValue,
                                                                   data: dict["name"].stringValue as AnyObject))
                    }
                    let fundPerformanceDataSet = ScatterChartDataSet(values: fundPerformanceEntry)
                    fundPerformanceDataSet.setScatterShape(.circle)
                    let data = ScatterChartData(dataSet: fundPerformanceDataSet)
                    self.fundPerformanceScatterChart.data = data
                    self.fundPerformanceScatterChart.notifyDataSetChanged()
                }
            }
        }
        queue.addOperation {
            Alamofire.request("\(BASE_URL)/company/\(self.companyModel!.code)/manager-performance").responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json).dictionaryValue["managers"]?.arrayValue

                    print("Company manager-performance \(result)")
                    
                    var managerPerformanceEntry = [ChartDataEntry]()
                    for dict in result ?? [] {
                        managerPerformanceEntry.append(ChartDataEntry(x: dict["rate"].doubleValue,
                                                                   y: dict["risk"].doubleValue,
                                                                   data: dict["name"].stringValue as AnyObject))
                    }
                    let managerPerformanceDataSet = ScatterChartDataSet(values: managerPerformanceEntry)
                    managerPerformanceDataSet.setScatterShape(.circle)
                    let data = ScatterChartData(dataSet: managerPerformanceDataSet)
                    self.managerPerformanceScatterChart.data = data
                    self.managerPerformanceScatterChart.notifyDataSetChanged()
                }
            }
        }
        queue.addOperation {
            let url = "\(BASE_URL)/company/\(self.companyModel!.code)/asset-allocation"
            Alamofire.request(url).responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json).arrayValue

                    print("Company asset \(result)")
                    
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
                    self.assetAllocationPieChart.notifyDataSetChanged()
                }
            }
        }
        queue.addOperation {
            SVProgressHUD.dismiss()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
