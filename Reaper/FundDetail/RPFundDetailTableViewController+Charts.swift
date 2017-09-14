//
//  RPFundDetailTableViewController+Charts.swift
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

extension RPFundDetailTableViewController {
    
    func unitNetValueAction() {
        Alamofire.request("\(BASE_URL)/fund/\(self.fundCode ?? "")/unit-net-value").responseJSON { response in
            if let json = response.result.value {
                var unitNetValueDataSet = LineChartDataSet()
                
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
                
                unitNetValueDataSet = LineChartDataSet(values: dataEntries, label: "单位净值走势")
                unitNetValueDataSet.drawCircleHoleEnabled = false
                unitNetValueDataSet.drawCirclesEnabled = false
                unitNetValueDataSet.setColor(.rpColor)
                
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "fullChartSegue", sender:
                    RPChartViewModel(title: "单位净值走势",
                                     data: LineChartData(dataSet: unitNetValueDataSet),
                                     valueFormatter: RPFundDateFormatter(labels: dates)))
            }
        }
    }
    
    func cumulativeNetValueAction() {
        Alamofire.request("\(BASE_URL)/fund/\(self.fundCode ?? "")/cumulative-net-value").responseJSON { response in
            if let json = response.result.value {
                let result2 = JSON(json).arrayValue
                
                var cumulativeNetValueDataSet = LineChartDataSet()
                
                var dates2 = [String]()
                var values2 = [Double]()
                for dict in result2 {
                    dates2.append((dict.dictionaryValue["date"]?.stringValue)!)
                    values2.append((dict.dictionaryValue["value"]?.doubleValue)!)
                }
                
                var dataEntries2 = [ChartDataEntry]()
                for i in 0..<dates2.count {
                    dataEntries2.append(ChartDataEntry(x: Double(i) / Double(dates2.count), y: values2[i]))
                }
                cumulativeNetValueDataSet = LineChartDataSet(values: dataEntries2, label: "累积净值走势")
                cumulativeNetValueDataSet.drawCircleHoleEnabled = false
                cumulativeNetValueDataSet.drawCirclesEnabled = false
                cumulativeNetValueDataSet.setColor(.rpColor)
                
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "fullChartSegue", sender:
                    RPChartViewModel(title: "累积净值走势",
                                     data: LineChartData(dataSet: cumulativeNetValueDataSet),
                                     valueFormatter: RPFundDateFormatter(labels: dates2)))
            }
        }
    }

    func updateCurrentAsset() {
        Alamofire.request("\(BASE_URL)/fund/\(self.fundCode ?? "")/current-asset").responseJSON { response in
            if let json = response.result.value {
                let result4 = JSON(json).dictionaryValue
                
                print("Current Asset \(result4)")
                
                var currentAssetDict = [String: Double]()
                for (key, value) in result4 where value.doubleValue > 0 {
                    currentAssetDict[key] = value.doubleValue
                }
                
                var dataEntries4 = [PieChartDataEntry]()
                for (key, value) in currentAssetDict {
                    dataEntries4.append(PieChartDataEntry(value: value, label: key))
                }
                let currentAssetDataSet = PieChartDataSet(values: dataEntries4, label: "")
                currentAssetDataSet.colors = ChartColorTemplates.vordiplom()
                currentAssetDataSet.valueTextColor = .black
                currentAssetDataSet.entryLabelColor = .clear
                
                DispatchQueue.main.async {
                    let data = PieChartData(dataSet: currentAssetDataSet)
                    self.currentAssetChart.data = data
                    self.currentAssetChart.data?.notifyDataChanged()
                    self.currentAssetChart.notifyDataSetChanged()
                }
            }
        }
    }
    
    func rateAction(_ month: String, title: String) {
        SVProgressHUD.show()
        Alamofire.request(
            "\(BASE_URL)/fund/\(self.fundCode ?? "")/rate",
            method: .get,
            parameters: ["month": month]
            ).responseJSON { response in
                if let json = response.result.value {
                    let result3 = JSON(json).arrayValue
                    
                    var dates3 = [String]()
                    var values3 = [Double]()
                    for dict in result3 {
                        dates3.append((dict.dictionaryValue["date"]?.stringValue)!)
                        values3.append((dict.dictionaryValue["value"]?.doubleValue)!)
                    }
                    
                    var dataEntries3 = [ChartDataEntry]()
                    for i in 0..<dates3.count {
                        dataEntries3.append(ChartDataEntry(x: Double(i) / Double(dates3.count), y: values3[i]))
                    }
                    let rateDataSet = LineChartDataSet(values: dataEntries3, label: "累积收益率走势 - \(title)")
                    rateDataSet.drawCircleHoleEnabled = false
                    rateDataSet.drawCirclesEnabled = false
                    rateDataSet.valueFont = UIFont(name: "PingFangSC-Regular", size: 15.0)!
                    
                    SVProgressHUD.dismiss()
                    
                    self.performSegue(withIdentifier: "fullChartSegue", sender:
                        RPChartViewModel(title: "累积收益率走势 - \(title)",
                            data: LineChartData(dataSet: rateDataSet),
                            valueFormatter: RPFundDateFormatter(labels: dates3)))
                }
        }
    }
    
    func updateStyleProfit() {
        let url = "\(BASE_URL)/fund/\(self.fundCode ?? "")/style-attribution/profit"
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
                
                self.performSegue(withIdentifier: "horizontalSegue",
                                  sender: RPChartViewModel(title: "风格归因 - 主动收益",
                                                           data: data,
                                                           valueFormatter: IndexAxisValueFormatter(values:  valueLabelsSorted.map({$0.key}))))
            }
        }
    }
    
    func updateStyleRisk() {
        let url = "\(BASE_URL)/fund/\(self.fundCode ?? "")/style-attribution/risk"
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
                
                self.performSegue(withIdentifier: "horizontalSegue",
                                  sender: RPChartViewModel(title: "风格归因 - 主动风险",
                                                           data: data,
                                                           valueFormatter: IndexAxisValueFormatter(values:  valueLabelsSorted.map({$0.key}))))
            }
        }
    }
    
    func updateIndustryProfit() {
        let url = "\(BASE_URL)/fund/\(self.fundCode ?? "")/industry-attribution/profit"
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
                
                self.performSegue(withIdentifier: "horizontalSegue", sender: RPChartViewModel(title: "行业归因 - 主动收益",
                                                                                              data: data,
                                                                                              valueFormatter:  IndexAxisValueFormatter(values:  valueLabelsSorted.map({$0.key}))))
            }
        }
    }
    
    func updateIndustryRisk() {
        let url = "\(BASE_URL)/fund/\(self.fundCode ?? "")/industry-attribution/risk"
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
                
                self.performSegue(withIdentifier: "horizontalSegue",
                                  sender: RPChartViewModel(title: "行业归因 - 主动风险",
                                                           data: data,
                                                           valueFormatter: IndexAxisValueFormatter(values:  valueLabelsSorted.map({$0.key}))))
            }
        }
    }

}
