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
                                     "信息比率"]
    private let analysisURLArray = ["risk-trend",
                                    "daily-retracement",
                                    "volatility",
                                    "value-at-risk",
                                    "downside-volatility",
                                    "sharpe-index",
                                    "treynor-index",
                                    "jensen-index",
                                    "information-ratio"]

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

                SVProgressHUD.dismiss()

                self.performSegue(withIdentifier: "fullChartSegue", sender:
                    RPLineChartViewModel(title: self.analysisTypeArray[indexPath.row],
                                         data: LineChartData(dataSet: analysisDataSet),
                                         valueFormatter: RPFundDateFormatter(labels: dates)))
            }
        }
    }

     // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullChartSegue" {
            let vc = segue.destination as! RPLineChartViewController
            vc.dataModel = (sender as! RPLineChartViewModel)
        }
     }

}
