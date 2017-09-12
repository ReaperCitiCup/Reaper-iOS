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
import SVProgressHUD

class RPManagerTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var totalScopeLabel: UILabel!
    @IBOutlet weak var bestReturnLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var appointedDateLabel: UILabel!
    
    @IBOutlet weak var abilityRadarChart: RadarChartView!
    @IBOutlet weak var fundRankHorizontalBarChart: HorizontalBarChartView!
    @IBOutlet weak var fundRateTrendChart: LineChartView!
    @IBOutlet weak var managerFundPerformanceScatterChart: ScatterChartView!
    @IBOutlet weak var managerPerformanceScatterChart: ScatterChartView!
    
    @IBOutlet weak var historyFundView: RPManagerHistoryFundView!
    
    var fundCode: String? = nil {
        didSet {
            let url = "\(BASE_URL)/fund/\(self.fundCode ?? "")/managers"
            Alamofire.request(url).responseJSON { response in
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
                                                    items: managers!.map { $0.name })
            menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> Void in
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
    
    private var menuView: BTNavigationDropdownMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .rpColor
        self.tableView.tableHeaderView = UIView()
        
        self.abilityRadarChart.chartDescription?.text = ""
        self.fundRateTrendChart.chartDescription?.text = ""
        self.fundRankHorizontalBarChart.chartDescription?.text = ""
        self.managerFundPerformanceScatterChart.chartDescription?.text = ""
        self.managerPerformanceScatterChart.chartDescription?.text = ""
        
        self.abilityRadarChart.legend.enabled = false
        self.abilityRadarChart.yAxis.drawLabelsEnabled = false
        self.abilityRadarChart.xAxis.valueFormatter = RPManagerAbilityFormatter()
        
        self.fundRateTrendChart.xAxis.labelPosition = .bottom
        self.fundRateTrendChart.xAxis.drawGridLinesEnabled = false
        self.fundRateTrendChart.rightAxis.drawAxisLineEnabled = false
        self.fundRateTrendChart.rightAxis.drawLabelsEnabled = false
        
        self.fundRankHorizontalBarChart.xAxis.labelPosition = .bottom
        self.fundRankHorizontalBarChart.rightAxis.drawAxisLineEnabled = false
        self.fundRankHorizontalBarChart.rightAxis.drawLabelsEnabled = false
        self.fundRankHorizontalBarChart.dragEnabled = false
        self.fundRankHorizontalBarChart.doubleTapToZoomEnabled = false
        self.fundRankHorizontalBarChart.pinchZoomEnabled = false
        self.fundRankHorizontalBarChart.xAxis.drawGridLinesEnabled = false

        managerFundPerformanceScatterChart.rightAxis.drawLabelsEnabled = false
        managerPerformanceScatterChart.rightAxis.drawLabelsEnabled = false

        managerFundPerformanceScatterChart.xAxis.labelPosition = .bottom
        managerPerformanceScatterChart.xAxis.labelPosition = .bottom

        managerFundPerformanceScatterChart.legend.enabled = false
        managerPerformanceScatterChart.legend.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "基金经理"
        self.tabBarController?.navigationItem.titleView = menuView

        print("Manager Code : \(managerModel?.code ?? "")")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tabBarController?.navigationItem.titleView = nil

        menuView?.hide()
    }
    
    func loadManager(of code: String) {
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
        guard managerModel != nil else {
            return
        }
        SVProgressHUD.show()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        // 现任收益率走势
        queue.addOperation {
            self.updateFundRateTrend()
        }
        // 现任基金排名
        queue.addOperation {
            self.updateManagerFundRank()
        }
        // 综合能力
        queue.addOperation {
            self.updateAbility()
        }
        // 历史基金
        queue.addOperation {
            self.updateHistoryFund()
        }
        // 历任基金表现
        queue.addOperation {
            self.updateFundPerformance()
        }
        // 基金经理表现
        queue.addOperation {
            self.updateManagerPerformance()
        }
        queue.addOperation {
            SVProgressHUD.dismiss()
        }
    }

    private func updateFundRateTrend() {
        Alamofire.request("\(BASE_URL)/manager/\(self.managerModel!.code)/fund-rate-trend").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).arrayValue

                var fundRateTrendDataSetArray = [LineChartDataSet]()

                if result.count > 0 {
                    for dict in result {
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
                        fundRateTrendDataSet.setColor(ChartColorTemplates.vordiplom()[fundRateTrendDataSetArray.count % ChartColorTemplates.vordiplom().count])
                        fundRateTrendDataSetArray.append(fundRateTrendDataSet)
                    }

                    let data = LineChartData(dataSets: fundRateTrendDataSetArray)
                    self.fundRateTrendChart.data = data
                    //                    self.fundRateTrendChart.xAxis.valueFormatter = RPFundDateFormatter(labels: dates)
                }
            }
        }
    }

    private func updateManagerFundRank() {
        Alamofire.request("\(BASE_URL)/manager/\(self.managerModel!.code)/fund-rank").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).arrayValue

                var monthDataSets = [BarChartDataSet]()

                for fundDict in result {
                    let fundName = fundDict["name"].stringValue

                    var monthDataEntries: [BarChartDataEntry] = []
                    for dict in fundDict["data"].arrayValue {
                        let month = Int.transformToXAxis(from: dict["month"].intValue)
                        let rank = dict["rank"].doubleValue
                        let total = dict["total"].doubleValue
                        monthDataEntries.append(BarChartDataEntry(x: Double(month),
                                                                  y: rank / total,
                                                                  data: fundName as AnyObject))
                    }

                    let dataSet = BarChartDataSet(values: monthDataEntries.sorted(by: { $0.x < $1.x }),
                                                  label: fundName)
                    dataSet.setColor(ChartColorTemplates.vordiplom()[monthDataSets.count % ChartColorTemplates.vordiplom().count])

                    monthDataSets.append(dataSet)
                }

                let data = BarChartData(dataSets: monthDataSets)
                data.barWidth /= (Double(monthDataSets.count) * 1.5)
                data.groupBars(fromX: 0.45,
                               groupSpace: 0.15,
                               barSpace: 0.15)

                self.fundRankHorizontalBarChart.xAxis.valueFormatter = RPManagerFundRankFormatter()
                self.fundRankHorizontalBarChart.data = data
            }
        }
    }

    private func updateAbility() {
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

    private func updateHistoryFund() {
        Alamofire.request("\(BASE_URL)/manager/\(self.managerModel!.code)/funds").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).arrayValue

                var models: [RPManagerHistoryFundModel] = []

                for dict in result {
                    models.append(RPManagerHistoryFundModel(name: dict["name"].stringValue,
                                                            scale: dict["scope"].doubleValue,
                                                            returnVal: dict["returns"].doubleValue))
                }

                self.historyFundView.fundHistoryModels = models
            }
        }
    }

    private func updateFundPerformance() {
        Alamofire.request("\(BASE_URL)/manager/\(self.managerModel!.code)/fund-performance").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).arrayValue

                var fundPerformanceEntry = [ChartDataEntry]()
                for dict in result {
                    fundPerformanceEntry.append(ChartDataEntry(x: dict["rate"].doubleValue,
                                                               y: dict["risk"].doubleValue))
                }
                let fundPerformanceDataSet = ScatterChartDataSet(values: fundPerformanceEntry)
                let data = ScatterChartData(dataSet: fundPerformanceDataSet)
                self.managerFundPerformanceScatterChart.data = data
            }
        }
    }

    private func updateManagerPerformance() {
        Alamofire.request("\(BASE_URL)/manager/\(self.managerModel!.code)/manager-performance").responseJSON { response in
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

    @IBAction func seeFullChartAction(_ sender: UIButton) {
        if let data = self.fundRateTrendChart.data {
            self.performSegue(withIdentifier: "fullChartSegue", sender: RPLineChartViewModel(title: "现任基金收益率走势",
                                                                                             data: data,
                                                                                             valueFormatter: self.fundRateTrendChart.xAxis.valueFormatter))
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 3, 7, 8:
            return SCREEN_WIDTH - 20
        case 6:
            return CGFloat(75 + historyFundView.fundHistoryModels.count * 30)
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullChartSegue" {
            let vc = segue.destination as! RPLineChartViewController
            vc.dataModel = (sender as? RPLineChartViewModel)
        }
    }

}

private extension Int {
    
    static func transformToXAxis(from month: Int) -> Int {
        switch month {
        case 1:
            return 1
        case 3:
            return 2
        case 6:
            return 3
        case 12:
            return 4
        case 24:
            return 5
        case 36:
            return 6
        default:
            return -1
        }
    }
    
}
