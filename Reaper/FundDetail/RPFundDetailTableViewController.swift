//
//  RPFundDetailTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/3.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
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
            self.typeLabel.text = self.fundDetailModel?.type.joined(separator: "/")
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
            
            if let rateDict = self.fundDetailModel?.rate {
                let rates = [rateDict["oneMonth"], rateDict["threeMonths"], rateDict["sixMonths"],
                             rateDict["oneYear"], rateDict["threeYears"], rateDict["sinceFounded"]]
                
                for i in 0..<self.rateMonthLabels.count {
                    let label = self.rateMonthLabels[i]
                    let attributedString = label.attributedText as! NSMutableAttributedString
                    attributedString.addAttributes([
                        NSForegroundColorAttributeName: UIColor.black
                        ], range: NSRange.init(location: 4, length: (label.text?.characters.count)! - 4))
                    label.attributedText = attributedString
                    
                    label.text?.append(String(format: "%.2f%%", rates[i] ?? 0.0))
                }
            }
            
            self.updateCurrentAsset()

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
    
    @IBOutlet var rateMonthLabels: [UILabel]!

    @IBOutlet weak var currentAssetChart: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentAssetChart.chartDescription?.text = ""
        self.currentAssetChart.drawHoleEnabled = false
        
        SVProgressHUD.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "基金详情"
    }
    
    @IBAction func netValueAction(_ sender: UIButton) {
        guard fundCode != nil else {
            SVProgressHUD.showInfo(withStatus: "数据仍在加载")
            SVProgressHUD.dismiss(withDelay: 2.0)
            return
        }

        SVProgressHUD.show()

        if sender.tag == 0 {
            self.unitNetValueAction()
        } else {
            self.cumulativeNetValueAction()
        }
    }

    @IBAction func updateRateAction(_ sender: UIButton) {
        guard fundCode != nil else {
            SVProgressHUD.showInfo(withStatus: "数据仍在加载")
            SVProgressHUD.dismiss(withDelay: 2.0)
            return
        }

        self.rateAction(sender.tag == -1 ? "all" : String(sender.tag),
                        title: sender.titleLabel?.text ?? "")
    }

    @IBAction func horizontalAction(_ sender: UIButton) {
        guard self.fundCode != nil else {
            SVProgressHUD.showInfo(withStatus: "数据仍在加载")
            SVProgressHUD.dismiss(withDelay: 2.0)
            return
        }
        SVProgressHUD.show()
        switch sender.tag {
        case 0:
            self.updateStyleProfit()
            break
        case 1:
            self.updateStyleRisk()
            break
        case 2:
            self.updateIndustryProfit()
            break
        case 3:
            self.updateIndustryRisk()
            break
        default:
            break
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60))
        let label = UILabel(frame: CGRect(x: 13, y: 6, width: SCREEN_WIDTH - 19, height: 48))
        label.font = UIFont(name: "PingFangSC-Semibold", size: 28.0)
        label.text = "\(String(self.fundDetailModel?.name ?? "")!) \(String( self.fundDetailModel?.code ?? "")!)"
        label.textColor = .white
        self.nameLabel = label
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 6 {
            return SCREEN_WIDTH - 20
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        SVProgressHUD.dismiss()
        if segue.identifier == "fullChartSegue" {
            let vc = segue.destination as! RPLineChartViewController
            vc.dataModel = (sender as! RPChartViewModel)
        } else if segue.identifier == "horizontalSegue" {
            let vc = segue.destination as! RPHorizontalBarChartViewController
            vc.dataModel = (sender as! RPChartViewModel)
        }
    }
    
}
