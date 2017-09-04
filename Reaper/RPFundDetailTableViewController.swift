//
//  RPFundDetailTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/3.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts
import SVProgressHUD

class RPFundDetailTableViewController: UITableViewController {
    
    var fundCode: String? = nil
    var fundDetailModel: RPFundDetailModel?
    
    var nameLabel: UILabel?
    @IBOutlet weak var unitNetValueLabel: UILabel!
    @IBOutlet weak var cumulativeNetValueLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var managerLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var scopeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    @IBOutlet weak var rate1MonthLabel: UILabel!
    @IBOutlet weak var rate3MonthLabel: UILabel!
    @IBOutlet weak var rate6MonthLabel: UILabel!
    @IBOutlet weak var rate1YearLabel: UILabel!
    @IBOutlet weak var rate3YearLabel: UILabel!
    @IBOutlet weak var rateSinceFoundLabel: UILabel!
    var rateLabels: [UILabel]?
    
    @IBOutlet weak var ratePeriodButton: UIButton!
    
    @IBOutlet weak var netValueChart: LineChartView!
    @IBOutlet weak var rateChart: LineChartView!
    @IBOutlet weak var currentAssetChart: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "基金详情"
        self.tableView.backgroundColor = .rpColor
        self.rateLabels = [rate1MonthLabel, rate3MonthLabel, rate6MonthLabel, rate1YearLabel, rate3YearLabel, rateSinceFoundLabel]
        
        self.ratePeriodButton.layer.cornerRadius = 3.0
        self.ratePeriodButton.layer.masksToBounds = true
        
        self.netValueChart.chartDescription?.text = ""
        self.rateChart.chartDescription?.text = ""
        self.currentAssetChart.chartDescription?.text = ""
        
        self.loadFundData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadFundData() {
        guard (fundCode != nil) else {
            return
        }
        SVProgressHUD.show(withStatus: "加载中")
        Alamofire.request("http://106.15.203.173:8080/api/fund/\(fundCode ?? "")").responseJSON { response in
        if let json = response.result.value {
            let result = JSON(json)
            
            var managerArray = [RPManagerShortModel]()
            for dict in result["manager"].arrayValue {
                managerArray.append(RPManagerShortModel(code: dict["code"].stringValue, name: dict["name"].stringValue))
            }
            
            self.fundDetailModel = RPFundDetailModel(code: result["code"].stringValue,
                                                     name: result["name"].stringValue,
                                                     type: result["type"].arrayValue.map({$0.stringValue}),
                                                     establishmentDate: result["establishmentDate"].stringValue,
                                                     scope: result["scope"].doubleValue,
                                                     unitNetValue: result["unitNetValue"].doubleValue,
                                                     cumulativeNetValue: result["cumulativeNetValue"].doubleValue,
                                                     dailyRate: result["dailyRate"].doubleValue,
                                                     rate: result["rate"].dictionaryObject as? [String:Double],
                                                     manager: managerArray,
                                                     company: RPCompanyShortModel(code: result["company"]["code"].stringValue,
                                                                                  name: result["company"]["name"].stringValue))
            
            self.nameLabel?.text = "\(String(self.fundDetailModel?.name ?? "")!) \(String( self.fundDetailModel?.code ?? "")!)"
            self.unitNetValueLabel.text = String(format: "%.4f", (self.fundDetailModel?.unitNetValue)!)
            self.cumulativeNetValueLabel.text = String(format: "%.4f", (self.fundDetailModel?.cumulativeNetValue)!)
            self.typeLabel.text = self.fundDetailModel?.type.reduce("", { r, s in "\(r ?? "")/\(s)"})
            self.scopeLabel.text = String(format: "%.2f", (self.fundDetailModel?.scope)!)
            self.rateLabel.text = String(format: "%.2f", (self.fundDetailModel?.dailyRate)!)
            if self.fundDetailModel?.manager?.count != 0 {
                self.managerLabel.text = self.fundDetailModel?.manager?[0].name
            }
            self.companyLabel.text = self.fundDetailModel?.company?.name
            self.dateLabel.text = self.fundDetailModel?.establishmentDate
            
            let dict = self.fundDetailModel?.rate
            if dict != nil {
                self.rate1MonthLabel.text?.append(String(format: "%.2f", dict!["oneMonth"]!))
                self.rate3MonthLabel.text?.append(String(format: "%.2f", dict!["threeMonth"]!))
                self.rate6MonthLabel.text?.append(String(format: "%.2f", dict!["sixMonth"]!))
                self.rate1YearLabel.text?.append(String(format: "%.2f", dict!["oneYear"]!))
                self.rate3YearLabel.text?.append(String(format: "%.2f", dict!["threeYear"]!))
                self.rateSinceFoundLabel.text?.append(String(format: "%.2f", dict!["sinceFounded"]!))
                
                for label in self.rateLabels! {
                    let attributedString = label.attributedText as! NSMutableAttributedString
                    attributedString.addAttributes([
                        NSForegroundColorAttributeName: UIColor.black
                        ], range: NSMakeRange(4, (label.text?.characters.count)! - 4))
                    label.attributedText = attributedString
                }
            }
            
            }
        }
        
        self.updateChartsData()
    }
    
    func updateChartsData() {
        
        var unitNetValueDataSet = LineChartDataSet()
        var cumulativeNetValueDataSet = LineChartDataSet()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation {
            Alamofire.request("http://106.15.203.173:8080/api/fund/\(self.fundCode ?? "")/unit-net-value").responseJSON { response in
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
                    
                    unitNetValueDataSet = LineChartDataSet(values: dataEntries, label: "单位净值走势")
                    unitNetValueDataSet.drawCircleHoleEnabled = false
                    unitNetValueDataSet.drawCirclesEnabled = false
                    
                    if unitNetValueDataSet.entryCount > 0 && cumulativeNetValueDataSet.entryCount > 0 {
                        let data = LineChartData(dataSets: [unitNetValueDataSet, cumulativeNetValueDataSet])
                        self.netValueChart.data = data
                        self.netValueChart.xAxis.valueFormatter = RPFundDateFormatter(labels: dates)
                    }
                }
            }
        }
        queue.addOperation {
            Alamofire.request("http://106.15.203.173:8080/api/fund/\(self.fundCode ?? "")/cumulative-net-value").responseJSON { response in
                if let json = response.result.value {
                    let result2 = JSON(json).arrayValue
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
                    cumulativeNetValueDataSet.setColor(UIColor.red)
                    
                    if unitNetValueDataSet.entryCount > 0 && cumulativeNetValueDataSet.entryCount > 0 {
                        let data = LineChartData(dataSets: [unitNetValueDataSet, cumulativeNetValueDataSet])
                        self.netValueChart.data = data
                        self.netValueChart.xAxis.valueFormatter = RPFundDateFormatter(labels: dates2)
                    }
                }
            }
        }
        queue.addOperation {
            self.updateRate(during: 0)
        }
        queue.addOperation {
            Alamofire.request("http://106.15.203.173:8080/api/fund/\(self.fundCode ?? "")/current-asset").responseJSON { response in
                if let json = response.result.value {
                    let result4 = JSON(json).dictionaryValue
                    var currentAssetDict = [String:Double]()
                    var allButOthers = 0.0
                    for (key, value) in result4 {
                        if value.doubleValue > 0 {
                            currentAssetDict[key] = value.doubleValue
                            allButOthers = allButOthers + value.doubleValue
                        }
                    }
                    currentAssetDict["other"] = 100 - allButOthers
                    
                    var dataEntries4 = [PieChartDataEntry]()
                    for (key, value) in currentAssetDict {
                        dataEntries4.append(PieChartDataEntry(value: value, label: key))
                    }
                    let currentAssetDataSet = PieChartDataSet(values: dataEntries4, label: "当前资产配置")
                    currentAssetDataSet.colors = ChartColorTemplates.vordiplom()
                    currentAssetDataSet.valueTextColor = .black
                    currentAssetDataSet.entryLabelColor = .clear
                    
                    let data = PieChartData(dataSet: currentAssetDataSet)
                    self.currentAssetChart.data = data
                }
            }
        }
        queue.addOperation {
            SVProgressHUD.dismiss()
        }
    }
    
    func updateRate(during time: Int) {
        Alamofire.request("http://106.15.203.173:8080/api/fund/\(self.fundCode ?? "")/rate?month=\(time == 0 ? "all" : String(time))").responseJSON { response in
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
                let rateDataSet = LineChartDataSet(values: dataEntries3, label: "累积收益率走势")
                rateDataSet.drawCircleHoleEnabled = false
                rateDataSet.drawCirclesEnabled = false
                
                let data = LineChartData(dataSet: rateDataSet)
                self.rateChart.data = data
                self.rateChart.xAxis.valueFormatter = RPFundDateFormatter(labels: dates3)
            }
        }
    }
    
    @IBAction func chooseRateAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "chooseRateSegue", sender: sender)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60))
        let label = UILabel(frame: CGRect(x: 13, y: 6, width: SCREEN_WIDTH - 19, height: 48))
        label.font = UIFont(name: "PingFangSC-Semibold", size: 28.0)
        label.text = ""
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
        if segue.identifier == "chooseRateSegue" {
            let vc = segue.destination as! RPFundRateChoiceTableViewController
            vc.delegate = self
            vc.nowPeriod = (sender as! UIButton).tag
        }
    }
    
}

extension RPFundDetailTableViewController: RPFundRateChoiceDelegate {
    func didSelectRate(with rateChoiceModel: RPFundRateChoiceModel) {
        self.ratePeriodButton.tag = rateChoiceModel.tag
        self.ratePeriodButton.setTitle(rateChoiceModel.description, for: .normal)
        self.updateRate(during: rateChoiceModel.tag)
    }
}
