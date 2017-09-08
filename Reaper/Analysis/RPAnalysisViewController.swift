//
//  RPAnalysisViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/7.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import SwiftyJSON
import BTNavigationDropdownMenu

class RPAnalysisViewController: UIViewController {
    
    var fundCode: String?
    let analysisTypeArray = ["风险走势",
                             "每日回撤",
                             "波动率",
                             "在险价值",
                             "下行波动率",
                             "夏普指标",
                             "特雷诺指标",
                             "詹森指数",
                             "信息比率"]
    let analysisURLArray = ["risk-trend",
                            "daily-retracement",
                            "volatility",
                            "value-at-risk",
                            "downside-volatility",
                            "sharpe-index",
                            "treynor-index",
                            "jensen-index",
                            "information-ratio"]
    var menuView: UIView?
    @IBOutlet weak var lineChartView: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                                containerView: self.navigationController!.view,
                                                title: BTTitle.title("深度分析"),
                                                items: analysisTypeArray)
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            self?.loadData(at: indexPath)
        }
        
        self.menuView = menuView
        
        self.lineChartView.chartDescription?.text = ""
        self.lineChartView.xAxis.labelPosition = .bottom
        self.lineChartView.xAxis.drawGridLinesEnabled = false
        self.lineChartView.rightAxis.drawAxisLineEnabled = false
        self.lineChartView.rightAxis.drawLabelsEnabled = false
        self.lineChartView.legend.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "深度分析"
        self.tabBarController?.navigationItem.titleView = menuView!
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tabBarController?.navigationItem.titleView = nil
    }
    
    private func loadData(at index: Int) {
        Alamofire.request("\(BASE_URL)/fund/\(self.fundCode!)/\(analysisURLArray[index])").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).arrayValue
                
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
                
                let data = LineChartData(dataSet: analysisDataSet)
                self.lineChartView.data = data
                self.lineChartView.xAxis.valueFormatter = RPFundDateFormatter(labels: dates)
            }
        }
    }

}
