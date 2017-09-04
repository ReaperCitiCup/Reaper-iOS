//
//  RPFundManagerTableViewController.swift
//  Reaper
//
//  Created by 宋 奎熹 on 2017/9/4.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RPFundManagerTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var totalScopeLabel: UILabel!
    @IBOutlet weak var bestReturnLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var appointedDateLabel: UILabel!
    
    var managerModel: RPManagerModel? = nil {
        didSet {
            self.nameLabel.text = managerModel?.name
            self.infoLabel.text = managerModel?.introduction
            self.companyLabel.text = self.companyLabel.text?.appending((managerModel?.company?.name)!)
            self.appointedDateLabel.text = self.appointedDateLabel.text?.appending((managerModel?.appointedDate)!)
            self.totalScopeLabel.text = String.init(format: "%.2f", (managerModel?.totalScope)!)
            self.bestReturnLabel.text = String.init(format: "%.2f", (managerModel?.bestReturns)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "基金经理"
        self.tableView.backgroundColor = .rpColor
        
        self.loadManager(of: "30061448")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadManager(of code: String) {
        Alamofire.request("http://106.15.203.173:8080/api/manager/\(code)").responseJSON { response in
            if let json = response.result.value {
                let result = JSON(json)
                self.managerModel = RPManagerModel(code: result["code"].stringValue,
                                                   name: result["name"].stringValue,
                                                   appointedDate: result["appointedDate"].stringValue,
                                                   company: RPCompanyShortModel(code: result["company"]["id"].stringValue,
                                                                                name: result["company"]["name"].stringValue),
                                                   totalScope: result["totalScope"].doubleValue,
                                                   bestReturns: result["totalScope"].doubleValue,
                                                   introduction: result["introduction"].stringValue)
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

}
