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
        
        SVProgressHUD.show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "基金公司"
        self.updateCharts()

        print("Company Code : \(companyModel?.code ?? "")")
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
            self.updateFundPerformance()
        }
        queue.addOperation {
            self.updateManagerPerformance()
        }
        queue.addOperation {
            self.updateAssetAllocation()
        }
        queue.addOperation {
            SVProgressHUD.dismiss()
        }
    }

    @IBAction func horizontalAction(_ sender: UIButton) {
        guard companyModel != nil else {
            SVProgressHUD.showInfo(withStatus: "数据仍在加载")
            SVProgressHUD.dismiss(withDelay: 2.0)
            return
        }
        SVProgressHUD.show()
        switch sender.tag {
        case 0:
            updateStyleProfit()
        case 1:
            updateStyleRisk()
        case 2:
            updateIndustryProfit()
        case 3:
            updateIndustryRisk()
        default:
            break
        }
    }

    private func updateFundPerformance() {
        Alamofire.request("\(BASE_URL)/company/\(self.companyModel!.code)/fund-performance").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).dictionaryValue["funds"]?.arrayValue
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

    private func updateManagerPerformance() {
        Alamofire.request("\(BASE_URL)/company/\(self.companyModel!.code)/manager-performance").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).dictionaryValue["managers"]?.arrayValue
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

    private func updateAssetAllocation() {
        let url = "\(BASE_URL)/company/\(self.companyModel!.code)/asset-allocation"
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
                self.assetAllocationPieChart.notifyDataSetChanged()
            }
        }
    }

    private func updateStyleProfit() {
        let url = "\(BASE_URL)/company/\(self.companyModel!.code)/style-attribution/profit"
        Alamofire.request(url).responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).arrayValue
                var styleAttributionProfitEntries = [ChartDataEntry]()
                
                var valueLabels: [String: Double] = [:]
                for i in 0..<result.count {
                    let dict = result[i].dictionaryValue
                    if let value = dict["value"]?.doubleValue {
                        valueLabels[(dict["field"]?.stringValue)!] = value
                    }
                }
                let valueLabelsSorted = valueLabels.sorted(by: {$0.1 < $1.1})
                for i in 0..<valueLabelsSorted.count {
                    styleAttributionProfitEntries.append(BarChartDataEntry(x: Double(i),
                                                                              y: valueLabelsSorted[i].value))
                }

                let styleAttributionProfitDataSet = BarChartDataSet(values: styleAttributionProfitEntries, label: "")
                styleAttributionProfitDataSet.setColor(.rpColor)
                styleAttributionProfitDataSet.valueTextColor = .black

                let data = BarChartData(dataSet: styleAttributionProfitDataSet)
                data.barWidth = 1.0

                self.performSegue(withIdentifier: "horizontalSegue", sender: RPChartViewModel(title: "风格归因 - 主动收益",
                                                                                         data: data,
                                                                                         valueFormatter:  IndexAxisValueFormatter(values:  valueLabelsSorted.map({$0.key}))))
            }
        }
    }

    private func updateStyleRisk() {
        let url = "\(BASE_URL)/company/\(self.companyModel!.code)/style-attribution/risk"
        Alamofire.request(url).responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).arrayValue
                var styleAttributionRiskEntries = [ChartDataEntry]()

                var valueLabels: [String: Double] = [:]
                for i in 0..<result.count {
                    let dict = result[i].dictionaryValue
                    if let value = dict["value"]?.doubleValue {
                        valueLabels[(dict["field"]?.stringValue)!] = value
                    }
                }
                let valueLabelsSorted = valueLabels.sorted(by: {$0.1 < $1.1})
                for i in 0..<valueLabelsSorted.count {
                    styleAttributionRiskEntries.append(BarChartDataEntry(x: Double(i),
                                                                              y: valueLabelsSorted[i].value))
                }

                let styleAttributionRiskDataSet = BarChartDataSet(values: styleAttributionRiskEntries, label: "")
                styleAttributionRiskDataSet.setColor(.rpColor)
                styleAttributionRiskDataSet.valueTextColor = .black

                let data = BarChartData(dataSet: styleAttributionRiskDataSet)
                data.barWidth = 1.0

                self.performSegue(withIdentifier: "horizontalSegue", sender: RPChartViewModel(title: "风格归因 - 主动风险",
                                                                                         data: data,
                                                                                         valueFormatter:  IndexAxisValueFormatter(values:  valueLabelsSorted.map({$0.key}))))
            }
        }
    }

    private func updateIndustryProfit() {
        let url = "\(BASE_URL)/company/\(self.companyModel!.code)/industry-attribution/profit"
        Alamofire.request(url).responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).arrayValue
                var industryAttributionProfitEntries = [ChartDataEntry]()

                var valueLabels: [String: Double] = [:]
                for i in 0..<result.count {
                    let dict = result[i].dictionaryValue
                    if let value = dict["value"]?.doubleValue {
                        valueLabels[(dict["field"]?.stringValue)!] = value
                    }
                }
                let valueLabelsSorted = valueLabels.sorted(by: {$0.1 < $1.1})
                for i in 0..<valueLabelsSorted.count {
                    industryAttributionProfitEntries.append(BarChartDataEntry(x: Double(i),
                                                                              y: valueLabelsSorted[i].value))
                }

                let industryAttributionProfitDataSet = BarChartDataSet(values: industryAttributionProfitEntries, label: "")
                industryAttributionProfitDataSet.setColor(.rpColor)
                industryAttributionProfitDataSet.valueTextColor = .black

                let data = BarChartData(dataSet: industryAttributionProfitDataSet)
                data.barWidth = 1.0

                self.performSegue(withIdentifier: "horizontalSegue", sender: RPChartViewModel(title: "行业归因 - 主动收益",
                                                                                         data: data,
                                                                                         valueFormatter:  IndexAxisValueFormatter(values:  valueLabelsSorted.map({$0.key}))))
            }
        }
    }

    private func updateIndustryRisk() {
        let url = "\(BASE_URL)/company/\(self.companyModel!.code)/industry-attribution/risk"
        Alamofire.request(url).responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).arrayValue
                var industryAttributionRiskEntries = [ChartDataEntry]()

                var valueLabels: [String: Double] = [:]
                for i in 0..<result.count {
                    let dict = result[i].dictionaryValue
                    if let value = dict["value"]?.doubleValue {
                        valueLabels[(dict["field"]?.stringValue)!] = value
                    }
                }
                let valueLabelsSorted = valueLabels.sorted(by: {$0.1 < $1.1})
                for i in 0..<valueLabelsSorted.count {
                    industryAttributionRiskEntries.append(BarChartDataEntry(x: Double(i),
                                                                              y: valueLabelsSorted[i].value))
                }

                let industryAttributionRiskDataSet = BarChartDataSet(values: industryAttributionRiskEntries, label: "")
                industryAttributionRiskDataSet.setColor(.rpColor)
                industryAttributionRiskDataSet.valueTextColor = .black

                let data = BarChartData(dataSet: industryAttributionRiskDataSet)
                data.barWidth = 1.0

                self.performSegue(withIdentifier: "horizontalSegue", sender: RPChartViewModel(title: "行业归因 - 主动风险",
                                                                                         data: data,
                                                                                         valueFormatter:  IndexAxisValueFormatter(values:  valueLabelsSorted.map({$0.key}))))
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row <= 2 {
            return SCREEN_WIDTH - 20
        } else {
            return 100.0
        }
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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "horizontalSegue" {
            SVProgressHUD.dismiss()
            let vc = segue.destination as! RPHorizontalBarChartViewController
            vc.dataModel = (sender as! RPChartViewModel)
        }
    }

}
