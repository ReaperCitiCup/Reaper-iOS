//
//  RPCompanyTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/7.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Charts
import SVProgressHUD

class RPCompanyTableViewController: UITableViewController {
    
    var companyModel: RPCompanyShortModel?
    private var nameLabel: UILabel?
    
    @IBOutlet weak var fundPerformanceScatterChart: ScatterChartView!
    @IBOutlet weak var managerPerformanceScatterChart: ScatterChartView!
    @IBOutlet weak var assetAllocationPieChart: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = .rpColor
        
        fundPerformanceScatterChart.chartDescription?.text = ""
        managerPerformanceScatterChart.chartDescription?.text = ""
        assetAllocationPieChart.chartDescription?.text = ""
        
        fundPerformanceScatterChart.rightAxis.drawLabelsEnabled = false
        managerPerformanceScatterChart.rightAxis.drawLabelsEnabled = false
        
        fundPerformanceScatterChart.xAxis.labelPosition = .bottom
        managerPerformanceScatterChart.xAxis.labelPosition = .bottom
        
        fundPerformanceScatterChart.legend.enabled = false
        managerPerformanceScatterChart.legend.enabled = false

        assetAllocationPieChart.drawHoleEnabled = false
        
        SVProgressHUD.show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "基金公司"
        self.updateCharts()

        print("Company Code : \(companyModel?.code ?? "")")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func updateCharts() {
        guard companyModel != nil else {
            return
        }

        SVProgressHUD.show()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation {
            self.updateFundPerformance()
        }
        queue.addOperation {
            self.updateManagerPerformance()
        }
        queue.addOperation {
            self.updateAssetAllocation()
        }
        queue.addOperation {
            SVProgressHUD.dismiss()
        }
    }

    @IBAction func horizontalAction(_ sender: UIButton) {
        guard companyModel != nil else {
            SVProgressHUD.showInfo(withStatus: "数据仍在加载")
            SVProgressHUD.dismiss(withDelay: 2.0)
            return
        }
        SVProgressHUD.show()
        switch sender.tag {
        case 0:
            self.updateStyleProfit()
        case 1:
            self.updateStyleRisk()
        case 2:
            self.updateIndustryProfit()
        case 3:
            self.updateIndustryRisk()
        default:
            break
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row <= 2 {
            return SCREEN_WIDTH - 20
        } else {
            return 100.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60))
        let label = UILabel(frame: CGRect(x: 13, y: 6, width: SCREEN_WIDTH - 19, height: 48))
        label.font = UIFont(name: "PingFangSC-Semibold", size: 28.0)
        label.text = self.companyModel?.name
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
        if segue.identifier == "horizontalSegue" {
            SVProgressHUD.dismiss()
            let vc = segue.destination as! RPHorizontalBarChartViewController
            vc.dataModel = (sender as! RPChartViewModel)
        }
    }

}
