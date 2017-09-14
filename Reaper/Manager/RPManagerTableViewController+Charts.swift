//
//  RPManagerTableViewController+Charts.swift
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

extension RPManagerTableViewController {
    
    func updateFundRateTrend() {
        Alamofire.request("\(BASE_URL)/manager/\(self.managerModel!.code)/fund-rate-trend").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).arrayValue
                
                var fundRateTrendDataSetArray = [LineChartDataSet]()
                
                var dateFormatter: RPFundDateFormatter? = nil
                
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
                        
                        if dateFormatter == nil {
                            dateFormatter = RPFundDateFormatter(labels: dates)
                        }
                    }
                    
                    let data = LineChartData(dataSets: fundRateTrendDataSetArray)
                    self.fundRateTrendChart.data = data
                    self.fundRateTrendChart.xAxis.valueFormatter = dateFormatter!
                }
            }
        }
    }
    
    func updateManagerFundRank() {
        //        Alamofire.request("\(BASE_URL)/manager/\(self.managerModel!.code)/fund-rank").responseJSON { response in
        //            if let json = response.result.value {
        //                let result = JSON(json).arrayValue
        //
        //                var monthDataSets = [BarChartDataSet]()
        //
        //                var fields: [String] = []
        //                for fundDict in result {
        //                    let fundName = fundDict["name"].stringValue
        //
        //                    var monthDataEntries: [BarChartDataEntry] = []
        //
        //                    for dict in fundDict["data"].arrayValue {
        //                        let rank = dict["rank"].doubleValue
        //                        let total = dict["total"].doubleValue
        //                        let type = dict["type"].stringValue
        //
        //                        fields.append(type)
        //
        //                        monthDataEntries.append(BarChartDataEntry(x: Double(monthDataEntries.count),
        //                                                                  y: rank / total,
        //                                                                  data: type as AnyObject))
        //                    }
        //
        //                    let dataSet = BarChartDataSet(values: monthDataEntries,
        //                                                  label: fundName)
        //                    dataSet.setColor(ChartColorTemplates.vordiplom()[monthDataSets.count % ChartColorTemplates.vordiplom().count])
        //
        //                    monthDataSets.append(dataSet)
        //                }
        //
        //                let data = BarChartData(dataSets: monthDataSets)
        //                data.barWidth /= (Double(monthDataSets.count) * 1.5)
        //                data.groupBars(fromX: 0.45,
        //                               groupSpace: 0.15,
        //                               barSpace: 0.15)
        //
        //                self.fundRankHorizontalBarChart.xAxis.valueFormatter = RPAttributionFormatter(labels: fields)
        //                self.fundRankHorizontalBarChart.data = data
        //                self.fundRankHorizontalBarChart.notifyDataSetChanged()
        //            }
        //        }
    }
    
    func updateAbility() {
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
                self.abilityRadarChart.notifyDataSetChanged()
            }
        }
    }
    
    func updateHistoryFund() {
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
    
    func updateFundPerformance() {
        Alamofire.request("\(BASE_URL)/manager/\(self.managerModel!.code)/fund-performance").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json)["funds"].arrayValue
                
                //                var labels: [String] = []
                var fundPerformanceEntry = [ChartDataEntry]()
                for dict in result {
                    //                    labels.append(dict["name"].stringValue)
                    fundPerformanceEntry.append(ChartDataEntry(x: dict["rate"].doubleValue,
                                                               y: dict["risk"].doubleValue,
                                                               data: dict["name"].stringValue as AnyObject))
                }
                let fundPerformanceDataSet = ScatterChartDataSet(values: fundPerformanceEntry)
                fundPerformanceDataSet.setColor(.rpColor)
                let data = ScatterChartData(dataSet: fundPerformanceDataSet)
                self.managerFundPerformanceScatterChart.data = data
                self.managerFundPerformanceScatterChart.notifyDataSetChanged()
                
            }
        }
    }
    
    func updateManagerPerformance() {
        Alamofire.request("\(BASE_URL)/manager/\(self.managerModel!.code)/manager-performance").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json).dictionaryValue
                
                var managerPerformanceEntry = [ChartDataEntry]()
                if let managerArray = result["managers"]?.arrayValue {
                    for dict in managerArray {
                        managerPerformanceEntry.append(ChartDataEntry(x: dict["rate"].doubleValue,
                                                                      y: dict["risk"].doubleValue))
                    }
                }
                var otherManagerPerformanceEntry = [ChartDataEntry]()
                if let otherManagerArray = result["others"]?.arrayValue {
                    for otherDict in otherManagerArray {
                        otherManagerPerformanceEntry.append(ChartDataEntry(x: otherDict["rate"].doubleValue,
                                                                           y: otherDict["risk"].doubleValue))
                    }
                }
                
                let managerPerformanceDataSet = ScatterChartDataSet(values: managerPerformanceEntry)
                managerPerformanceDataSet.setColor(ChartColorTemplates.vordiplom()[0])
                let otherManagerPerformanceDataSet = ScatterChartDataSet(values: otherManagerPerformanceEntry)
                otherManagerPerformanceDataSet.setColor(ChartColorTemplates.vordiplom()[1])
                let data = ScatterChartData(dataSets: [managerPerformanceDataSet, otherManagerPerformanceDataSet])
                self.managerPerformanceScatterChart.data = data
                self.managerPerformanceScatterChart.notifyDataSetChanged()
            }
        }
    }
    
}
