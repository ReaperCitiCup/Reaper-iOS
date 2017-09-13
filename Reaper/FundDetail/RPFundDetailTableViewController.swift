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
    
    var fundCode: String?
    var fundDetailModel: RPFundDetailModel? {
        didSet {
            self.fundCode = self.fundDetailModel?.code
            
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
            self.assessDailyRateLabel.text = String(format: "%.4f%%", (self.fundDetailModel?.assessDailyRate)!)
            self.assessIncreaseLabel.text = String(format: "%.4f", (self.fundDetailModel?.assessIncrease)!)
            self.assessNetValueLabel.text = String(format: "%.4f", (self.fundDetailModel?.assessNetValue)!)
            
            let dict = self.fundDetailModel?.rate
            if dict != nil {
                self.rate1MonthLabel.text?.append(String(format: "%.2f%%", dict!["oneMonth"] ?? 0.0))
                self.rate3MonthLabel.text?.append(String(format: "%.2f%%", dict!["threeMonths"] ?? 0.0))
                self.rate6MonthLabel.text?.append(String(format: "%.2f%%", dict!["sixMonths"] ?? 0.0))
                self.rate1YearLabel.text?.append(String(format: "%.2f%%", dict!["oneYear"] ?? 0.0))
                self.rate3YearLabel.text?.append(String(format: "%.2f%%", dict!["threeYears"] ?? 0.0))
                self.rateSinceFoundLabel.text?.append(String(format: "%.2f%%", dict!["sinceFounded"] ?? 0.0))
                
                for label in self.rateLabels! {
                    let attributedString = label.attributedText as! NSMutableAttributedString
                    attributedString.addAttributes([
                        NSForegroundColorAttributeName: UIColor.black
                        ], range: NSRange.init(location: 4, length: (label.text?.characters.count)! - 4))
                    label.attributedText = attributedString
                }
            }

            SVProgressHUD.dismiss()
        }
    }
    
    private var nameLabel: UILabel?
    @IBOutlet weak var unitNetValueLabel: UILabel!
    @IBOutlet weak var cumulativeNetValueLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var managerLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var scopeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var assessNetValueLabel: UILabel!
    @IBOutlet weak var assessIncreaseLabel: UILabel!
    @IBOutlet weak var assessDailyRateLabel: UILabel!
    
    private var rateLabels: [UILabel]?
    @IBOutlet weak var rate1MonthLabel: UILabel!
    @IBOutlet weak var rate3MonthLabel: UILabel!
    @IBOutlet weak var rate6MonthLabel: UILabel!
    @IBOutlet weak var rate1YearLabel: UILabel!
    @IBOutlet weak var rate3YearLabel: UILabel!
    @IBOutlet weak var rateSinceFoundLabel: UILabel!

    @IBOutlet weak var currentAssetChart: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = .rpColor
        self.rateLabels = [rate1MonthLabel, rate3MonthLabel, rate6MonthLabel, rate1YearLabel, rate3YearLabel, rateSinceFoundLabel]

        self.currentAssetChart.chartDescription?.text = ""
        self.currentAssetChart.drawHoleEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "基金详情"

        updateCurrentAsset()
    }
    
    @IBAction func netValueAction(_ sender: UIButton) {
        guard fundCode != nil else {
            return
        }

        SVProgressHUD.show()

        if sender.tag == 0 {
            self.unitNetValueAction()
        } else {
            self.cumulativeNetValueAction()
        }
    }

    private func unitNetValueAction() {
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

                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "fullChartSegue", sender:
                    RPLineChartViewModel(title: "单位净值走势",
                                         data: LineChartData(dataSet: unitNetValueDataSet),
                                         valueFormatter: RPFundDateFormatter(labels: dates)))
            }
        }
    }

    private func cumulativeNetValueAction() {
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
                cumulativeNetValueDataSet.setColor(.red)

                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "fullChartSegue", sender:
                    RPLineChartViewModel(title: "累积净值走势",
                                         data: LineChartData(dataSet: cumulativeNetValueDataSet),
                                         valueFormatter: RPFundDateFormatter(labels: dates2)))
            }
        }
    }

    @IBAction func updateRateAction(_ sender: UIButton) {
        guard fundCode != nil else {
            return
        }

        SVProgressHUD.show()
        Alamofire.request(
            "\(BASE_URL)/fund/\(self.fundCode ?? "")/rate",
            method: .get,
            parameters: ["month": sender.tag == -1 ? "all" : String(sender.tag)]
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
                let rateDataSet = LineChartDataSet(values: dataEntries3, label: "累积收益率走势 - \(sender.titleLabel?.text ?? "")")
                rateDataSet.drawCircleHoleEnabled = false
                rateDataSet.drawCirclesEnabled = false
                rateDataSet.valueFont = UIFont(name: "PingFangSC-Regular", size: 15.0)!

                SVProgressHUD.dismiss()

                self.performSegue(withIdentifier: "fullChartSegue", sender:
                    RPLineChartViewModel(title: "累积收益率走势 - \(sender.titleLabel?.text ?? "")",
                                         data: LineChartData(dataSet: rateDataSet),
                                         valueFormatter: RPFundDateFormatter(labels: dates3)))
            }
        }
    }

    private func updateCurrentAsset() {
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
                    self.currentAssetChart.notifyDataSetChanged()
                }
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4 {
            return SCREEN_WIDTH - 20
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
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
