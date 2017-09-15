//
//  RPCompanyTableViewController+Charts.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/14.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Charts
import SVProgressHUD

extension RPCompanyTableViewController {
    
    func updateFundPerformance() {
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
    
    func updateManagerPerformance() {
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
    
    func updateAssetAllocation() {
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
                assetAllocationDataSet.colors = UIColor.reaperColors()
                assetAllocationDataSet.valueTextColor = .black
                assetAllocationDataSet.entryLabelColor = .clear
                
                let data = PieChartData(dataSet: assetAllocationDataSet)
                self.assetAllocationPieChart.data = data
                self.assetAllocationPieChart.notifyDataSetChanged()
            }
        }
    }
    
    func updateStyleProfit() {
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
    
    func updateStyleRisk() {
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
    
    func updateIndustryProfit() {
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
    
    func updateIndustryRisk() {
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
    
}
