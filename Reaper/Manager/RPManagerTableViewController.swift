//
//  RPManagerTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/4.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts
import BTNavigationDropdownMenu

class RPManagerTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var totalScopeLabel: UILabel!
    @IBOutlet weak var bestReturnLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var appointedDateLabel: UILabel!
    
    @IBOutlet weak var abilityRadarChart: RadarChartView!
    
    @IBOutlet weak var fundRateTrendChart: LineChartView!
    
    var fundCode: String? = nil {
        didSet {
            Alamofire.request("\(BASE_URL)/fund/\(self.fundCode ?? "")/managers").responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json).arrayValue
                    var tempManagers = [RPManagerShortModel]()
                    for dict in result {
                        tempManagers.append(RPManagerShortModel(code: dict["id"].stringValue,
                                                            name: dict["name"].stringValue,
                                                            startDate: dict["startDate"].stringValue,
                                                            endDate: dict["endDate"].stringValue,
                                                            days: dict["days"].intValue,
                                                            returns: dict["returns"].doubleValue))
                    }
                    self.managers = tempManagers
                }
            }
        }
    }
    
    var managers: [RPManagerShortModel]? = nil {
        didSet {
            self.loadManager(of: managers![0].code)
            
            let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                                    containerView: self.navigationController!.view,
                                                    title: BTTitle.title(managers![0].name),
                                                    items: managers!.map{ $0.name })
            menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
                if let code = self?.managers![indexPath].code {
                    self?.loadManager(of: code)
                }
            }
            
            self.menuView = menuView
        }
    }
    
    var managerModel: RPManagerModel? = nil {
        didSet {
            DispatchQueue.main.async {
                self.nameLabel.text = self.managerModel?.name
                self.infoLabel.text = self.managerModel?.introduction
                self.companyLabel.text = String.init(format: "任职起始时间: %@", (self.managerModel?.company?.name)!)
                self.appointedDateLabel.text = String.init(format: "现任基金公司: %@", (self.managerModel?.appointedDate)!)
                self.totalScopeLabel.text = String.init(format: "%.2f", (self.managerModel?.totalScope)!)
                self.bestReturnLabel.text = String.init(format: "%.2f", (self.managerModel?.bestReturns)!)
                
                self.updateChartsData()
            }
        }
    }
    
    var menuView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .rpColor
        self.tableView.tableHeaderView = UIView()
        
        self.abilityRadarChart.chartDescription?.text = ""
        self.fundRateTrendChart.chartDescription?.text = ""
        
        self.abilityRadarChart.legend.enabled = false
        self.abilityRadarChart.yAxis.drawLabelsEnabled = false
        self.abilityRadarChart.xAxis.valueFormatter = RPManagerAbilityFormatter()
        
        self.fundRateTrendChart.xAxis.labelPosition = .bottom
        self.fundRateTrendChart.xAxis.drawGridLinesEnabled = false
        self.fundRateTrendChart.rightAxis.drawAxisLineEnabled = false
        self.fundRateTrendChart.rightAxis.drawLabelsEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "基金经理"
        self.tabBarController?.navigationItem.titleView = menuView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.tabBarController?.navigationItem.titleView = nil
    }
    
    func loadManager(of code: String) {
        
        print("Code: \(code)")
        
        Alamofire.request("\(BASE_URL)/manager/\(code)").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json)
                // FIXME: ID or CODE
                self.managerModel = RPManagerModel(code: result["id"].stringValue,
                                                   name: result["name"].stringValue,
                                                   appointedDate: result["appointedDate"].stringValue,
                                                   company: RPCompanyShortModel(code: result["company"]["id"].stringValue,
                                                                                name: result["company"]["name"].stringValue),
                                                   totalScope: result["totalScope"].doubleValue,
                                                   bestReturns: result["bestReturns"].doubleValue,
                                                   introduction: result["introduction"].stringValue)
                
                self.tableView.reloadData()
            }
        }
    }
    
    private func updateChartsData() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        // 现任收益率走势
        queue.addOperation {
            Alamofire.request("\(BASE_URL)/manager/\(self.managerModel!.code)/fund-rate-trend").responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json).arrayValue
                    
                    var fundRateTrendDataSetArray = [LineChartDataSet]()
                    
                    for dict in result {
                        _ = dict["id"]
                        let fundName = dict["name"]
                        let dataArr = dict["data"].arrayValue
                        
                        var dates = [String]()
                        var values = [Double]()
                        for pairs in dataArr {
                            dates.append((pairs.dictionaryValue["date"]?.stringValue)!)
                            values.append((pairs.dictionaryValue["value"]?.doubleValue)!)
                        }
                        
                        var dataEntries = [ChartDataEntry]()
                        for i in 0..<dates.count {
                            dataEntries.append(ChartDataEntry(x: Double(i) / Double(dates.count), y: values[i]))
                        }
                        
                        let fundRateTrendDataSet = LineChartDataSet(values: dataEntries, label: fundName.stringValue)
                        fundRateTrendDataSet.drawCircleHoleEnabled = false
                        fundRateTrendDataSet.drawCirclesEnabled = false
                        fundRateTrendDataSetArray.append(fundRateTrendDataSet)
                    }
                    
                    let data = LineChartData(dataSets: fundRateTrendDataSetArray)
                    self.fundRateTrendChart.data = data
//                    self.fundRateTrendChart.xAxis.valueFormatter = RPFundDateFormatter(labels: dates)
                }
            }
        }
        // 综合能力
        queue.addOperation {
            Alamofire.request("\(BASE_URL)/manager/\(self.managerModel!.code)/ability").responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json).dictionaryValue
                    
                    var abilityChartDataEntries = [RadarChartDataEntry]()
                    for (key, value) in result {
                        abilityChartDataEntries.append(RadarChartDataEntry(value: value.doubleValue,
                                                                           data: key as AnyObject))
                    }
                    let abilityDataSet = RadarChartDataSet(values: abilityChartDataEntries, label: "经理综合能力")
                    abilityDataSet.drawFilledEnabled = true
                    
                    let data = RadarChartData(dataSet: abilityDataSet)
                    self.abilityRadarChart.data = data
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return SCREEN_WIDTH - 20
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
}
