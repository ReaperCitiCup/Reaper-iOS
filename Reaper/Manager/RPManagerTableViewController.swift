//
//  RPManagerTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/4.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts
import BTNavigationDropdownMenu
import SVProgressHUD
import Kingfisher

class RPManagerTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var totalScopeLabel: UILabel!
    @IBOutlet weak var bestReturnLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var appointedDateLabel: UILabel!
    @IBOutlet weak var managerImageView: UIImageView!
    
    @IBOutlet weak var abilityRadarChart: RadarChartView!
    @IBOutlet weak var fundRankHorizontalBarChart: RPHorizontalBarChartView!
    @IBOutlet weak var fundRateTrendChart: LineChartView!
    @IBOutlet weak var managerFundPerformanceScatterChart: ScatterChartView!
    @IBOutlet weak var managerPerformanceScatterChart: ScatterChartView!
    
    @IBOutlet weak var historyFundView: RPManagerHistoryFundView!
    
    var fundCode: String? = nil {
        didSet {
            let url = "\(BASE_URL)/fund/\(self.fundCode ?? "")/managers"
            Alamofire.request(url).responseJSON { response in
                if let json = response.result.value {
                    let result = JSON(json).arrayValue
                    var tempManagers = [RPManagerShortModel]()
                    for dict in result {
                        tempManagers.append(RPManagerShortModel(code: dict["id"].stringValue,
                                                            name: dict["name"].stringValue,
                                                            startDate: dict["startDate"].stringValue,
                                                            endDate: dict["endDate"].stringValue,
                                                            days: dict["days"].intValue,
                                                            returns: dict["returns"].doubleValue))
                    }
                    self.managers = tempManagers
                }
            }
        }
    }
    
    var managers: [RPManagerShortModel]? = nil {
        didSet {
            self.loadManager(of: managers![0].code)
            
            let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController,
                                                    containerView: self.navigationController!.view,
                                                    title: BTTitle.title(managers![0].name),
                                                    items: managers!.map { $0.name })
            menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> Void in
                if let code = self?.managers![indexPath].code {
                    self?.loadManager(of: code)
                }
            }
            
            self.menuView = menuView
        }
    }
    
    var managerModel: RPManagerModel? = nil {
        didSet {
            SVProgressHUD.show()

            DispatchQueue.main.async {
                self.nameLabel.text = self.managerModel?.name
                self.infoLabel.text = self.managerModel?.introduction
                self.companyLabel.text = String.init(format: "任职起始时间: %@", (self.managerModel?.company?.name)!)
                self.appointedDateLabel.text = String.init(format: "现任基金公司: %@", (self.managerModel?.appointedDate)!)
                self.totalScopeLabel.text = String.init(format: "%.2f", (self.managerModel?.totalScope)!)
                self.bestReturnLabel.text = String.init(format: "%.2f", (self.managerModel?.bestReturns)!)
                if let url = self.managerModel?.managerImageUrl {
                    self.managerImageView.kf.setImage(with: URL(string: url))
                }
            }

            self.updateChartsData()
        }
    }
    
    private var menuView: BTNavigationDropdownMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .rpColor
        self.tableView.tableHeaderView = UIView()
        
        self.abilityRadarChart.chartDescription?.text = ""
        self.fundRateTrendChart.chartDescription?.text = ""
        self.fundRankHorizontalBarChart.chartDescription?.text = ""
        self.managerFundPerformanceScatterChart.chartDescription?.text = ""
        self.managerPerformanceScatterChart.chartDescription?.text = ""
        
        self.abilityRadarChart.legend.enabled = false
        self.abilityRadarChart.yAxis.drawLabelsEnabled = false
        self.abilityRadarChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["经验值", "择时能力", "收益率", "择股能力", "抗风险"])
        
        self.fundRateTrendChart.xAxis.labelPosition = .bottom
        self.fundRateTrendChart.xAxis.drawGridLinesEnabled = false
        self.fundRateTrendChart.rightAxis.drawAxisLineEnabled = false
        self.fundRateTrendChart.rightAxis.drawLabelsEnabled = false

        managerFundPerformanceScatterChart.rightAxis.drawLabelsEnabled = false
        managerPerformanceScatterChart.rightAxis.drawLabelsEnabled = false

        managerFundPerformanceScatterChart.xAxis.labelPosition = .bottom
        managerPerformanceScatterChart.xAxis.labelPosition = .bottom

        managerFundPerformanceScatterChart.legend.enabled = false
        managerPerformanceScatterChart.legend.enabled = false
        
        SVProgressHUD.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "基金经理"
        self.tabBarController?.navigationItem.titleView = menuView

        print("Manager Code : \(managerModel?.code ?? "")")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tabBarController?.navigationItem.titleView = nil

        menuView?.hide()
    }
    
    func loadManager(of code: String) {
        Alamofire.request("\(BASE_URL)/manager/\(code)").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json)
                self.managerModel = RPManagerModel(code: result["id"].stringValue,
                                                   name: result["name"].stringValue,
                                                   appointedDate: result["appointedDate"].stringValue,
                                                   company: RPCompanyShortModel(code: result["company"]["id"].stringValue,
                                                                                name: result["company"]["name"].stringValue),
                                                   totalScope: result["totalScope"].doubleValue,
                                                   bestReturns: result["bestReturns"].doubleValue,
                                                   introduction: result["introduction"].stringValue,
                                                   managerImageUrl: result["managerImageUrl"].stringValue)
                self.tableView.reloadData()
            }
        }
    }
    
    private func updateChartsData() {
        guard managerModel != nil else {
            return
        }

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        // 现任收益率走势
        queue.addOperation {
            self.updateFundRateTrend()
        }
        // 现任基金排名
        queue.addOperation {
            self.updateManagerFundRank()
        }
        // 综合能力
        queue.addOperation {
            self.updateAbility()
        }
        // 历史基金
        queue.addOperation {
            self.updateHistoryFund()
        }
        // 历任基金表现
        queue.addOperation {
            self.updateFundPerformance()
        }
        // 基金经理表现
        queue.addOperation {
            self.updateManagerPerformance()
        }
        queue.addOperation {
            SVProgressHUD.dismiss()
        }
    }

    @IBAction func seeFullChartAction(_ sender: UIButton) {
        if let data = self.fundRateTrendChart.data {
            self.performSegue(withIdentifier: "fullChartSegue", sender: RPChartViewModel(title: "现任基金收益率走势",
                                                                                             data: data,
                                                                                             valueFormatter: self.fundRateTrendChart.xAxis.valueFormatter))
        } else {
            SVProgressHUD.showInfo(withStatus: "数据仍在加载")
            SVProgressHUD.dismiss(withDelay: 2.0)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 3, 7, 8:
            return SCREEN_WIDTH - 20
        case 6:
            return CGFloat(75 + historyFundView.fundHistoryModels.count * 30)
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullChartSegue" {
            let vc = segue.destination as! RPLineChartViewController
            vc.dataModel = (sender as? RPChartViewModel)
        }
    }

}
