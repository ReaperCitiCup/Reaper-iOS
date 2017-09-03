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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "基金详情"
        self.tableView.backgroundColor = .rpColor
        self.rateLabels = [rate1MonthLabel, rate3MonthLabel, rate6MonthLabel, rate1YearLabel, rate3YearLabel, rateSinceFoundLabel]
        
        self.loadFundData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadFundData() {
        guard (fundCode != nil) else {
            return
        }
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
            
            self.nameLabel?.text = self.fundDetailModel?.name
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
                        NSAttributedStringKey.foregroundColor: UIColor.black
                        ], range: NSMakeRange(4, (label.text?.characters.count)! - 4))
                    label.attributedText = attributedString
                }
            }
            
            }
        }
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

}
