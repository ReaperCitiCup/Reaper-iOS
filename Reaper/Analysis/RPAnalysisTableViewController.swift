//
//  RPAnalysisTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/12.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts
import SVProgressHUD

class RPAnalysisTableViewController: UITableViewController {

    var fundCode: String?
    private let analysisTypeArray = ["风险走势",
                                     "每日回撤",
                                     "波动率",
                                     "在险价值",
                                     "下行波动率",
                                     "夏普指标",
                                     "特雷诺指标",
                                     "詹森指数",
                                     "风格归因 - 主动收益",
                                     "风格归因 - 主动风险",
                                     "行业归因 - 主动收益",
                                     "行业归因 - 主动风险",
                                     "品种归因",
                                     "Brison 归因 - 基于股票持仓",
                                     "Brison 归因 - 基于债券持仓"]
    private let analysisURLArray = ["risk-trend",
                                    "daily-retracement",
                                    "volatility",
                                    "value-at-risk",
                                    "downside-volatility",
                                    "sharpe-index",
                                    "treynor-index",
                                    "jensen-index",
                                    "style-attribution/profit",
                                    "style-attribution/risk",
                                    "industry-attribution/profit",
                                    "industry-attribution/risk",
                                    "variety-attribution",
                                    "brison-attribution/stock",
                                    "brison-attribution/bond"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "深度分析"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return analysisTypeArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RPAnalysisTableViewCell", for: indexPath)

        cell.textLabel?.text = analysisTypeArray[indexPath.row]

        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        SVProgressHUD.show()
        Alamofire.request("\(BASE_URL)/fund/\(self.fundCode!)/\(analysisURLArray[indexPath.row])").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).arrayValue

                print("Analysis \(result)")

                if indexPath.row <= 7 {
                    var dates = [String]()
                    var values = [Double]()
                    
                    for dict in result {
                        dates.append((dict.dictionaryValue["date"]?.stringValue)!)
                        values.append((dict.dictionaryValue["value"]?.doubleValue)!)
                    }
                    
                    var dataEntries = [ChartDataEntry]()
                    for i in 0..<dates.count {
                        dataEntries.append(ChartDataEntry(x: Double(i) / Double(dates.count), y: values[i]))
                    }
                    
                    let analysisDataSet = LineChartDataSet(values: dataEntries, label: "")
                    analysisDataSet.drawCircleHoleEnabled = false
                    analysisDataSet.drawCirclesEnabled = false
                    
                    self.performSegue(withIdentifier: "fullChartSegue", sender:
                        RPChartViewModel(title: self.analysisTypeArray[indexPath.row],
                                         data: LineChartData(dataSet: analysisDataSet),
                                         valueFormatter: RPFundDateFormatter(labels: dates)))
                } else {
                    var valueLabels: [String: Double] = [:]
                    for i in 0..<result.count {
                        let dict = result[i].dictionaryValue
                        if let value = dict["value"]?.doubleValue {
                            valueLabels[(dict["field"]?.stringValue)!] = value
                        }
                    }
                    
                    var barEntries = [ChartDataEntry]()
                    let valueLabelsSorted = valueLabels.sorted(by: {$0.1 < $1.1})
                    for i in 0..<valueLabelsSorted.count {
                        barEntries.append(BarChartDataEntry(x: Double(i),
                                                            y: valueLabelsSorted[i].value))
                    }
                    
                    let barDataSet = BarChartDataSet(values: barEntries, label: "")
                    barDataSet.setColor(.rpColor)
                    barDataSet.valueTextColor = .black
                    
                    let data = BarChartData(dataSet: barDataSet)
                    
                    self.performSegue(withIdentifier: "horizontalSegue",
                                      sender: RPChartViewModel(title: self.analysisTypeArray[indexPath.row],
                                                               data: data,
                                                               valueFormatter:  IndexAxisValueFormatter(values:  valueLabelsSorted.map({$0.key}))))
                }
                SVProgressHUD.dismiss()
            }
        }
    }

     // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullChartSegue" {
            let vc = segue.destination as! RPLineChartViewController
            vc.dataModel = (sender as! RPChartViewModel)
        } else if segue.identifier == "horizontalSegue" {
            let vc = segue.destination as! RPHorizontalBarChartViewController
            vc.dataModel = (sender as! RPChartViewModel)
        }
     }

}
